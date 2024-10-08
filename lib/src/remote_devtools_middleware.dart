// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

// ignore: use_string_in_part_of_directives
part of flutter_bloc_dev_tools;

class RemoteDevToolsObserver extends BlocObserver {
  static late Socket socket;
  String? _channel;
  late String _url;
  int portNumber;
  String ipAddress;

  RemoteDevToolsStatus _status = RemoteDevToolsStatus.notConnected;

  RemoteDevToolsStatus get status => _status;

  Set<int> skippedIndexes = {};

  final Map<String, Map<int, String>> _blocs = {};
  final Map<String, dynamic> _appState = {};
  final Set<BlocBase> _appBlocs = {};

  /// The name that will appear in Instance Name in Dev Tools. If not specified,
  /// default to 'Flutter Dev Tools'.
  String? instanceName;

  RemoteDevToolsObserver({
    required this.portNumber,
    required this.ipAddress,
    this.instanceName = 'Flutter Dev Tools',
  }) {
    _url = "ws://$ipAddress:$portNumber/socketcluster/";
    connect();
  }

  Future<void> connect() async {
    try {
      _status = RemoteDevToolsStatus.connecting;
      socket = await Socket.connect(
        _url,
        listener: SocketListener(),
      );

      _status = RemoteDevToolsStatus.connected;
      _channel = await _login();
      _status = RemoteDevToolsStatus.starting;
      _relay(DevConstant.start);
      _waitForStart();
    } catch (e) {
      log('Must Run Devtools Correctly to continue');
    }
  }

  Future<String> _login() {
    final c = Completer<String>();
    socket.emit(DevConstant.login, DevConstant.master,
        (String name, dynamic error, dynamic data) {
      c.complete(data as String);
    });
    return c.future;
  }

  void _waitForStart() {
    socket.on(_channel!, (String? name, dynamic data) {
      if (data[DevConstant.type] == DevConstant.start) {
        _status = RemoteDevToolsStatus.started;
      } else if (data[DevConstant.type] == DevConstant.dispatch &&
          data[DevConstant.smallAction][DevConstant.type] ==
              DevConstant.toggleAction) {
        log('skip');

        _storeSkipIndex(data[DevConstant.smallAction][DevConstant.id]);
      } else {
        if (data[DevConstant.type] == DevConstant.dispatch &&
            data[DevConstant.smallAction][DevConstant.type] ==
                DevConstant.jumpToState) {
          log('jump');

          _handleJump(
              json.decode(data[DevConstant.state]) as Map<String, dynamic>,
              data[DevConstant.smallAction][DevConstant.index]);
        }
      }
    });
  }

  String? _getBlocName(BlocBase? bloc) {
    final blocName = bloc.runtimeType.toString();
    final blocHash = bloc.hashCode;
    if (_blocs.containsKey(blocName)) {
      if (!_blocs[blocName]!.containsKey(blocHash)) {
        _blocs[blocName]?[blocHash] =
            '$blocName-${_blocs[blocName]?.keys.length}';
      }
    } else {
      _blocs[blocName] = {blocHash: blocName};
    }
    return _blocs[blocName]?[blocHash];
  }

  void _removeBlocName(BlocBase bloc) {
    final blocName = bloc.runtimeType.toString();
    final blocHash = bloc.hashCode;
    if (_blocs.containsKey(blocName) &&
        _blocs[blocName]!.containsKey(blocHash)) {
      _blocs[blocName]?.remove(blocHash);
    }
  }

  void _handleJump(Map<String, dynamic> json, int index) {
    if (skippedIndexes.contains(index)) {
      return;
    }

    json.forEach((key, value) {
      final bloc =
          _appBlocs.firstWhere((bloc) => bloc.runtimeType.toString() == key);

      final newState = bloc.state.fromJson(value);

      bloc.emit(newState);
    });
  }

  void _storeSkipIndex(int skipIndex) {
    skippedIndexes.add(skipIndex);
  }

  void _relay(String type,
      [BlocBase? bloc, Object? state, dynamic action, String? nextActionId]) {
    final message = {
      DevConstant.type: type,
      'id': socket.id,
      'name': instanceName
    };
    final blocName = _getBlocName(bloc);
    if (state != null) {
      /// Add or update Bloc state
      if (state is MappableToJson) {
        _appState[blocName ?? 'NA'] = state.toJson();
        message[DevConstant.payload] = jsonEncode(_appState);
      } else {
        _appState[blocName ?? 'NA'] = state.toString();
        message[DevConstant.payload] = jsonEncode(_appState);
      }
    } else {
      /// Remove Bloc state
      if (_appState.containsKey(blocName)) {
        _removeBlocName(bloc!);
        _appState.remove(blocName);
        message[DevConstant.payload] = jsonEncode(_appState);
      }
    }

    if (type == DevConstant.bigAction) {
      message[DevConstant.smallAction] = _actionEncode(action);
      message[DevConstant.nextActionId] = nextActionId;
    } else if (action != null) {
      message[DevConstant.smallAction] = action as String;
    }
    if (bloc != null) {
      _appBlocs.add(bloc);
    }
    socket.emit(
        socket.id != null ? DevConstant.log : DevConstant.logNoid, message);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (status == RemoteDevToolsStatus.started) {
      _relay(
          DevConstant.bigAction, bloc, transition.nextState, transition.event);
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (status == RemoteDevToolsStatus.started && bloc is Cubit) {
      _relay(DevConstant.bigAction, bloc, change.nextState,
          bloc.runtimeType.toString());
    }
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (status == RemoteDevToolsStatus.started) {
      _relay(DevConstant.bigAction, bloc, bloc.state, 'OnCreate');
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (status == RemoteDevToolsStatus.started) {
      _relay(DevConstant.bigAction, bloc, null, 'OnClose');
    }
  }

  String _actionEncode(dynamic action) {
    if (action is MappableToJson) {
      if (action.toJson().keys.isEmpty) {
        return jsonEncode({
          DevConstant.type: action.runtimeType.toString(),
        });
      }
      return jsonEncode({
        DevConstant.type: action.runtimeType.toString(),
        DevConstant.payload: action.toJson(),
      });
    }

    if (action.toString().contains(DevConstant.instanceOf)) {
      return jsonEncode({
        DevConstant.type: action.runtimeType.toString(),
      });
    }

    return jsonEncode({
      DevConstant.type: action.toString(),
    });
  }
}
