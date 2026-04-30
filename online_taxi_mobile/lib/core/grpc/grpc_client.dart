import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart';
import '../services/storage_service.dart';

const _host = '10.0.2.2'; // Android эмулятор. Для реального устройства — IP машины

class AuthInterceptor extends ClientInterceptor {
  final StorageService _storage;
  String? _token;

  AuthInterceptor(this._storage) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    _token = await _storage.getAccessToken();
  }

  void updateToken(String? token) => _token = token;

  CallOptions _withAuth(CallOptions options) {
    if (_token == null) return options;
    return options.mergedWith(
      CallOptions(metadata: {'authorization': 'Bearer $_token'}),
    );
  }

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    return invoker(method, request, _withAuth(options));
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    return invoker(method, requests, _withAuth(options));
  }
}

class GrpcClients {
  final ClientChannel auth;
  final ClientChannel driver;
  final ClientChannel trip;
  final AuthInterceptor interceptor;

  GrpcClients({
    required this.auth,
    required this.driver,
    required this.trip,
    required this.interceptor,
  });
}

final grpcClientsProvider = Provider<GrpcClients>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final opts = ChannelOptions(credentials: const ChannelCredentials.insecure());
  return GrpcClients(
    auth:        ClientChannel(_host, port: 50051, options: opts),
    driver:      ClientChannel(_host, port: 50052, options: opts),
    trip:        ClientChannel(_host, port: 50053, options: opts),
    interceptor: AuthInterceptor(storage),
  );
});
