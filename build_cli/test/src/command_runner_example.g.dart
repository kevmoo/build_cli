// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars, require_trailing_commas

part of 'command_runner_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

CommitOptions _$parseCommitOptionsResult(ArgResults result) =>
    CommitOptions(all: result['all'] as bool);

ArgParser _$populateCommitOptionsParser(ArgParser parser) =>
    parser..addFlag('all', abbr: 'a');

final _$parserForCommitOptions = _$populateCommitOptionsParser(ArgParser());

CommitOptions parseCommitOptions(List<String> args) {
  final result = _$parserForCommitOptions.parse(args);
  return _$parseCommitOptionsResult(result);
}

abstract class _$CommitOptionsCommand<T> extends Command<T> {
  _$CommitOptionsCommand() {
    _$populateCommitOptionsParser(argParser);
  }

  late final _options = _$parseCommitOptionsResult(argResults!);
}
