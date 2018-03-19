// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// https://github.com/dart-lang/sdk/issues/31761
// ignore_for_file: comment_references

// Until `requireLibraryDirective` is removed
// ignore_for_file: deprecated_member_use

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'build_cli_generator.dart';

Builder cliPartBuilder(
    {String header,
    @Deprecated(
        'Library directives are no longer required for part generation. '
        'This option will be removed in v0.4.0.')
        bool requireLibraryDirective: false}) {
  requireLibraryDirective ??= false;
  return new PartBuilder(const [
    const CliGenerator(),
  ],
      header: header,
      // ignore: deprecated_member_use
      requireLibraryDirective: requireLibraryDirective);
}
