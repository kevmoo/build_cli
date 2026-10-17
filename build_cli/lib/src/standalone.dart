// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:args/args.dart';
import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:yaml/yaml.dart';

import 'build_cli_generator.dart';
import 'util.dart';
import 'version.dart';

const _defaultDirectories = ['lib', 'bin', 'example', 'test', 'tool'];
const _headerLine =
    '// **************************************************************************';
final _generatorBannerPattern = RegExp(
  r'^// \*{74}\r?\n// ([^\r\n]+)\r?\n// \*{74}$',
  multiLine: true,
);

/// Runs the standalone `build_cli` CLI and returns an exit code.
Future<int> runBuildCli(
  List<String> args, {
  String? workingDirectory,
  StringSink? out,
  StringSink? err,
}) async {
  final stdoutSink = out ?? stdout;
  final stderrSink = err ?? stderr;
  final parsed = _parseArgs(args, stdoutSink, stderrSink);
  if (parsed.earlyExitCode case final code?) {
    return code;
  }

  final rootDir = p.normalize(
    p.absolute(workingDirectory ?? Directory.current.path),
  );
  final resolvedTargets = _resolveTargetPaths(
    parsed.restPaths,
    rootDir,
    stderrSink,
  );
  if (resolvedTargets.errorExitCode case final code?) {
    return code;
  }

  final candidateFiles = _collectCandidateFiles(resolvedTargets.targets);
  if (candidateFiles.isEmpty) {
    return 0;
  }

  final packageRoots = candidateFiles.map(_findPackageRoot).toSet().toList()
    ..sort();
  final collection = AnalysisContextCollection(
    includedPaths: packageRoots,
    sdkPath: cli_util.sdkPath,
  );

  final packageStates = <String, _PackageState>{};
  var allSucceeded = true;

  for (final filePath in candidateFiles) {
    final pkgRoot = _findPackageRoot(filePath);
    final state = packageStates.putIfAbsent(
      pkgRoot,
      () => _loadPackageState(pkgRoot, stderrSink),
    );
    if (!state.isValid) {
      allSucceeded = false;
      continue;
    }

    final ok = await _processCandidateFile(
      collection,
      filePath,
      state: state,
      checkOnly: parsed.checkOnly,
      workingDir: rootDir,
      out: stdoutSink,
      err: stderrSink,
    );
    if (!ok) {
      allSucceeded = false;
    }
  }

  return allSucceeded ? 0 : 1;
}

({bool checkOnly, List<String> restPaths, int? earlyExitCode}) _parseArgs(
  List<String> args,
  StringSink out,
  StringSink err,
) {
  final parser = ArgParser()
    ..addFlag(
      'check',
      abbr: 'c',
      negatable: false,
      help:
          'Check that generated .g.dart files match expected output without '
          'writing.',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    );

  final ArgResults results;
  try {
    results = parser.parse(args);
  } on ArgParserException catch (e) {
    err
      ..writeln(e.message)
      ..writeln()
      ..writeln('Usage: build_cli [options] [<paths...>]')
      ..writeln()
      ..writeln(parser.usage);
    return (checkOnly: false, restPaths: const [], earlyExitCode: 64);
  }

  if (results['help'] as bool) {
    out
      ..writeln(
        'Generate .g.dart files for @CliOptions classes without build_runner.',
      )
      ..writeln()
      ..writeln('Usage: build_cli [options] [<paths...>]')
      ..writeln()
      ..writeln(parser.usage);
    return (checkOnly: false, restPaths: const [], earlyExitCode: 0);
  }

  return (
    checkOnly: results['check'] as bool,
    restPaths: results.rest,
    earlyExitCode: null,
  );
}

({List<String> targets, int? errorExitCode}) _resolveTargetPaths(
  List<String> restPaths,
  String rootDir,
  StringSink err,
) {
  if (restPaths.isEmpty) {
    final defaults = [
      for (final dirName in _defaultDirectories)
        if (Directory(p.join(rootDir, dirName)).existsSync())
          p.join(rootDir, dirName),
    ];
    return (targets: defaults, errorExitCode: null);
  }

  final targets = <String>[];
  for (final rawPath in restPaths) {
    final resolvedPath = p.normalize(p.absolute(rootDir, rawPath));
    if (FileSystemEntity.typeSync(resolvedPath) ==
        FileSystemEntityType.notFound) {
      err.writeln('Could not find file or directory "$rawPath".');
      return (targets: const [], errorExitCode: 64);
    }
    targets.add(resolvedPath);
  }
  return (targets: targets, errorExitCode: null);
}

