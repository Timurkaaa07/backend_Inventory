import 'dart:io';
import 'package:data/utils/app_response.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:conduit/conduit.dart';
import 'package:data/utils/app_utils.dart';
import 'package:data/models/room.dart';
import 'package:data/models/Division.dart';
import 'package:data/models/Employee.dart';
import 'package:data/models/Goods.dart';
import 'package:data/models/InventoryList.dart';
import 'package:data/models/InventoryRecord.dart';

class AppGoodsBarcodeController extends ResourceController {
  final ManagedContext managedContext;
  AppGoodsBarcodeController(this.managedContext);

  @Operation.get('inventorynumbergoods')
  Future<Response> scanBarcode(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path('inventorynumbergoods') int inventorynumbergoods
  ) async {
    try {
      final currentEmployeeId = AppUtils.getIdFromHeader(header);
      final employee = await managedContext.fetchObjectWithID<Employee>(currentEmployeeId);
      if (employee == null) {
        return AppResponse.badRequest(message: "Сотрудник не найден");
      }

      // final qGetGoods = Query<Goods>(managedContext)
      //   ..where((x) => x.inventoryNumberGoods).equalTo(inventorynumbergoods);
      // final goods = await qGetGoods.fetchOne();
      // if (goods == null) {
      //   return AppResponse.ok(message: "Товар по данному инвентарному номеру не найден");
      // }

      // // Создание инвентарной записи
      // final qCreateInventRecord = Query<InventoryRecord>(managedContext)
      //   ..values.inventRecord = DateTime.now()
      //   ..values.statusIR = "Сканировано"
      //   ..values.employee = employee
      //   ..values.inventoryList?.id = 1 
      //   ..values.goodsList = goods;
      // final createdRecord = await qCreateInventRecord.insert();

      final query = '''
              SELECT G.id, G.inventorynumbergoods, G.namegoods, G.conditionGoods, R.nameroom, E.fullName
              FROM _goods G
              INNER JOIN _employee E ON G.employee_id = E.id
              INNER JOIN _room R ON G.room_idroom = R.idroom
              WHERE G.inventorynumbergoods = @inventorynumbergoods
          ''';
      final result = await managedContext.persistentStore.execute(
        query,
        substitutionValues: {"inventorynumbergoods": inventorynumbergoods},
      );
      if (result.isEmpty) {
        return AppResponse.ok(message: "Товар по данному инвентарному номеру не найден");
      }

      return AppResponse.ok(body: result, message: "Успешное сканирование штрихкода");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка при сканировании штрихкода и создании инвентарной записи");
    }
  }
}
