import 'package:flutter/foundation.dart';
import 'package:flutter_micro_frontends/src/client_proxy.dart';
import 'package:flutter_micro_frontends/src/micro_frontend_event.dart';
import 'package:flutter_micro_frontends/src/my_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Microservice communication tests', () {
    // The instance of the ClientProxy to manage micro frontend communication.
    late ClientProxy clientProxy;
    // The instance of MyController representing a micro frontend module.
    late MyController myController;

    setUp(() {
      clientProxy = ClientProxy();
      myController = MyController(clientProxy);
    });

    /// Test sending a message and receiving a response from the micro frontend.
    test('Send a message and receive a response', () async {
      // Register a message handler for the 'pattern1' and initialize the micro
      // frontend.
      myController
        ..registerMessageHandler(
          'pattern1',
          (Object? message) => 'Received: $message',
        )
        ..onInitialized();

      // Send a message and expect a response from the micro frontend.
      String response = await clientProxy.send<String>(
        'myController.queue',
        'pattern1',
        'Hello, microservices!',
      );
      expect(response, 'Received: Hello, microservices!');
    });

    /// Test emitting a message without waiting for a response from the micro
    ///  frontend.
    test('Emit a message without waiting for a response', () {
      // Register a message handler for the 'pattern2' and initialize the micro
      // frontend.
      myController
        ..registerMessageHandler(
          'pattern2',
          (Object? message) {
            debugPrint('Received: $message');
          },
        )
        ..onInitialized();

      // Emit a message without waiting for a response.
      clientProxy.emit(
        'myController.queue',
        'pattern2',
        'Hello, microservices!',
      );
    });

    /// Test handling an incoming message for a specific pattern.
    test('Handle an incoming message for a specific pattern', () {
      // Register a message handler for the 'pattern3' and initialize the micro
      // frontend.
      myController
        ..registerMessageHandler(
          'pattern3',
          (Object? message) {
            debugPrint('Received: $message');
          },
        )
        ..onInitialized();

      // Emit a message for the 'pattern3'.
      clientProxy.emit(
        'myController.queue',
        'pattern3',
        'Hello, microservices!',
      );
    });

    /// Test throwing an exception if no message handler is registered for a
    /// specific pattern.
    test(
        '''Throw an exception if no message handler is registered for a specific pattern''',
        () {
      // Initialize the micro frontend without registering a message handler.
      myController.onInitialized();
      // Listen for incoming messages in the 'myController.queue'.
      clientProxy.messageQueues['myController.queue']!.stream
          .listen((MicroFrontendEvent event) {});

      // Emit a message with an unregistered pattern and expect an exception to
      // be thrown.
      expect(
        () {
          clientProxy.emit(
            'myController.queue',
            'unregisteredPattern',
            'Hello, microservices!',
          );
        },
        throwsA(isA<Exception>()),
      );
    });
  });
}
