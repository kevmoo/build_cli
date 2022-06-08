// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: lines_longer_than_80_chars

part of 'command_runner_example.dart';

// **************************************************************************
// CliGenerator
// **************************************************************************

CommitCommandOptions _$parseCommitCommandOptionsResult(ArgResults result) =>
    CommitCommandOptions(
      all: result['all'] as bool,
    );

ArgParser _$populateCommitCommandOptionsParser(ArgParser parser) => parser
  ..addFlag(
    'all',
    abbr: 'a',
  );

final _$parserForCommitCommandOptions =
    _$populateCommitCommandOptionsParser(ArgParser());

CommitCommandOptions parseCommitCommandOptions(List<String> args) {
  final result = _$parserForCommitCommandOptions.parse(args);
  return _$parseCommitCommandOptionsResult(result);
}

mixin _$CommitCommandOptionsForCliCommand on CliCommand<CommitCommandOptions> {
  @override
  void populateOptionsParser() =>
      _$populateCommitCommandOptionsParser(argParser);

  @override
  CommitCommandOptions parseOptionsResult(ArgResults result) =>
      _$parseCommitCommandOptionsResult(result);
}
