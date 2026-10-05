import 'location_point.dart';
import 'user.dart';

enum MessageType {
  text,
  liveLocation,
  etaUpdate,
  systemAlert,
  fareReceipt,
}

class ChatMessage {
  final String id;
  final String rideId;
  final User sender;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final GeoPoint? locationData;
  final String? etaText;
  final double? amount;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.rideId,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.locationData,
    this.etaText,
    this.amount,
    this.isMe = false,
  });

  ChatMessage copyWith({
    String? id,
    String? rideId,
    User? sender,
    String? text,
    DateTime? timestamp,
    MessageType? type,
    GeoPoint? locationData,
    String? etaText,
    double? amount,
    bool? isMe,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      locationData: locationData ?? this.locationData,
      etaText: etaText ?? this.etaText,
      amount: amount ?? this.amount,
      isMe: isMe ?? this.isMe,
    );
  }
}
