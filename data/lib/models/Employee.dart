import 'package:conduit_core/conduit_core.dart';
import 'package:data/models/Division.dart';
import 'package:data/models/Goods.dart';
import 'package:data/models/InventoryList.dart';
import 'package:data/models/InventoryRecord.dart';

class Employee extends ManagedObject<_Employee> implements _Employee {}

class _Employee {
  @primaryKey
  int? id;
  @Column(nullable: true, indexed: true)
  String? fullName;
  ManagedSet<InventoryList>? inventoryList;
  ManagedSet<InventoryRecord>? inventoryRecordList;
  ManagedSet<Goods>? goodsList;
  @Relate(#employeeList, isRequired: true, onDelete: DeleteRule.cascade)
  Division? division; // Подразделение
}
