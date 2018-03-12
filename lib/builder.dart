// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:build/build.dart';

import 'src/part_builder.dart';

Builder cliBuilder(BuilderOptions options) => cliPartBuilder(
    header: options.config['header'] as String,
    // ignore: deprecated_member_use
    requireLibraryDirective:
        options.config['require_library_directive'] as bool ?? false);
