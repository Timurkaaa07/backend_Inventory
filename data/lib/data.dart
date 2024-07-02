import 'package:conduit_core/conduit_core.dart';
import 'package:conduit_postgresql/conduit_postgresql.dart';
import 'Contollers/app_post_controller.dart';
import 'Contollers/app_token_controller.dart';
import 'utils/app_env.dart';
import 'Contollers/app_barcode_controller.dart';
import 'Contollers/app_goods_controller.dart';
import 'Contollers/app_inventrecord_controller.dart';
import 'Contollers/app_employee_controller.dart';
import 'Contollers/app_inventlist_controller.dart';
class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;
  @override
  Future prepare() {
    final persistentStore = _initDatabase();
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  // @override
  // Controller get entryPoint => Router()
  //   ..route("token/[:refresh]").link(
  //     () => AppAuthContoller(managedContext),
  //   )
  //   ..route("user")
  //       .link(() => AppTokenController())!
  //       .link(() => AppUserContoller(managedContext));

    @override
    Controller get entryPoint => Router()
    // ..route("posts/[:id]").link(() => AppTokenController())!.link(() => AppPostContoller(managedContext))
    // ..route("goods/[:inventoryNumber]").link(() => AppGoodsBarcodeController(managedContext));
    ..route("posts/[:id]")
    .link(() => AppTokenController())!
    .link(() => AppPostContoller(managedContext),
    )

    ..route("employees")
    .link(() => AppTokenController())!
    .link(() => AppEmployeeController(managedContext),
    )

    ..route("good/[:id]")
    .link(() => AppTokenController())!
    .link(() => AppGoodsContoller(managedContext),
    )


    

    ..route("inventrecord")
    .link(() => AppTokenController())!
    .link(() => AppInventRecordContoller(managedContext),
    )

    ..route("inventlist/[:id]")
    .link(() => AppTokenController())!
    .link(() => AppInventListContoller(managedContext),
    )


    ..route("goods/[:inventorynumbergoods]")
    .link(() => AppTokenController())!
    .link(() => AppGoodsBarcodeController(managedContext));


        
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