List<String> _collectCandidateFiles(List<String> targets) {
  final found = <String>{};
  for (final target in targets) {
    if (FileSystemEntity.isDirectorySync(target)) {
      _collectFromDirectory(Directory(target), found);
    } else if (_isCandidateDartFile(File(target))) {
      found.add(target);
    }
  }

  return found.toList()..sort();
}

void _collectFromDirectory(Directory dir, Set<String> found) {
  for (final entity in dir.listSync(followLinks: false)) {
    final base = p.basename(entity.path);
    if (base.startsWith('.')) {
      continue;
    }
    if (entity is Directory) {
      if (base == 'build') {
        continue;
      }
      _collectFromDirectory(entity, found);
    } else if (entity is File && _isCandidateDartFile(entity)) {
      found.add(p.normalize(entity.path));
    }
  }
}

bool _isCandidateDartFile(File file) {
  final path = file.path;
  if (!path.endsWith('.dart') ||
      path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart')) {
    return false;
  }
  return file.readAsStringSync().contains('CliOptions');
}

String _findPackageRoot(String filePath) {
  var dir = p.dirname(filePath);
  while (true) {
    if (File(p.join(dir, 'pubspec.yaml')).existsSync()) {
      return dir;
    }
    final parent = p.dirname(dir);
    if (parent == dir) {
      return p.dirname(filePath);
    }
    dir = parent;
  }
}

class _PackageState {
  final String rootDir;
  final bool isValid;
  final List<String> ignoreForFile;

  const _PackageState({
    required this.rootDir,
    required this.isValid,
    required this.ignoreForFile,
  });
}

_PackageState _loadPackageState(String pkgRoot, StringSink err) {
  final pubspecFile = File(p.join(pkgRoot, 'pubspec.yaml'));
  if (pubspecFile.existsSync()) {
    final content = pubspecFile.readAsStringSync();
    final yaml = loadYaml(content, sourceUrl: pubspecFile.uri);
    final pkgName = (yaml is YamlMap && yaml['name'] is String)
        ? yaml['name'] as String
        : p.basename(pkgRoot);
    try {
      validatePubspecSdkConstraint(
        content,
        packageName: pkgName,
        sourceUrl: pubspecFile.uri,
      );
    } on InvalidGenerationSourceError catch (e) {
      err.writeln(e.message);
      return _PackageState(
        rootDir: pkgRoot,
        isValid: false,
        ignoreForFile: const [],
      );
    }
  }

  return _PackageState(
    rootDir: pkgRoot,
    isValid: true,
    ignoreForFile: _readIgnoreForFileFromBuildYaml(pkgRoot),
  );
}

List<String> _readIgnoreForFileFromBuildYaml(String pkgRoot) {
  final buildFile = File(p.join(pkgRoot, 'build.yaml'));
  if (!buildFile.existsSync()) {
    return const [];
  }
  try {
    final yaml = loadYaml(buildFile.readAsStringSync());
    if (yaml is! YamlMap) return const [];
    final targets = yaml['targets'];
    if (targets is! YamlMap) return const [];
    final defaultTarget = targets[r'$default'];
    if (defaultTarget is! YamlMap) return const [];
    final builders = defaultTarget['builders'];
    if (builders is! YamlMap) return const [];
    final combining =
        builders['source_gen|combining_builder'] ??
        builders['source_gen:combining_builder'];
    if (combining is! YamlMap) return const [];
    final options = combining['options'];
    if (options is! YamlMap) return const [];
    final ignores = options['ignore_for_file'];
    if (ignores is YamlList) {
      return ignores.whereType<String>().toList();
    }
  } on Object {
    // Ignore malformed build.yaml files in standalone mode.
  }
  return const [];
}

