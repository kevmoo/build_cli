// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/inheritance_manager3.dart' // ignore: implementation_imports
    show InheritanceManager3;
import 'package:source_gen/source_gen.dart';

Never throwBugFound(FieldElement2 element) => throwUnsupported(
  element,
  "You've hit a bug in build_cli!",
  todo:
      'Please rerun your build with --verbose and file as issue '
      'with the stace trace.',
);

Never throwUnsupported(FieldElement2 element, String message, {String? todo}) =>
    throw InvalidGenerationSourceError(
      'Could not handle field `${element.displayName}`. $message',
      element: element,
      todo: todo ?? '',
    );

/// Returns a [Set] of all instance [FieldElement] items for [element] and
/// super classes, sorted first by their location in the inheritance hierarchy
/// (super first) and then by their location in the source file.
Set<FieldElement2> createSortedFieldSet(InstanceElement2 element) {
  // Get all of the fields that need to be assigned
  // TODO: support overriding the field set with an annotation option
  final fieldsList = element.fields2.where((e) => !e.isStatic).toList();

  final manager = InheritanceManager3();

  for (var v in manager.getInheritedMap(element as InterfaceElement2).values) {
    assert(v is! FieldElement2);
    if (dartCoreObjectChecker.isExactly(v.enclosingElement2!)) {
      continue;
    }

    if (v is PropertyAccessorElement2 && v.baseElement is FieldElement2) {
      fieldsList.add(v.baseElement as FieldElement2);
    }
  }

  // Sort these in the order in which they appear in the class
  // Sadly, `classElement.fields` puts properties after fields
  fieldsList.sort(_sortByLocation);

  return fieldsList.toSet();
}

int _sortByLocation(FieldElement2 a, FieldElement2 b) {
  final checkerA = TypeChecker.fromStatic(a.enclosingElement2.thisType);

  if (!checkerA.isExactly(b.enclosingElement2)) {
    // in this case, you want to prioritize the enclosingElement that is more
    // "super".

    if (checkerA.isAssignableFrom(b.enclosingElement2)) {
      return -1;
    }

    final checkerB = TypeChecker.fromStatic(b.enclosingElement2.thisType);

    if (checkerB.isAssignableFrom(a.enclosingElement2)) {
      return 1;
    }
  }

  /// Returns the offset of given field/property in its source file – with a
  /// preference for the getter if it's defined.
  int offsetFor(FieldElement2 e) {
    if (e.isSynthetic) {
      return (e.getter2 ?? e.setter2)!.firstFragment.nameOffset2 ?? 0;
    }
    return e.firstFragment.nameOffset2 ?? 0;
  }

  return offsetFor(a).compareTo(offsetFor(b));
}

const dartCoreObjectChecker = TypeChecker.fromUrl('dart:core#Object');

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
  ClassElement2 classElement,
  Iterable<String> availableConstructorParameters,
  Iterable<String> writeableFields,
  Map<String, String> unavailableReasons,
  String Function(String paramOrFieldName, {FormalParameterElement ctorParam})
  deserializeForField,
) {
  final className = classElement.displayName;

  var ctor = classElement.unnamedConstructor2;
  if (ctor == null) {
    if (classElement.constructors2.length == 1) {
      ctor = classElement.constructors2.single;
    } else {
      // TODO: allow specifying the target constructor
      throw InvalidGenerationSourceError(
        'Could not pick a constructor to use.',
        element: classElement,
      );
    }
  }

  final usedCtorParamsAndFields = <String>{};
  final constructorArguments = <FormalParameterElement>[];
  final namedConstructorArguments = <FormalParameterElement>[];

  for (var arg in ctor.formalParameters) {
    if (!availableConstructorParameters.contains(arg.name3)) {
      if (arg.isPositional) {
        var msg =
            'Cannot populate the required constructor '
            'argument: ${arg.displayName}.';

        final additionalInfo = unavailableReasons[arg.name3];

        if (additionalInfo != null) {
          msg = '$msg $additionalInfo';
        }

        throw InvalidGenerationSourceError(msg, element: ctor);
      }

      continue;
    }

    // TODO: validate that the types match!
    if (arg.isNamed) {
      namedConstructorArguments.add(arg);
    } else {
      constructorArguments.add(arg);
    }
    usedCtorParamsAndFields.add(arg.name3!);
  }

  // fields that aren't already set by the constructor and that aren't final
  final remainingFieldsForInvocationBody = writeableFields.toSet().difference(
    usedCtorParamsAndFields,
  );

  final ctorNameRaw = ctor.name3!;

  final ctorName =
      ctorNameRaw.isEmpty || ctorNameRaw == 'new' ? '' : '.$ctorNameRaw';

  //
  // Generate the static factory method
  //
  buffer
    ..write('$className$ctorName(')
    ..writeAll(
      constructorArguments.map(
        (e) => '${deserializeForField(e.name3!, ctorParam: e)},',
      ),
    )
    ..writeAll(
      namedConstructorArguments.map((paramElement) {
        final value = deserializeForField(
          paramElement.name3!,
          ctorParam: paramElement,
        );
        return '${paramElement.name3}: $value,';
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

extension DartTypeExtension on DartType {
  String toStringNonNullable() {
    final val = getDisplayString();
    if (val.endsWith('?')) return val.substring(0, val.length - 1);
    return val;
  }
}

extension ElementExtension on Element {
  String toStringNonNullable() {
    final val = displayString();
    if (val.endsWith('?')) return val.substring(0, val.length - 1);
    return val;
  }
}
