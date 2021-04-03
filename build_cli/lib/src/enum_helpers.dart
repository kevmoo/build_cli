import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_helper/source_helper.dart';

import 'util.dart';

String? enumValueMapFromType(DartType targetType) {
  final enumMap = _enumFieldsMap(targetType);

  if (enumMap == null) {
    return null;
  }

  final items =
      enumMap.entries.map((e) => '  ${targetType.element!.name}.${e.key.name}: '
          '${escapeDartString(kebab(e.value))}');

  return 'const ${enumConstMapName(targetType)} = '
      '<${targetType.element!.name}, String>{\n${items.join(',\n')}\n};';
}

String enumConstMapName(DartType targetType) =>
    '_\$${targetType.element!.name}EnumMapBuildCli';

/// If [targetType] is not an enum, `null` is returned.
Map<FieldElement, String>? _enumFieldsMap(DartType targetType) {
  if (targetType is InterfaceType && targetType.element.isEnum) {
    return Map<FieldElement, String>.fromEntries(targetType.element.fields
        .where((p) => !p.isSynthetic)
        .map((p) => MapEntry(p, p.name)));
  }
  return null;
}

const enumValueHelperFunctionName = r'_$enumValueHelper';

const enumValueHelper = '''
T $enumValueHelperFunctionName<T>(Map<T, String> enumValues, String source) =>
 enumValues
    .entries
    .singleWhere((e) => e.value == source,
        orElse: () => throw ArgumentError(
            '`\$source` is not one of the supported values: '
            '\${enumValues.values.join(', ')}'))
    .key;
''';

const nullableEnumValueHelperFunctionName =
    r'_$nullableEnumValueHelperNullable';

const nullableEnumValueHelper = '''
T? $nullableEnumValueHelperFunctionName<T>(Map<T, String> enumValues, String? source) =>
  source == null ? null : $enumValueHelperFunctionName(enumValues, source);
''';
