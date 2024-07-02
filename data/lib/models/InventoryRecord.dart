import 'package:conduit_core/conduit_core.dart';
import 'package:data/models/Employee.dart';
import 'package:data/models/Goods.dart';
import 'package:data/models/InventoryList.dart';


// Инвентарная запись
class InventoryRecord extends ManagedObject<_InventoryRecord>
    implements _InventoryRecord {}

class _InventoryRecord {
  @primaryKey
  int? id;
  DateTime? inventRecord; // Дата создания
  @Column(nullable: true, indexed: true)
  String? statusIR;
  @Column(nullable: true, indexed: true)
  String? statusYes;
  @Relate(#inventoryRecordList, isRequired: true, onDelete: DeleteRule.cascade)
  Employee? employee;
  @Relate(#inventoryRecordList, isRequired: true, onDelete: DeleteRule.cascade)
  InventoryList? inventoryList;
  @Relate(#inventoryRecordList, isRequired: true, onDelete: DeleteRule.cascade)
  Goods? goodsList;
}
