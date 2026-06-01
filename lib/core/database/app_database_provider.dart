import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'daos/chat_local_dao.dart';
import 'app_database.dart';

//This keeps the Drift database shared through Riverpod.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  ref.onDispose(database.close);

  return database;
});

final chatLocalDaoProvider = Provider<ChatLocalDao>((ref) {
  return ref.watch(appDatabaseProvider).chatLocalDao;
});