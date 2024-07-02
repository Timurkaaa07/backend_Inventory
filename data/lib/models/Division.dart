import 'package:conduit_core/conduit_core.dart';
import 'package:data/models/Employee.dart';
import 'package:data/models/room.dart';

class Division extends ManagedObject<_Division> implements _Division {}

class _Division {
  @primaryKey
  int? id;
  String? nameDivision;
  ManagedSet<Employee>? employeeList;
  @Relate(#divisionList, isRequired: true, onDelete: DeleteRule.cascade)
  Room? room; // Помещение
}
