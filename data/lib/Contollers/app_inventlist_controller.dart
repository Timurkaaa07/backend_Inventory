import 'dart:io';

import 'package:data/utils/app_response.dart';
import 'package:data/models/author.dart';
import 'package:data/models/post.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:data/utils/app_utils.dart';
import 'package:data/models/room.dart';
import 'package:data/models/Division.dart';
import 'package:data/models/Employee.dart';
import 'package:data/models/Goods.dart';
import 'package:data/models/InventoryList.dart';
import 'package:data/models/InventoryRecord.dart';
// Инвентарная ведомость
class AppInventListContoller extends ResourceController {
    final ManagedContext managedContext;
    AppInventListContoller(this.managedContext);

    
  @Operation.get("id")
  Future<Response> getGood(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentEmployeeId = AppUtils.getIdFromHeader(header);
      // У поста есть айди, и мы сравниваем с айди который получаем в запросе
      // Вернуть пост, если он принадлежит пользователю
      final qGetGood = Query<Goods>(managedContext)
      ..where((x) => x.id).equalTo(id)
      ..where((x) => x.employee?.id).equalTo(currentEmployeeId)
      ..returningProperties((x) => [
        x.inventoryNumberGoods , x.nameGoods, x.groupGoods, x.conditionGoods, x.firstCost,
      ]);
      final good = await qGetGood.fetchOne();

      if (good == null) {
        return AppResponse.ok(message: "ОС не найдено");
      }
      
      return AppResponse.ok(
          body: good.backing.contents, message: "Успешное получение ОС");
    } catch (error) {
        return AppResponse.serverError(error, message: "Ошибка получение ОС");
    }
  }

  @Operation.get()
  Future<Response> getInventList(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final currentEmployeeId = AppUtils.getIdFromHeader(header);
      final employee = await managedContext.fetchObjectWithID<Employee>(currentEmployeeId);
      if (employee == null) {
        return AppResponse.badRequest(message: "Сотрудник не найден");
      }
      final query = '''
            SELECT IL.codeorderil, E1.fullName as "Комиссия",
                R.idRoom, G.namegoods, G.id,
                G.inventorynumbergoods, E2.fullName as "Мол",
                IR.statusYes
            FROM _InventoryList IL 
	            INNER JOIN _Employee E1
		            ON IL.employee_id = E1.id
	            INNER JOIN _Room R
		            ON IL.room_idRoom = R.idRoom
	            INNER JOIN _Goods G
		            ON G.room_idRoom = R.idRoom		
	            INNER JOIN _Employee E2
		            ON G.employee_id = E2.id
	            FULL JOIN _InventoryRecord IR
		            ON IR.goodslist_id = G.id
            WHERE E1.id = @currentEmployeeId
          ''';
      final result = await managedContext.persistentStore.execute(
        query,
        substitutionValues: {"currentEmployeeId": currentEmployeeId},
      );
      if (result.isEmpty) {
        return AppResponse.ok(message: "Инвентарной ведомости не найдено");
      }

      return AppResponse.ok(body: result, message: "Успешное получение ведомости");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка");
    }
  }




    
    
    @Operation.post()
    Future<Response> createInventList(
        @Bind.header(HttpHeaders.authorizationHeader) String header,
        @Bind.body() InventoryList inventList) async {
            try {
                final id = AppUtils.getIdFromHeader(header);
                final employee = await managedContext.fetchObjectWithID<Employee>(id);
                final qCreateInventList = Query<InventoryList>(managedContext)
                ..values.codeOrderIL = inventList.codeOrderIL
                ..values.dateIL = DateTime.now()
                ..values.dateStart = inventList.dateStart
                ..values.dateEnd = inventList.dateEnd
                ..values.room?.idRoom = inventList.room?.idRoom
                ..values.employee?.id = inventList.employee?.id;
                await qCreateInventList.insert();
                return AppResponse.ok(message: "Успешное создание инвентарной ведомости");
    }       catch (error) {
                return AppResponse.serverError(error, message: "Ошибка создания инвентарной ведомости");
    }
        }

}