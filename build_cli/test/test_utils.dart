// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:mirrors';

import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

String _packagePathCache;

String getPackagePath() {
  if (_packagePathCache == null) {
    // Getting the location of this file – via reflection
    var currentFilePath = (reflect(getPackagePath) as ClosureMirror)
        .function
        .location
        .sourceUri
        .path;

    _packagePathCache = p.normalize(p.join(p.dirname(currentFilePath), '..'));
  }
  return _packagePathCache;
}

Matcher invalidGenerationSourceErrorMatcher(messageMatcher, {todo}) =>
    const TypeMatcher<InvalidGenerationSourceError>()
        .having((e) => e.message, 'message', messageMatcher)
        .having((e) => e.todo, 'todo', todo ?? isEmpty)
        .having((e) => e.element, 'element', isNotNull);

Matcher throwsInvalidGenerationSourceError(messageMatcher, {todo}) =>
    throwsA(invalidGenerationSourceErrorMatcher(messageMatcher, todo: todo));
