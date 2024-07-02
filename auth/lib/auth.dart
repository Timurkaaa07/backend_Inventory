import 'package:auth/Contollers/app_auth_controller.dart';
import 'package:auth/Contollers/app_token_controller.dart';
import 'package:auth/Contollers/app_user_controller.dart';
import 'package:conduit_core/conduit_core.dart';
import 'package:conduit_postgresql/conduit_postgresql.dart';

import 'utils/app_env.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;
  @override
  Future prepare() {
    final persistentStore = _initDatabase();
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route("token/[:refresh]").link(
      () => AppAuthContoller(managedContext),
    )
    ..route("user")
        .link(() => AppTokenController())!
        .link(() => AppUserContoller(managedContext));
  PostgreSQLPersistentStore _initDatabase() {
    return PostgreSQLPersistentStore(
      AppEnv.dbUsername,
      AppEnv.dbPassword,
      AppEnv.dbHost,
      int.tryParse(AppEnv.dbPort),
      AppEnv.dbDatabaseName,
    );
  }
}
