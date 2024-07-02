import 'package:conduit_core/conduit_core.dart';
import 'package:data/models/Division.dart';
import 'package:data/models/Goods.dart';
import 'package:data/models/InventoryList.dart';

class Room extends ManagedObject<_Room> implements _Room {}

class _Room {
  @primaryKey
  int? idRoom;
  String? nameRoom;
  ManagedSet<InventoryList>? inventoryList;
  ManagedSet<Division>? divisionList;
  ManagedSet<Goods>? goodsList;
}
