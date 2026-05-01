import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_helper/source_helper.dart';

String enumValueMapFromType(DartType targetType) {
  final enumMap = _enumFieldsMap(targetType);

  final items = enumMap.entries.map(
    (e) =>
        '  ${targetType.element!.name}.${e.key.name}: '
        '${escapeDartString(e.value.kebab)}',
  );

  return 'const ${enumConstMapName(targetType)} = '
      '<${targetType.element!.name}, String>{\n${items.join(',\n')}\n};';
}

String enumConstMapName(DartType targetType) =>
    '_\$${targetType.element!.name}EnumMapBuildCli';

Map<FieldElement, String> _enumFieldsMap(DartType targetType) {
  final element = targetType.element as EnumElement;
  return {for (final p in element.constants) p: p.name!};
}

const enumValueHelperFunctionName = r'_$enumValueHelper';

const enumValueHelper =
    '''
T $enumValueHelperFunctionName<T>(Map<T, String> enumValues, String source) =>
 enumValues
    .entries
    .singleWhere((e) => e.value == source,
        orElse: () => throw ArgumentError(
            '`\$source` is not one of the supported values: '
            '\${enumValues.values.join(', ')}',),)
    .key;
''';

const nullableEnumValueHelperFunctionName =
    r'_$nullableEnumValueHelperNullable';

const nullableEnumValueHelper =
    '''
T? $nullableEnumValueHelperFunctionName<T>(
  Map<T, String> enumValues,
  String? source,
) =>
  source == null ? null : $enumValueHelperFunctionName(enumValues, source);
''';
