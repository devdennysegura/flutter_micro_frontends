import 'client_proxy.dart';

/// [MicroserviceController] is an abstract base class for creating controllers
/// to handle incoming messages from other microservices. It provides a basic
/// structure for listening to messages and handling them using callbacks.
abstract class MicroserviceController {
  MicroserviceController(this.clientProxy);

  /// A reference to the [ClientProxy] instance.
  final ClientProxy clientProxy;

  /// The name of the message queue associated with this controller.
  static String? queueName = '';

  /// This method is called when the controller is initialized.
  void onInitialized();

  /// Adds a callback function [handler] for the given [pattern] to handle
  /// incoming messages.
  void registerMessageHandler(
    String pattern,
    Function(Object? message) handler,
  );
}
