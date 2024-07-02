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


class AppGoodsContoller extends ResourceController {
  final ManagedContext managedContext;

  AppGoodsContoller(this.managedContext);

  @Operation.post()
  Future<Response> createGoods(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Goods goods,) async {

        if (goods.inventoryNumberGoods == null)
        {
            return AppResponse.badRequest(message: "Поле инвентарный номер ОС обязательно");
        }

        if (goods.nameGoods == null || goods.nameGoods?.isEmpty == true)
        {
            return AppResponse.badRequest(message: "Поле название ОС обязательно");
        }

        if (goods.groupGoods == null || goods.groupGoods?.isEmpty == true)
        {
            return AppResponse.badRequest(message: "Поле группа ОС обязательно");
        }

        if (goods.conditionGoods == null || goods.conditionGoods?.isEmpty == true)
        {
            return AppResponse.badRequest(message: "Поле состояние ОС обязательно");
        }

        try {
            final id = AppUtils.getIdFromHeader(header);
            final employe = await managedContext.fetchObjectWithID<Employee>(id);
            if (employe == null) {
                final qCreateEmployee = Query<Employee>(managedContext)..values.id = id;
                await qCreateEmployee.insert();
      }
            final qCreateGood = Query<Goods>(managedContext)
                ..values.inventoryNumberGoods = goods.inventoryNumberGoods
                ..values.nameGoods = goods.nameGoods
                ..values.groupGoods = goods.groupGoods
                ..values.dateStart = DateTime.now()
                ..values.firstCost = goods.firstCost
                ..values.residualCost = goods.residualCost
                ..values.conditionGoods = goods.conditionGoods
                // ..values.employee?.id = id
                ..values.employee?.id = goods.employee?.id
                ..values.room?.idRoom = goods.room?.idRoom;
            await qCreateGood.insert();
            return AppResponse.ok(message: "Успешное создание ОС");
        }
        catch(error) {
            return AppResponse.serverError(error, message: "Ошибка создания ОС");   
        }     
    }

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
  Future<Response> getGoods(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetGoods = Query<Goods>(managedContext)
        ..where((x) => x.employee?.id).equalTo(id);
      final List<Goods> goods = await qGetGoods.fetch();
      if (goods.isEmpty) return Response.notFound();
      return Response.ok(goods);
    } catch (error) {
        return AppResponse.serverError(error, message: "Ошибка получения ОС");
    }
  }


  @Operation.delete("id")
  Future<Response> deleteGood(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentEmployeeId = AppUtils.getIdFromHeader(header);
      final good = await managedContext.fetchObjectWithID<Goods>(id);

      if (good == null) {
        return AppResponse.ok(message: "ОС не найдено");
      }

      if (good.employee?.id != currentEmployeeId) {
        return AppResponse.ok(message: "Нет доступа к ОС");
      }
      final qDeleteGood = Query<Goods>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeleteGood.delete();
      return AppResponse.ok(message: "Успешное удаление ОС");
    } catch (error) {
        return AppResponse.serverError(error, message: "Ошибка удаления ОС");
    }
  }




}