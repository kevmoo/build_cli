// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:mirrors';

import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

/// Return the path to the current Dart SDK.
String getSdkPath() => p.dirname(p.dirname(Platform.resolvedExecutable));

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

Matcher throwsInvalidGenerationSourceError(messageMatcher, todoMatcher) =>
    throwsA(allOf(
        const isInstanceOf<InvalidGenerationSourceError>(),
        new FeatureMatcher<InvalidGenerationSourceError>(
            'message', (e) => e.message, messageMatcher),
        new FeatureMatcher<InvalidGenerationSourceError>(
            'todo', (e) => e.todo, todoMatcher),
        new FeatureMatcher<InvalidGenerationSourceError>(
            'element', (e) => e.element, isNotNull)));

// TODO(kevmoo) add this to pkg/matcher – is nice!
class FeatureMatcher<T> extends CustomMatcher {
  final dynamic Function(T value) _feature;

  FeatureMatcher(String name, this._feature, matcher)
      : super('`$name`', '`$name`', matcher);

  @override
  featureValueOf(covariant T actual) => _feature(actual);
}

bool pathToDartFile(String path) => p.extension(path) == '.dart';

/// Skips symbolic links and any item in [directoryPath] recursively that begins
/// with `.`.
///
/// [searchList] is a list of relative paths within [directoryPath].
/// Returned results will be those files that match file paths or are within
/// directories defined in the list.
@deprecated
Future<List<String>> getDartFiles(String directoryPath,
        {List<String> searchList, bool followLinks: false}) =>
    _getFiles(directoryPath, searchList: searchList, followLinks: followLinks)
        .where(pathToDartFile)
        .toList();

/// Skips symbolic links and any item in [directoryPath] recursively that begins
/// with `.`.
///
/// [searchList] is a list of relative paths within [directoryPath].
/// Returned results will be those files that match file paths or are within
/// directories defined in the list.
Stream<String> _getFiles(String directoryPath,
    {List<String> searchList, bool followLinks: false}) async* {
  searchList ??= <String>[];

  var map = await _expandSearchList(directoryPath, searchList);
  var searchDirs = <String>[];

  for (var path in map.keys) {
    var type = map[path];

    if (type == FileSystemEntityType.FILE) {
      yield path;
    } else {
      searchDirs.add(path);
    }
  }

  for (var path in searchDirs) {
    var rootDir = new Directory(path);

    yield* _populateFiles(rootDir, followLinks: followLinks);
  }
}

Future<Map<String, FileSystemEntityType>> _expandSearchList(
    String basePath, List<String> searchList) async {
  List<String> searchPaths;

  if (searchList.isEmpty) {
    searchPaths = <String>[basePath];
  } else {
    searchPaths = searchList.map((path) => p.join(basePath, path)).toList();
  }

  var items = <String, FileSystemEntityType>{};

  for (var path in searchPaths) {
    var type = await FileSystemEntity.type(path);

    if (type != FileSystemEntityType.FILE &&
        type != FileSystemEntityType.DIRECTORY) {
      continue;
    }

    /// If there is overlap with the provided paths, just fail.
    /// For instance, providing x and x/y or x/z.dart is a failure
    items.forEach((ePath, eType) {
      // if a file or a directory, check to see if it's a child of ePath - dir
      if (eType == FileSystemEntityType.DIRECTORY) {
        if (p.isWithin(ePath, path)) {
          throw new ArgumentError(
              'Redundant entry: "$path" is within "$ePath"');
        }
      }

      if (type == FileSystemEntityType.DIRECTORY) {
        // check to see if existing items are in this directory
        if (p.isWithin(path, ePath)) {
          throw new ArgumentError(
              'Redundant entry: "$ePath" is within "$path"');
        }
      }
    });

    items[path] = type;
  }

  return items;
}

Stream<String> _populateFiles(Directory directory,
    {bool followLinks: false}) async* {
  await for (var fse
      in directory.list(recursive: false, followLinks: followLinks)) {
    if (p.basename(fse.path).startsWith('.')) {
      continue;
    }

    if (fse is File) {
      yield fse.path;
    } else if (fse is Directory) {
      yield* _populateFiles(fse, followLinks: followLinks);
    }
  }
}
