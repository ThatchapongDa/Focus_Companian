import 'package:wakelock_plus/wakelock_plus.dart';

abstract class WakelockService {
  Future<void> enable();
  Future<void> disable();
}

class WakelockServiceImpl implements WakelockService {
  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}
