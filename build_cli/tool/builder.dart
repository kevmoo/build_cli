// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

LibraryBuilder _builder(_ReplaceGenerator generator) => LibraryBuilder(
      generator,
      generatedExtension: '.${generator.gName}.dart',
      formatOutput: (a) => a,
    );

Builder defaultOverride([_]) => _builder(_NonNullableGenerator());

abstract class _ReplaceGenerator extends Generator {
  final String gName;

  _ReplaceGenerator(this.gName);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final path = buildStep.inputId.path;
    final baseName = p.basenameWithoutExtension(path);

    final content = await buildStep.readAsString(buildStep.inputId);

    return _Replacement.generate(content, createReplacements(baseName));
  }

  Iterable<_Replacement> createReplacements(String baseName) sync* {
    yield _Replacement(
      "part '$baseName.g.dart",
      "part '$baseName.$gName.g.dart",
    );
  }
}

class _NonNullableGenerator extends _ReplaceGenerator {
  _NonNullableGenerator() : super('overrides');

  @override
  Iterable<_Replacement> createReplacements(String baseName) sync* {
    yield* super.createReplacements(baseName);

    yield _Replacement(
        '@CliOption(', '@CliOption(\n    provideDefaultToOverride: true,');
  }
}

class _Replacement {
  final Pattern existing;
  final String replacement;

  _Replacement(this.existing, this.replacement);

  static String generate(
      String inputContent, Iterable<_Replacement> replacements) {
    var outputContent = inputContent;

    for (final r in replacements) {
      if (!outputContent.contains(r.existing)) {
        throw StateError(
            'Input string did not contain `${r.existing}` as expected.');
      }
      outputContent = outputContent.replaceAll(r.existing, r.replacement);
    }

    return outputContent.replaceAll(',)', ',\n)');
  }
}
