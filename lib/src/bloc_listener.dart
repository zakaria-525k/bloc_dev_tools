import 'dart:async';
import 'dart:developer';

import 'package:socketcluster_client/socketcluster_client.dart';

class MyListener extends BasicListener {
  @override
  void onAuthentication(Socket socket, bool? status) {
    log('onAuthentication: socket $socket status $status');
  }

  @override
  void onConnectError(Socket socket, e) {
    log('onConnectError: socket $socket e $e');
  }

  @override
  void onConnected(Socket socket) {
    log('onConnected: socket $socket');
    Timer.periodic(const Duration(seconds: 2), (_) {
      log('Attempting to send');
      socket.emit('sampleClientEvent', {'message': 'This is an object with a message property'});
    });
  }

  @override
  void onDisconnected(Socket socket) {
    log('onDisconnected: socket $socket');
  }

  @override
  void onSetAuthToken(String? token, Socket socket) {
    log('onSetAuthToken: socket $socket token $token');
    socket.authToken = token;
  }
}
