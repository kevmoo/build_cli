import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

import '../annotations.dart';
import 'to_share.dart';

final boolChecker = new TypeChecker.fromRuntime(bool);
final stringChecker = new TypeChecker.fromRuntime(String);
final _cliOptionChecker = new TypeChecker.fromRuntime(CliOption);

final _argInfoCache = new Expando<ArgInfo>();

enum ArgType { option, flag }

class ArgInfo {
  final CliOption optionData;
  final ArgType argType;

  ArgInfo(this.argType, this.optionData);

  static ArgInfo fromField(FieldElement element) {
    var info = _argInfoCache[element];
    if (info != null) {
      return info;
    }

    var type = _getArgType(element.type);
    var option = _getOptions(element);
    return _argInfoCache[element] = new ArgInfo(type, option);
  }
}

ArgType _getArgType(DartType targetType) {
  if (boolChecker.isExactlyType(targetType)) {
    return ArgType.flag;
  }

  if (stringChecker.isExactlyType(targetType)) {
    return ArgType.option;
  }

  if (isEnum(targetType)) {
    return ArgType.option;
  }

  throw new UnsupportedError('Cannot party on `$targetType`.');
}

CliOption _getOptions(FieldElement element) {
  var obj = _cliOptionChecker.firstAnnotationOfExact(element) ??
      _cliOptionChecker.firstAnnotationOfExact(element.getter);

  List<String> allowedValues;
  String defaultsTo;

  var annotation = new ConstantReader(obj);
  var defaultsToReader =
      annotation.isNull ? null : annotation?.read('defaultsTo');

  if (isEnum(element.type)) {
    var interfaceType = element.type as InterfaceType;

    allowedValues = interfaceType.accessors
        .where((p) => p.returnType == element.type)
        .map((p) => p.name)
        .toList();

    if (defaultsToReader != null && !defaultsToReader.isNull) {
      var objectValue = defaultsToReader.objectValue;
      if (objectValue.type != element.type) {
        throw new StateError('this is also wack');
      }

      var enumValueIndex = objectValue.getField('index').toIntValue();
      defaultsTo = allowedValues[enumValueIndex];
    }
  }

  if (annotation.isNull) {
    return new CliOption(allowed: allowedValues);
  }

  var allowedReader = annotation.read('allowed');
  if (!allowedReader.isNull) {
    allowedValues = allowedReader.listValue
        .map((o) => new ConstantReader(o).stringValue)
        .toList();
  }

  if (!defaultsToReader.isNull) {
    if (isEnum(element.type)) {} else if (defaultsToReader.isString) {
      defaultsTo = defaultsToReader.stringValue;
    } else {
      throw new StateError('What are you doing?');
    }
  }

  if (allowedValues != null &&
      defaultsTo != null &&
      !allowedValues.contains(defaultsTo)) {
    throw new StateError('Boo!');
  }

  return new CliOption(
      name: annotation.read('name').literalValue as String,
      abbr: annotation.read('abbr').literalValue as String,
      defaultsTo: defaultsTo,
      help: annotation.read('help').literalValue as String,
      allowed: allowedValues,
      negatable: annotation.read('negatable').literalValue as bool);
}
