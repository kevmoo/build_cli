// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_helper/source_helper.dart';

Never throwBugFound(FieldElement element) => throwUnsupported(
  element,
  "You've hit a bug in build_cli!",
  todo:
      'Please rerun your build with --verbose and file as issue '
      'with the stace trace.',
);

Never throwUnsupported(FieldElement element, String message, {String? todo}) =>
    throw InvalidGenerationSourceError(
      'Could not handle field `${element.displayName}`. $message',
      element: element,
      todo: todo ?? '',
    );

/// Writes the invocation of the default constructor – `new Class(...)` for the
/// type defined in [classElement] to the provided [buffer].
///
/// If an parameter is required to invoke the constructor,
/// [availableConstructorParameters] is checked to see if it is available. If
/// [availableConstructorParameters] does not contain the parameter name,
/// an [UnsupportedError] is thrown.
///
/// To improve the error details, [unavailableReasons] is checked for the
/// unavailable constructor parameter. If the value is not `null`, it is
/// included in the [UnsupportedError] message.
///
/// [writeableFields] are also populated, but only if they have not already
/// been defined by a constructor parameter with the same name.
///
/// Set set of all constructor parameters and and fields that are populated is
/// returned.
Set<String> writeConstructorInvocation(
  StringBuffer buffer,
  ClassElement classElement,
  Iterable<String> availableConstructorParameters,
  Iterable<String> writeableFields,
  Map<String, String> unavailableReasons,
  String Function(String paramOrFieldName, {FormalParameterElement ctorParam})
  deserializeForField,
) {
  final ctor = _selectConstructor(classElement);
  final plan = planConstruction(ctor, availableConstructorParameters.toSet());
  final unpopulated = plan.unmatched
      .where((arg) => arg.isRequired || arg.isPositional)
      .firstOrNull;
  if (unpopulated != null) {
    var msg =
        'Cannot populate the required constructor '
        'argument: ${unpopulated.displayName}.';
    final additionalInfo = unavailableReasons[unpopulated.name];
    if (additionalInfo != null) {
      msg = '$msg $additionalInfo';
    }
    throw InvalidGenerationSourceError(msg, element: ctor);
  }

  final usedCtorParamsAndFields = {...plan.consumedNames};

  // fields that aren't already set by the constructor and that aren't final
  final remainingFieldsForInvocationBody = writeableFields.toSet().difference(
    usedCtorParamsAndFields,
  );

  //
  // Generate the static factory method
  //
  buffer
    ..write('${ctor.qualifiedName}(')
    ..writeAll(
      plan.positional.map(
        (e) => '${deserializeForField(e.name!, ctorParam: e)},',
      ),
    )
    ..writeAll(
      plan.named.map((paramElement) {
        final value = deserializeForField(
          paramElement.name!,
          ctorParam: paramElement,
        );
        return '${paramElement.name}: $value,';
      }),
    )
    ..write(')');
  if (remainingFieldsForInvocationBody.isEmpty) {
    buffer.writeln(';');
  } else {
    for (var field in remainingFieldsForInvocationBody) {
      buffer
        ..writeln()
        ..write('      ..$field = ')
        ..write(deserializeForField(field));
      usedCtorParamsAndFields.add(field);
    }
    buffer.writeln(';');
  }
  buffer.writeln();

  return usedCtorParamsAndFields;
}

ConstructorElement _selectConstructor(ClassElement classElement) {
  try {
    return constructorByName(classElement, '');
  } on InvalidGenerationSourceError {
    if (classElement.constructors.length == 1) {
      return classElement.constructors.single;
    }
    throw InvalidGenerationSourceError(
      'Could not pick a constructor to use.',
      element: classElement,
    );
  }
}
