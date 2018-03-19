// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/resolver/inheritance_manager.dart'
    show InheritanceManager;
import 'package:analyzer/analyzer.dart';
import 'package:source_gen/source_gen.dart';

final _dartCoreObjectChecker = new TypeChecker.fromRuntime(Object);

bool isEnum(DartType targetType) =>
    targetType is InterfaceType && targetType.element.isEnum;

String commonNullPrefix(
        bool nullable, String expression, String unsafeExpression) =>
    nullable
        ? '$expression == null ? null : $unsafeExpression'
        : unsafeExpression;

// Copied from pkg/source_gen - lib/src/utils.
String friendlyNameForElement(Element element) {
  var friendlyName = element.displayName;

  if (friendlyName == null) {
    throw new ArgumentError(
        'Cannot get friendly name for $element - ${element.runtimeType}.');
  }

  var names = <String>[friendlyName];
  if (element is ClassElement) {
    names.insert(0, 'class');
    if (element.isAbstract) {
      names.insert(0, 'abstract');
    }
  }
  if (element is VariableElement) {
    names.insert(0, element.type.toString());

    if (element.isConst) {
      names.insert(0, 'const');
    }

    if (element.isFinal) {
      names.insert(0, 'final');
    }
  }
  if (element is LibraryElement) {
    names.insert(0, 'library');
  }

  return names.join(' ');
}

/// Returns a list of all instance, [FieldElement] items for [element] and
/// super classes.
List<FieldElement> listFields(ClassElement element) {
  // Get all of the fields that need to be assigned
  // TODO: support overriding the field set with an annotation option
  var fieldsList = element.fields.where((e) => !e.isStatic).toList();

  var manager = new InheritanceManager(element.library);

  for (var v in manager.getMembersInheritedFromClasses(element).values) {
    assert(v is! FieldElement);
    if (_dartCoreObjectChecker.isExactly(v.enclosingElement)) {
      continue;
    }

    if (v is PropertyAccessorElement && v.variable is FieldElement) {
      fieldsList.add(v.variable as FieldElement);
    }
  }

  var undefinedFields = fieldsList.where((fe) => fe.type.isUndefined).toList();
  if (undefinedFields.isNotEmpty) {
    var description =
        undefinedFields.map((fe) => '`${fe.displayName}`').join(', ');

    throw new InvalidGenerationSourceError(
        'At least one field has an invalid type: $description.',
        todo: 'Check names and imports.');
  }

  // Sort these in the order in which they appear in the class
  // Sadly, `classElement.fields` puts properties after fields
  fieldsList.sort(_sortByLocation);

  return fieldsList;
}

int _sortByLocation(FieldElement a, FieldElement b) {
  var checkerA = new TypeChecker.fromStatic(a.enclosingElement.type);

  if (!checkerA.isExactly(b.enclosingElement)) {
    // in this case, you want to prioritize the enclosingElement that is more
    // "super".

    if (checkerA.isSuperOf(b.enclosingElement)) {
      return -1;
    }

    var checkerB = new TypeChecker.fromStatic(b.enclosingElement.type);

    if (checkerB.isSuperOf(a.enclosingElement)) {
      return 1;
    }
  }

  /// Returns the offset of given field/property in its source file – with a
  /// preference for the getter if it's defined.
  int _offsetFor(FieldElement e) {
    if (e.getter != null && e.getter.nameOffset != e.nameOffset) {
      assert(e.nameOffset == -1);
      return e.getter.nameOffset;
    }
    return e.nameOffset;
  }

  return _offsetFor(a).compareTo(_offsetFor(b));
}

/// Returns the set of fields that are not written to via constructors.
Set<FieldElement> writeNewInstance(
    StringBuffer buffer,
    ClassElement classElement,
    Map<String, FieldElement> fields,
    String valueAccess(FieldElement field, {ParameterElement ctorParam})) {
  // creating a copy so it can be mutated
  var fieldsToSet = new Map<String, FieldElement>.from(fields);
  var className = classElement.displayName;
  // Create the factory method

  // Get the default constructor
  // TODO: allow overriding the ctor used for the factory
  var ctor = classElement.unnamedConstructor;
  if (ctor == null) {
    throw new UnsupportedError(
        'The class `${classElement.name}` has no default constructor.');
  }

  var ctorArguments = <ParameterElement>[];
  var ctorNamedArguments = <ParameterElement>[];

  for (var arg in ctor.parameters) {
    var field = fields[arg.name];

    if (field == null) {
      if (arg.parameterKind == ParameterKind.REQUIRED) {
        throw new UnsupportedError('Cannot populate the required constructor '
            'argument: ${arg.displayName}.');
      }
      continue;
    }

    // TODO: validate that the types match!
    if (arg.parameterKind == ParameterKind.NAMED) {
      ctorNamedArguments.add(arg);
    } else {
      ctorArguments.add(arg);
    }
    fieldsToSet.remove(arg.name);
  }

  var undefinedArgs = [ctorArguments, ctorNamedArguments]
      .expand((l) => l)
      .where((pe) => pe.type.isUndefined)
      .toList();
  if (undefinedArgs.isNotEmpty) {
    var description =
        undefinedArgs.map((fe) => '`${fe.displayName}`').join(', ');

    throw new InvalidGenerationSourceError(
        'At least one constructor argument has an invalid type: $description.',
        todo: 'Check names and imports.');
  }

  // these are fields to skip – now to find them
  var finalFields = fieldsToSet.values.where((field) => field.isFinal).toSet();

  for (var finalField in finalFields) {
    var value = fieldsToSet.remove(finalField.name);
    assert(value == finalField);
  }

  //
  // Generate the static factory method
  //
  buffer.write('new $className(');
  buffer.writeAll(
      ctorArguments.map((paramElement) =>
          valueAccess(fields[paramElement.name], ctorParam: paramElement)),
      ', ');
  if (ctorArguments.isNotEmpty && ctorNamedArguments.isNotEmpty) {
    buffer.write(', ');
  }
  buffer.writeAll(
      ctorNamedArguments.map((paramElement) =>
          '${paramElement.name}: ' +
          valueAccess(fields[paramElement.name], ctorParam: paramElement)),
      ', ');

  buffer.write(')');
  if (fieldsToSet.isEmpty) {
    buffer.writeln(';');
  } else {
    for (var field in fieldsToSet.values) {
      buffer.writeln();
      buffer.write('      ..${field.name} = ');
      buffer.write(valueAccess(field));
    }
    buffer.writeln(';');
  }
  buffer.writeln();

  return finalFields;
}
