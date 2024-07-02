import 'package:data/utils/app_response.dart';
import 'package:data/models/author.dart';
import 'package:data/models/post.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:conduit/conduit.dart';
import 'package:data/utils/app_utils.dart';
import 'package:data/models/room.dart';
import 'package:data/models/Division.dart';
import 'package:data/models/Employee.dart';
import 'package:data/models/Goods.dart';
import 'package:data/models/InventoryList.dart';
import 'package:data/models/InventoryRecord.dart';
import 'dart:io';



class AppEmployeeController extends ResourceController {
  final ManagedContext managedContext;

  AppEmployeeController(this.managedContext);

  @Operation.post()
  Future<Response> createEmployee(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Employee employee,
    ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final employe = await managedContext.fetchObjectWithID<Employee>(id);
      if (employe == null) {
            final qCreateEmployee = Query<Employee>(managedContext)
            ..values.id = id
            ..values.fullName = employee.fullName
            ..values.division?.id = 1;
            final createdEmployee = await qCreateEmployee.insert();
            return AppResponse.ok(body: createdEmployee, message: "Сотрудник успешно создан");
      }
      else{
        return AppResponse.badRequest(message: "Сотрудник уже существует");
      }
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка создания сотрудника");
    }
  }
}
