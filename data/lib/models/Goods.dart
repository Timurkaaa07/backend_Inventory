import 'package:conduit_core/conduit_core.dart';
import 'package:data/models/Employee.dart';
import 'package:data/models/InventoryRecord.dart';
import 'package:data/models/room.dart';
import 'package:data/models/author.dart';

class Goods extends ManagedObject<_Goods> implements _Goods {}

class _Goods {
  @primaryKey
  int? id;
  int? inventoryNumberGoods;
  String? nameGoods;
  String? groupGoods;
  DateTime? dateStart;
  double? firstCost;
  double? residualCost;
  String? conditionGoods;
  ManagedSet<InventoryRecord>? inventoryRecordList;
  @Relate(#goodsList, onDelete: DeleteRule.cascade)
  Employee? employee;
  @Relate(#goodsList, onDelete: DeleteRule.cascade)
  Room? room;
}
