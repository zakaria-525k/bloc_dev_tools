// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:bloc_dev_tools/bloc_dev_tools.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final observer = RemoteDevToolsObserver(url: 'ws://localhost:8123/socketcluster/');

  await observer.connect();

  Bloc.observer = observer;
  runApp(const CounterApp());
}
