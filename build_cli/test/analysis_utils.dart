// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';

Future<LibraryReader> libReaderForContent(String content) async {
  final fileMap = {'a|lib/test_input.dart': content};

  final library = await resolveSources(fileMap, (resolver) async {
    final assetId = AssetId.parse('a|lib/test_input.dart');
    final lib = await resolver.libraryFor(assetId);
    return lib;
  });

  return LibraryReader(library);
}
