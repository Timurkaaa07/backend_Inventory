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

class AppInventRecordContoller extends ResourceController {
    final ManagedContext managedContext;
    AppInventRecordContoller(this.managedContext);

// Инвентарная запись
    
    @Operation.post()
    Future<Response> createInventRecord(
        @Bind.header(HttpHeaders.authorizationHeader) String header,
        @Bind.body() InventoryRecord inventRecord) async {
            try {
                final id = AppUtils.getIdFromHeader(header);
                final employee = await managedContext.fetchObjectWithID<Employee>(id);
                final qCreateInventRecord = Query<InventoryRecord>(managedContext)
                ..values.inventRecord = DateTime.now()
                ..values.statusIR = inventRecord.statusIR
                ..values.employee?.id = id
                ..values.inventoryList?.id = inventRecord.inventoryList?.id
                ..values.statusYes = "сканировано"
                ..values.goodsList?.id = inventRecord.goodsList?.id;
                await qCreateInventRecord.insert();
                return AppResponse.ok(message: "Успешное создание инвентарной записи");
    }       catch (error) {
                return AppResponse.serverError(error, message: "Ошибка создания инвентарной записи");
    }
        }

}