// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/src/generated/engine.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';

Future<AnalysisContext> getAnalysisContextForProjectPath() async {
  final library = await resolveAsset(
      AssetId.parse('build_cli|test/src/test_input.dart'), (resolver) async {
    final allLibs = await resolver.libraries.toList();
    return allLibs.first;
  });

  return library.context;
}
