# Remote Devtools for flutter_bloc

Remote Devtools support for Blocs of [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc).

## Features

- **Supports Cubit and bloc.
- **Inspect bloc state and Event.
- **Supports Skip Action: This allows dropping a state from the list of states in the app.
- **Support Jump Action:This allows jumping to any state and starting the sliding of states from the selected state.
- **Changes to the states made through the dashboard will be rendered on the tested mobile device.
- **Support Slider that tracks all states except skipped states.


![Devtools Demo](https://github.com/andrea689/flutter_bloc_devtools/raw/main/demo.gif)

## Installation

Add the library to pubspec.yaml:

```yaml
dependencies:
  bloc_dev_tools: ^1.0.0
```

## BlocObserver configuration

Add `RemoteDevToolsObserver` to your `Bloc.observer`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final observer = RemoteDevToolsObserver(
    portNumber: 8000,
    ipAddress: 'localhost',
  );

  await observer.connect();
  Bloc.observer = observer;

  runApp(const CounterApp());
}
/*
Notes About Ip Address on different Devices :

*In real device ip
Find the local IP address of your machine
On Windows:
Open Command Prompt and type ipconfig.
On macOS/Linux:

Open Terminal and type ifconfig (or ip a on Linux).
Look for the inet address under your active network interface (e.g., en0).

*In Simulator
localhost

*In Emulator
10.0.2.2
 */
```

## Making your Events and States Mappable

Events and States have to implements `MappableToJson, MappableFromJson`:

```dart
class CounterState extends Equatable implements MappableToJson, MappableFromJson {
  final int counter;

  const CounterState({
    required this.counter,
  });

  CounterState copyWith({
    int? counter,
  }) =>
      CounterState(
        counter: counter ?? this.counter,
      );

  @override
  List<Object> get props => [
    counter,
  ];

  @override
  Map<String, dynamic> toJson() => {
    'counter': counter,
  };

  @override
  CounterState fromJson(Map<String, dynamic> json) {
    return CounterState(counter: json['counter']);
  }
}

```

## Using remotedev

Use the Javascript [Remote Devtools](https://github.com/zalmoxisus/remotedev-server) package. Start the remotedev server on your machine

```bash
npm install -g remotedev-server
remotedev --port 8000
```

Run your application. It will connect to the remotedev server. You can now debug your flutter_bloc application by opening up `http://localhost:8000` in a web browser.

## Examples

- [Counter](example/counter)