Future<bool> _processCandidateFile(
  AnalysisContextCollection collection,
  String filePath, {
  required _PackageState state,
  required bool checkOnly,
  required String workingDir,
  required StringSink out,
  required StringSink err,
}) async {
  final displayInput = _displayPath(filePath, workingDir);
  final context = collection.contextFor(filePath);
  final resolved = await context.currentSession.getResolvedUnit(filePath);
  if (resolved is! ResolvedUnitResult) {
    err.writeln('Failed to analyze $displayInput.');
    return false;
  }
  if (resolved.isPart) {
    return true;
  }

  final String generatedBody;
  try {
    generatedBody = generateCliForLibrary(
      LibraryReader(resolved.libraryElement),
      onWarning: err.writeln,
    );
  } on InvalidGenerationSourceError catch (e) {
    err.writeln(e);
    return false;
  }

  if (generatedBody.isEmpty) {
    return true;
  }

  final partFileName = '${p.basenameWithoutExtension(filePath)}.g.dart';
  final hasPartDirective = resolved.unit.directives
      .whereType<PartDirective>()
      .any((d) => d.uri.stringValue == partFileName);
  if (!hasPartDirective) {
    err.writeln(
      '$displayInput must include "part \'$partFileName\';" to generate CLI '
      'options.',
    );
    return false;
  }

  final outputPath = p.join(p.dirname(filePath), partFileName);
  final displayOutput = _displayPath(outputPath, workingDir);
  final outputFile = File(outputPath);
  final existingContent = outputFile.existsSync()
      ? outputFile.readAsStringSync()
      : null;

  if (existingContent != null) {
    final otherGenerators = _findOtherGenerators(existingContent);
    if (otherGenerators.isNotEmpty) {
      err.writeln(
        'Cannot overwrite $displayOutput: found output from other generators '
        '(${otherGenerators.join(', ')}). Files combining multiple generators '
        'must use build_runner.',
      );
      return false;
    }
  }

  final formattedOutput = _formatGeneratedPart(
    resolved.libraryElement,
    p.basename(filePath),
    generatedBody,
    state.ignoreForFile,
    _updateCommand(filePath, state.rootDir),
  );

  return _writeOrCheckOutput(
    outputFile,
    existingContent: existingContent,
    formattedOutput: formattedOutput,
    displayOutput: displayOutput,
    checkOnly: checkOnly,
    out: out,
    err: err,
  );
}

bool _writeOrCheckOutput(
  File outputFile, {
  required String? existingContent,
  required String formattedOutput,
  required String displayOutput,
  required bool checkOnly,
  required StringSink out,
  required StringSink err,
}) {
  if (checkOnly) {
    if (existingContent == null) {
      err.writeln(
        'Missing generated file $displayOutput. Run "dart run build_cli" to '
        'generate it.',
      );
      return false;
    }
    if (existingContent != formattedOutput) {
      err.writeln(
        'Generated file $displayOutput is out of date. Run '
        '"dart run build_cli" to update it.',
      );
      return false;
    }
    return true;
  }

  if (existingContent != formattedOutput) {
    outputFile.writeAsStringSync(formattedOutput);
    out.writeln('Generated $displayOutput.');
  }
  return true;
}

List<String> _findOtherGenerators(String content) => _generatorBannerPattern
    .allMatches(content)
    .map((m) => m.group(1)!.trim())
    .where((name) => name != 'CliGenerator')
    .toSet()
    .toList();

String _updateCommand(String filePath, String pkgRoot) {
  final baseVersion = packageVersion.split(RegExp('[-+]')).first;
  final baseCmd = 'dart run build_cli@^$baseVersion';
  if (!p.isWithin(pkgRoot, filePath)) {
    final posixPath = p.posix.joinAll(p.split(filePath));
    return '$baseCmd $posixPath';
  }
  final relSegments = p.split(p.relative(filePath, from: pkgRoot));
  if (relSegments.isNotEmpty &&
      _defaultDirectories.contains(relSegments.first)) {
    return baseCmd;
  }
  final posixRel = p.posix.joinAll(relSegments);
  return '$baseCmd $posixRel';
}

String _formatGeneratedPart(
  LibraryElement library,
  String sourceFileName,
  String generatedBody,
  List<String> ignoreForFile,
  String updateCommand,
) {
  final partChunk =
      '''
$_headerLine
// CliGenerator
$_headerLine

$generatedBody
''';
  final formattedChunk = DartFormatter(
    languageVersion: library.languageVersion.effective,
  ).format(partChunk).trim();

  final buffer = StringBuffer(defaultFileHeader)
    ..writeln()
    ..writeln('// Generated by package:build_cli $packageVersion.')
    ..writeln('// To update, run: $updateCommand');
  if (library.languageVersion.override case final override?) {
    buffer.writeln('// @dart=${override.major}.${override.minor}');
  }
  buffer.writeln();
  if (ignoreForFile.isNotEmpty) {
    buffer
      ..writeln('// ignore_for_file: ${ignoreForFile.join(', ')}')
      ..writeln();
  }
  buffer
    ..writeln("part of '$sourceFileName';")
    ..writeln()
    ..writeln(formattedChunk);

  return buffer.toString();
}

String _displayPath(String absolutePath, String workingDir) =>
    p.isWithin(workingDir, absolutePath)
    ? p.relative(absolutePath, from: workingDir)
    : absolutePath;
