import 'dart:async';

import 'package:flutter/foundation.dart';

import 'micro_frontend_event.dart';
import 'my_controller.dart';

/// The [ClientProxy] class is responsible for managing message queues and
/// communication between microservices. It provides methods to send and emit
/// messages through queues and register message handlers.
class ClientProxy {
  // ...rest of the private variables
  final Map<String, StreamController<MicroFrontendEvent>> _messageQueues =
      <String, StreamController<MicroFrontendEvent>>{};

  final Map<String, Map<String, MessageHandler>> _messageHandlersByQueue =
      <String, Map<String, MessageHandler>>{};

  /// Initializes the message queue with the given [queueName] if it doesn't
  /// already exist.
  void _initializeQueue(String queueName) {
    if (!_messageQueues.containsKey(queueName)) {
      _messageQueues[queueName] =
          StreamController<MicroFrontendEvent>.broadcast();
    }
  }

  /// Initializes the message queue with the given [queueName] if it doesn't
  /// already exist. This method is used for testing purposes.
  void initializeMessageQueue(String queueName) {
    _initializeQueue(queueName);
  }

  /// Registers a set of message handlers for the specified [queue].
  void registerMessageHandlers(
    String queue,
    Map<String, MessageHandler> handlers,
  ) {
    _messageHandlersByQueue[queue] = handlers;
  }

  /// Sends a message with the given [queue], [pattern], and [message] and
  /// returns a [Future] that completes with the response from the message
  /// handler.
  Future<T> send<T>([
    String queue = '',
    String pattern = '',
    Object? message,
  ]) async {
    _initializeQueue(queue);
    Completer<T> completer = Completer<T>();

    StreamSubscription<MicroFrontendEvent>? subscription;
    Map<String, dynamic Function(Object?)>? service =
        _messageHandlersByQueue[queue];
    dynamic Function(Object?)? serviceHandler;
    if (service!.containsKey(pattern)) {
      serviceHandler = service[pattern];
    } else {
      throw Exception(
        '''No handler found for pattern: $pattern in queue: $queue''',
      );
    }
    subscription =
        _messageQueues[queue]!.stream.listen((MicroFrontendEvent response) {
      if (response.pattern == pattern) {
        completer.complete(serviceHandler!(response.data) as T);
        subscription?.cancel();
      }
    });

    _messageQueues[queue]!.add(
      MicroFrontendEvent(pattern: pattern, data: message),
    );

    return completer.future;
  }

  /// Emits a message with the given [queue], [pattern], and [message] without
  /// waiting for a response.
  void emit([String queue = '', String pattern = '', Object? message]) {
    _initializeQueue(queue);
    Map<String, dynamic Function(Object?)>? service =
        _messageHandlersByQueue[queue];
    dynamic Function(Object?)? serviceHandler;
    if (service!.containsKey(pattern)) {
      serviceHandler = service[pattern];
    } else {
      throw Exception(
        '''No handler found for pattern: $pattern in queue: $queue''',
      );
    }
    serviceHandler!(message);
    _messageQueues[queue]!.add(
      MicroFrontendEvent(pattern: pattern),
    );
  }

  /// Returns the internal message queues. This method is used for testing
  /// purposes.
  @visibleForTesting
  Map<String, StreamController<MicroFrontendEvent>> get messageQueues =>
      _messageQueues;
}
