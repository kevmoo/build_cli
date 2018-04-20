// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/src/string_source.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'package:build_cli/build_cli.dart';

import 'analysis_utils.dart';
import 'test_utils.dart';

final _formatter = new dart_style.DartFormatter();

void main() {
  final generator = const CliGenerator();
  CompilationUnit compUnit;

  var inlineContent = <String>[];

  Future<CompilationUnit> _getCompilationUnitForString(
      String projectPath) async {
    var filePath = p.join(getPackagePath(), 'test', 'src', 'test_input.dart');

    inlineContent.insert(0, new File(filePath).readAsStringSync());

    var source = new StringSource(inlineContent.join('\n'), 'test content');

    // null this out – should not be touched again
    inlineContent = null;

    var context = await getAnalysisContextForProjectPath(projectPath);

    var libElement = context.computeLibraryElement(source);
    return context.resolveCompilationUnit(source, libElement);
  }

  Future<String> runForElementNamed(String name) async {
    var library = new LibraryReader(compUnit.element.library);
    var element = library.allElements
        .singleWhere((e) => e.name == name, orElse: () => null);
    if (element == null) {
      fail('Could not find element `$name`.');
    }
    var annotation = generator.typeChecker.firstAnnotationOf(element);
    var generated = await generator.generateForAnnotatedElement(
        element, new ConstantReader(annotation), null);

    return _formatter.format(generated);
  }

  void testOutput(
      String testName, String elementName, String elementContent, expected) {
    inlineContent.add(elementContent);

    test(testName, () async {
      var actual = await runForElementNamed(elementName);
      printOnFailure(['`' * 72, actual, '`' * 72].join('\n'));
      expect(actual, expected);
    });
  }

  void testBadOutput(String testName, String elementName, String elementContent,
      expectedThrow) {
    inlineContent.add(elementContent);

    test(testName, () async {
      expect(runForElementNamed(elementName), expectedThrow);
    });
  }

  setUpAll(() async {
    compUnit = await _getCompilationUnitForString(getPackagePath());
  });

  testOutput('just empty', 'Empty', r'''
@CliOptions()
class Empty {}
''', r'''
Empty _$parseEmptyResult(ArgResults result) {
  return new Empty();
}

ArgParser _$populateEmptyParser(ArgParser parser) => parser;

final _$parserForEmpty = _$populateEmptyParser(new ArgParser());

Empty parseEmpty(List<String> args) {
  var result = _$parserForEmpty.parse(args);
  return _$parseEmptyResult(result);
}
''');

  group('special fields', () {
    testOutput('a command', 'WithCommand', r'''
@CliOptions()
class WithCommand {
  ArgResults command;
}
''', r'''
WithCommand _$parseWithCommandResult(ArgResults result) {
  return new WithCommand()..command = result.command;
}

ArgParser _$populateWithCommandParser(ArgParser parser) => parser;

final _$parserForWithCommand = _$populateWithCommandParser(new ArgParser());

WithCommand parseWithCommand(List<String> args) {
  var result = _$parserForWithCommand.parse(args);
  return _$parseWithCommandResult(result);
}
''');

    testBadOutput(
        'wasParsed without a source',
        'LonelyWasParsed',
        r'''
@CliOptions()
class LonelyWasParsed {
  bool nothingWasParsed;
}
''',
        throwsInvalidGenerationSourceError(
            'Could not handle field `nothingWasParsed`. Could not find expected source field `nothing`.'));
  });

  group('non-classes', () {
    testBadOutput(
        'const field',
        'theAnswer',
        r'''@CliOptions()const theAnswer = 42;''',
        throwsInvalidGenerationSourceError(
            'Generator cannot target `theAnswer`.'
            ' `@CliOptions` can only be applied to a class.',
            todo: 'Remove the `@CliOptions` annotation from `theAnswer`.'));

    testBadOutput(
        'method',
        'annotatedMethod',
        r'''@CliOptions() void annotatedMethod() => null;''',
        throwsInvalidGenerationSourceError(
            'Generator cannot target `annotatedMethod`.'
            ' `@CliOptions` can only be applied to a class.',
            todo:
                'Remove the `@CliOptions` annotation from `annotatedMethod`.'));
  });

  group('unknown types', () {
    test('in constructor arguments', () async {
      expect(
          runForElementNamed('UnknownCtorParamType'),
          throwsInvalidGenerationSourceError(
              'At least one constructor argument has an invalid type: `number`.',
              todo: 'Check names and imports.'));
    });

    test('in fields', () async {
      expect(
          runForElementNamed('UnknownFieldType'),
          throwsInvalidGenerationSourceError(
              'Could not handle field `number`. It has an undefined type.',
              todo: 'Check names and imports.'));
    });
  });

  test('unsupported type', () {
    expect(
        runForElementNamed('UnsupportedFieldType'),
        throwsInvalidGenerationSourceError(
          'Could not handle field `number`. `Duration` is not supported.',
        ));
  });

  test('default values is not in allowed', () async {
    expect(
        runForElementNamed('DefaultNotInAllowed'),
        throwsInvalidGenerationSourceError('Could not handle field `option`. '
            'The `defaultsTo` value – `a` is not in `allowedValues`.'));
  });

  test('negating an option', () async {
    expect(
        runForElementNamed('NegatableOption'),
        throwsInvalidGenerationSourceError('Could not handle field `option`. '
            '`negatable` is only valid for flags – type `bool`.'));
  });

  test('negating a multi-option', () async {
    expect(
        runForElementNamed('NegatableMultiOption'),
        throwsInvalidGenerationSourceError('Could not handle field `options`. '
            '`negatable` is only valid for flags – type `bool`.'));
  });

  group('convert', () {
    test('cannot be a static method', () async {
      expect(
          runForElementNamed('ConvertAsStatic'),
          throwsInvalidGenerationSourceError('Could not handle field `option`. '
              'The function provided for `convert` must be top-level. '
              'Static class methods (like `_staticConvertStringToDuration`) are not supported.'));
    });

    test('must have the right return type', () async {
      expect(
          runForElementNamed('BadConvertReturn'),
          throwsInvalidGenerationSourceError('Could not handle field `option`. '
              'The convert function `_convertStringToDuration` return type '
              '`Duration` is not compatible with the field type `String`.'));
    });

    test('must have the right param type', () async {
      expect(
          runForElementNamed('BadConvertParam'),
          throwsInvalidGenerationSourceError('Could not handle field `option`. '
              'The convert function `_convertIntToString` must have one '
              'positional paramater of type `String`.'));
    });

    test('does not convert multi options', () async {
      expect(
          runForElementNamed('ConvertOnMulti'),
          throwsInvalidGenerationSourceError('Could not handle field `option`. '
              'The convert function `_convertStringToDuration` return type '
              '`Duration` is not compatible with the field type `List<Duration>`.'));
    });
  });

  group('flag', () {
    test('convert does not convert multi options', () async {
      expect(
          runForElementNamed('FlagWithStringDefault'),
          throwsInvalidGenerationSourceError(
            'Could not handle field `option`. '
                'The value for `defaultsTo` must be assignable to `bool`.',
          ));
    });
    test('convert does not convert multi options', () async {
      expect(
          runForElementNamed('FlagWithAllowed'),
          throwsInvalidGenerationSourceError('Could not handle field `option`. '
              '`allowed` is not supported for flags.'));
    });
    test('convert does not convert multi options', () async {
      expect(
          runForElementNamed('FlagWithAllowedHelp'),
          throwsInvalidGenerationSourceError('Could not handle field `option`. '
              '`allowedHelp` is not supported for flags.'));
    });
    test('convert does not convert multi options', () async {
      expect(
          runForElementNamed('FlagWithValueHelp'),
          throwsInvalidGenerationSourceError('Could not handle field `option`. '
              '`valueHelp` is not supported for flags.'));
    });
  });
}
