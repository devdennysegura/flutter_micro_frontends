// The [MicroFrontendEvent] class represents an event occurring in the
/// microfrontend architecture. It contains a [pattern] and optional [data].
class MicroFrontendEvent {
  /// Constructs a [MicroFrontendEvent] with the given [pattern] and optional
  /// [data].
  MicroFrontendEvent({required this.pattern, this.data});

  /// The pattern associated with this event.
  final String pattern;

  /// The data associated with this event.
  final Object? data;

  /// Returns a string representation of the [MicroFrontendEvent].
  @override
  String toString() => 'MicroFrontendEvent($pattern)';

  /// Returns the hash code for this [MicroFrontendEvent].
  @override
  int get hashCode => pattern.hashCode ^ data.hashCode;

  /// Compares two [MicroFrontendEvent] objects for equality.
  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MicroFrontendEvent &&
        other.pattern == pattern &&
        other.data == data;
  }
}
