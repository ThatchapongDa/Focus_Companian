import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);

    _initialized = true;
  }

  Future<Box<T>> openBox<T>(String boxName) async {
    if (!_initialized) {
      await init();
    }
    return await Hive.openBox<T>(boxName);
  }

  Future<void> closeAllBoxes() async {
    await Hive.close();
  }
}
