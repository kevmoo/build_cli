// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:build/build.dart';
import 'package:logging/logging.dart';

import 'src/part_builder.dart';

final _logger = new Logger('json_serializable');

Builder cliBuilder(BuilderOptions options) {
  var setOptions = new Map<String, dynamic>.from(options.config);

  dynamic read(String key) => setOptions.remove(key);

  try {
    return cliPartBuilder(header: read('header') as String);
  } finally {
    if (setOptions.isNotEmpty) {
      _logger.warning('These options were ignored: `$setOptions`.');
    }
  }
}
