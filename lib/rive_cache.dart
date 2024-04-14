import 'dart:async';

import 'package:rive/rive.dart';

enum Rive2LoadStatus {
  loading,
  loaded,
  disposed,
}

class Rive2Cache {
  Map<String, Completer<RiveFile?>> rive2Cache = {};

  Rive2Cache() {
    // cache rive which are used frequently
    cacheRive2Animations([]);
  }

  void cacheRive2Animations(List<String> rives) async {
    rives.forEach((rive) {
      cacheRive(rive);
    });
  }

  void cacheRive(String rive) {
    if (getLoadStatus(rive) == Rive2LoadStatus.loading ||
        getLoadStatus(rive) == Rive2LoadStatus.loaded) {
      return;
    }

    rive2Cache[rive] = Completer<RiveFile?>();
    RiveFile.asset(rive).then((cachedRive) {
      rive2Cache[rive]!.complete(cachedRive);
    });
  }

  void disposeRive2Animations(List<String> rives) {
    rives.forEach((rive) {
      rive2Cache.remove(rive);
    });
  }

  Future<RiveFile?> getCachedRive2File(String rive) async {
    if (getLoadStatus(rive) == Rive2LoadStatus.disposed) {
      return null;
    }
    return rive2Cache[rive]!.future;
  }

  Rive2LoadStatus getLoadStatus(String rive) {
    if (!rive2Cache.containsKey(rive)) {
      return Rive2LoadStatus.disposed;
    }
    if (!(rive2Cache[rive]!.isCompleted)) {
      return Rive2LoadStatus.loading;
    }
    if (rive2Cache[rive]!.isCompleted) {
      return Rive2LoadStatus.loaded;
    }
    return Rive2LoadStatus.disposed;
  }
}
