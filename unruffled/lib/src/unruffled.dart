import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:unruffled/src/models/data/data_adapter.dart';
import 'package:unruffled/src/models/data/data_model.dart';
import 'package:unruffled/src/models/offline/offline_operation.dart';
import 'package:unruffled/src/repositories/local/hive_local_storage.dart';
import 'package:unruffled/src/repositories/remote/remote_repository.dart';

class Unruffled {
  Unruffled({
    required this.baseDirectory,
    required String defaultBaseUrl,
    Map<String, dynamic>? defaultHeaders,
    List<int>? encryptionKey,
    Dio? dio,
  }) {
    dio?.options.baseUrl = defaultBaseUrl;
    dio?.options.headers = defaultHeaders;
    GetIt.I.registerSingleton(dio ??
        Dio(BaseOptions(
          baseUrl: defaultBaseUrl,
          headers: defaultHeaders,
        )));
    GetIt.I.registerSingleton(HiveLocalStorage(encryptionKey: encryptionKey));
  }

  final String baseDirectory;
  final List<RemoteRepository> _remoteRepositories = [];

  Unruffled registerAdapter<T extends DataModel<T>>(DataAdapter<T> adapter) {
    _remoteRepositories.add(RemoteRepository<T>(dataAdapter: adapter));
    return this;
  }

  Future<Unruffled> init() async {
    Hive.init(baseDirectory);
    for (var remote in _remoteRepositories) {
      await remote.initialize();
    }
    return this;
  }

  RemoteRepository<T> repository<T extends DataModel<T>>() {
    for (var element in _remoteRepositories) {
      if (element is RemoteRepository<T>) {
        return element;
      }
    }
    throw ("It seems that your class ${T.toString()} doesn't have a ${T.toString()}Adapter() registered");
  }

  Future<List<OfflineOperation>> get offlineOperations async {
    List<OfflineOperation> operations = [];
    for (var element in _remoteRepositories) {
      operations.addAll(await element.offlineOperations);
    }
    return operations;
  }
}
