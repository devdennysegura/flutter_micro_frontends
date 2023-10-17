import '../flutter_micro_frontends.dart';

/// A [MessageHandler] is a function that takes an input message and processes
/// it. It returns a value of type T based on the processed input.
typedef MessageHandler<T> = T? Function(Object? message);

/// The [MyController] class is an example implementation of a
/// [MicroserviceController]. It demonstrates how to create a controller that
/// listens to messages and processes them using registered message handlers.
class MyController extends MicroserviceController {
  MyController(ClientProxy clientProxy) : super(clientProxy);

  /// A map of registered message handlers.
  final Map<String, MessageHandler> messageHandlers =
      <String, MessageHandler>{};

  /// The name of the message queue associated with this controller.
  static String? queueName = 'myController.queue';

  /// Adds a callback function [handler] for the given [pattern] to handle
  /// incoming messages.
  @override
  void registerMessageHandler(
    String pattern,
    Function(Object? message) handler,
  ) {
    messageHandlers[pattern] = handler;
  }

  /// This method is called when the controller is initialized. It sets up the
  /// message queue and registers the message handlers.
  @override
  void onInitialized() {
    clientProxy
      ..initializeMessageQueue(queueName!)
      ..registerMessageHandlers(queueName!, messageHandlers);
  }
}
