import 'package:conduit_core/conduit_core.dart';
import 'package:data/models/Employee.dart';
import 'package:data/models/InventoryRecord.dart';
import 'package:data/models/room.dart';

class InventoryList extends ManagedObject<_InventoryList>
    implements _InventoryList {}
// Инвентарная ведомость
class _InventoryList {
  @primaryKey
  int? id; // номер ИВ
  int? codeOrderIL; // код приказа
  @Column(nullable: true, indexed: true)
  DateTime? dateStart; // Период начала
  @Column(nullable: true, indexed: true)
  DateTime? dateEnd; // Период окончания
  DateTime? dateIL; // ДатаСоздания
  @Relate(#inventoryList, isRequired: true, onDelete: DeleteRule.cascade)
  Room? room; // Помещение
  @Relate(#inventoryList, isRequired: true, onDelete: DeleteRule.cascade)
  Employee? employee;
  ManagedSet<InventoryRecord>? inventoryRecordList;
}
