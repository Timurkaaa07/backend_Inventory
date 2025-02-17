import 'package:data/models/response_model.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResonseModel(error, message));

  static _getResonseModel(error, String? message) {
    if (error is QueryException) {
      return AppResponseModel(
          error: error.toString(), message: message ?? error.message);
    }
    if (error is JwtException) {
      return AppResponseModel(
          error: error.toString(), message: message ?? error.message);
    }
    return AppResponseModel(
        error: error.toString(), message: message ?? "Неизвестная ошибка");
  }

  AppResponse.ok({dynamic body, String? message})
      : super.ok(AppResponseModel(data: body, message: message));

  AppResponse.badRequest({String? message})
      : super.badRequest(
            body: AppResponseModel(message: message ?? "Ошибка запроса"));
  AppResponse.unauthorized(dynamic error, {String? message})
      : super.unauthorized(body: _getResonseModel(error, message));
}
