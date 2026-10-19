// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

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

/// Returns a [Set] of all instance [FieldElement] items for [element] and
/// super classes, sorted first by their location in the inheritance hierarchy
/// (super first) and then by their location in the source file.
Set<FieldElement> createSortedFieldSet(InstanceElement element) {
  // Get all of the fields that need to be assigned
  // TODO: support overriding the field set with an annotation option
  final fieldsList = element.fields
      .where((e) => !e.isStatic)
      .cast<FieldElement>()
      .toList();

  for (var v in (element as InterfaceElement).inheritedMembers.values) {
    assert(v is! FieldElement);
    if (dartCoreObjectChecker.isExactly(v.enclosingElement!)) {
      continue;
    }

    if (v case PropertyAccessorElement(:final FieldElement variable)) {
      fieldsList.add(variable);
    }
  }

  // Sort these in the order in which they appear in the class
  // Sadly, `classElement.fields` puts properties after fields
  fieldsList.sort(_sortByLocation);

  return fieldsList.toSet();
}

int _sortByLocation(FieldElement a, FieldElement b) {
  final checkerA = TypeChecker.fromStatic(a.enclosingElement.thisType);

  if (!checkerA.isExactly(b.enclosingElement)) {
    // in this case, you want to prioritize the enclosingElement that is more
    // "super".

    if (checkerA.isAssignableFrom(b.enclosingElement)) {
      return -1;
    }

    final checkerB = TypeChecker.fromStatic(b.enclosingElement.thisType);

    if (checkerB.isAssignableFrom(a.enclosingElement)) {
      return 1;
    }
  }

  /// Returns the offset of given field/property in its source file – with a
  /// preference for the getter if it's defined.
  int offsetFor(FieldElement e) {
    if (!e.isOriginDeclaration) {
      return (e.getter ?? e.setter)!.firstFragment.nameOffset ?? 0;
    }
    return e.firstFragment.nameOffset ?? 0;
  }

  return offsetFor(a).compareTo(offsetFor(b));
}

const dartCoreObjectChecker = TypeChecker.typeNamed(
  Object,
  inPackage: 'core',
  inSdk: true,
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
  final className = classElement.displayName;
  final ctor = _selectConstructor(classElement);
  final resolvedParams = _resolveConstructorParams(
    ctor,
    availableConstructorParameters,
    unavailableReasons,
  );
  final usedCtorParamsAndFields = resolvedParams.used;

  // fields that aren't already set by the constructor and that aren't final
  final remainingFieldsForInvocationBody = writeableFields.toSet().difference(
    usedCtorParamsAndFields,
  );

  final ctorName = switch (ctor.name!) {
    '' || 'new' => '',
    final name => '.$name',
  };

  //
  // Generate the static factory method
  //
  buffer
    ..write('$className$ctorName(')
    ..writeAll(
      resolvedParams.positional.map(
        (e) => '${deserializeForField(e.name!, ctorParam: e)},',
      ),
    )
    ..writeAll(
      resolvedParams.named.map((paramElement) {
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
  final unnamed = classElement.unnamedConstructor;
  if (unnamed != null) {
    return unnamed;
  }
  if (classElement.constructors.length == 1) {
    return classElement.constructors.single;
  }
  throw InvalidGenerationSourceError(
    'Could not pick a constructor to use.',
    element: classElement,
  );
}

({
  List<FormalParameterElement> positional,
  List<FormalParameterElement> named,
  Set<String> used,
})
_resolveConstructorParams(
  ConstructorElement ctor,
  Iterable<String> availableConstructorParameters,
  Map<String, String> unavailableReasons,
) {
  final used = <String>{};
  final positional = <FormalParameterElement>[];
  final named = <FormalParameterElement>[];

  for (var arg in ctor.formalParameters) {
    if (!availableConstructorParameters.contains(arg.name)) {
      if (arg.isRequired || arg.isPositional) {
        var msg =
            'Cannot populate the required constructor '
            'argument: ${arg.displayName}.';
        final additionalInfo = unavailableReasons[arg.name];
        if (additionalInfo != null) {
          msg = '$msg $additionalInfo';
        }
        throw InvalidGenerationSourceError(msg, element: ctor);
      }
      continue;
    }

    if (arg.isNamed) {
      named.add(arg);
    } else {
      positional.add(arg);
    }
    used.add(arg.name!);
  }

  return (positional: positional, named: named, used: used);
}

extension DartTypeExtension on DartType {
  String toStringNonNullable() {
    final val = getDisplayString();
    if (val.endsWith('?')) return val.substring(0, val.length - 1);
    return val;
  }
}
