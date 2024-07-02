import 'package:auth/models/response_model.dart';
import 'package:auth/models/user.dart';
import 'package:auth/utils/app_env.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;



class AppAuthContoller extends ResourceController {
  final ManagedContext managedContext;
  
  
  AppAuthContoller(this.managedContext);

// Авторизация
  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.username == null) {
      return Response.badRequest(
          body:
              AppResponseModel(message: "Поля password username обязательны"));
    }

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties(
            (table) => [table.id, table.salt, table.hashPassword]);

      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input("Пользователь не найден", []);
      }
      final requestHashPassword =
          generatePasswordHash(user.password ?? "", findUser.salt ?? "");
      if (requestHashPassword == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);
        final newUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);
        return AppResponse.ok(
            body: newUser?.backing.contents, message: "Успешная авторизация");
      } else {
        throw QueryException.input("Пароль не верный", []);
      }
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка авторизации");
    }
  }

// Регистрация
  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null) {
      return Response.badRequest(
        body: AppResponseModel(message: "Поле password обязательно"));
  }
    if (user.username == null) {
      return Response.badRequest(
        body: AppResponseModel(message: "Поле username обязательно"));
  }

    if (user.email == null) {
    return Response.badRequest(
        body: AppResponseModel(message: "Поле email обязательно"));
  }

    if (user.fullName == null) {
      return Response.badRequest(
          body: AppResponseModel(message: "Поле fullName обязательно"));
    }  
    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);
    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.fullName = user.fullName
          ..values.jobPost = user.jobPost
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()["id"];
        await _updateTokens(id, transaction);        
      });

      final requestData = {'fullName': user.fullName};
      // Формируем заголовки запроса
      final tokens = _getTokens(id);
      final headers = {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer ${tokens["access"]}'
      };

      final response = await http.post(
          Uri.parse('http://62.109.24.61/data/employees'),
          headers: headers,
          body: json.encode(requestData),
        );
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return AppResponse.ok(
          body: userData?.backing.contents, message: "Пользователь успешно зарегистрирован");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка регистрации");
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens["access"]
      ..values.refreshToken = tokens["refresh"];
    await qUpdateTokens.updateOne();
  }

// Обновление токена
  @Operation.post('refresh')
  Future<Response> refreshToken(
      @Bind.path("refresh") String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);
      final user = await managedContext.fetchObjectWithID<User>(id);
      if (user?.refreshToken != refreshToken) {
        return Response.unauthorized(
            body: AppResponseModel(message: "Token is not valid"));
      } else {
        await _updateTokens(id, managedContext);
        final user = await managedContext.fetchObjectWithID<User>(id);
        return AppResponse.ok(
            body: user?.backing.contents,
            message: "Успешное обновление токенов");
      }
    } catch (error) {
      return AppResponse.serverError(error,
          message: "Ошибка обновления токенов");
    }
  }

  Map<String, dynamic> _getTokens(int id) {
    // TODO remove when release
    final key = AppEnv.secretKey;
    final accesClaimSet = JwtClaim(
        maxAge: Duration(minutes: AppEnv.time), otherClaims: {"id": id});
    final refreshClaimSet = JwtClaim(otherClaims: {"id": id});
    final tokens = <String, dynamic>{};
    tokens["access"] = issueJwtHS256(accesClaimSet, key);
    tokens["refresh"] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
