// import 'dart:async';
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

class AppPostContoller extends ResourceController {
  final ManagedContext managedContext;

  AppPostContoller(this.managedContext);

  @Operation.post()
  Future<Response> createPost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() Post post,
  ) async {
    if (post.content == null ||
        post.content?.isEmpty == true ||
        post.name == null ||
        post.name?.isEmpty == true) {
      return AppResponse.badRequest(message: "Поля name и content обязательны");
    }
    try {
      final id = AppUtils.getIdFromHeader(header);
      final author = await managedContext.fetchObjectWithID<Author>(id);
      if (author == null) {
        final qCreateAuthor = Query<Author>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }
      final size = post.content?.length ?? 0;
      final qCreatePost = Query<Post>(managedContext)
        ..values.author?.id = id
        ..values.name = post.name
        ..values.preContent = post.content?.substring(0, size <= 20 ? size : 20)
        ..values.content = post.content;
      await qCreatePost.insert();
      return AppResponse.ok(message: "Успешное создание поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка создания поста");
    }
  }

  @Operation.get("id")
  Future<Response> getPost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      // У поста есть айди, и мы сравниваем с айди который получаем в запросе
      // Вернуть пост, если он принадлежит пользователю
      final qGetPost = Query<Post>(managedContext)
      ..where((x) => x.id).equalTo(id)
      ..where((x) => x.author?.id).equalTo(currentAuthorId)
      ..returningProperties((x) => [
        x.content , x.id, x.name, 
      ]);
      final post = await qGetPost.fetchOne();

      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      
      return AppResponse.ok(
          body: post.backing.contents, message: "Успешное получение поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка получения поста");
    }
  }

  @Operation.delete("id")
  Future<Response> deletePost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);

      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }

      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      final qDeletePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeletePost.delete();
      return AppResponse.ok(message: "Успешное удаление поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка удаления поста");
    }
  }

  @Operation.get()
  Future<Response> getPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qGetPosts = Query<Post>(managedContext)
        ..where((x) => x.author?.id).equalTo(id);
      final List<Post> posts = await qGetPosts.fetch();
      if (posts.isEmpty) return Response.notFound();
      return Response.ok(posts);
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка получения поста");
    }
  }
}
