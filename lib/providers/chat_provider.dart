import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/location_point.dart';
import '../models/user.dart';

class ChatProvider with ChangeNotifier {
  final Map<String, List<ChatMessage>> _rideMessages = {};
  bool _isTyping = false;

  ChatProvider() {
    _initSampleMessages();
  }

  bool get isTyping => _isTyping;

  List<ChatMessage> getMessagesForRide(String rideId) {
    return _rideMessages[rideId] ?? [];
  }

  void sendMessage({
    required String rideId,
    required String text,
    MessageType type = MessageType.text,
    GeoPoint? locationData,
    String? etaText,
  }) {
    final list = _rideMessages.putIfAbsent(rideId, () => []);

    final userMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      rideId: rideId,
      sender: User.currentUser,
      text: text,
      timestamp: DateTime.now(),
      type: type,
      locationData: locationData,
      etaText: etaText,
      isMe: true,
    );

    list.add(userMessage);
    notifyListeners();

    // Trigger realistic auto-response from Driver / Co-passenger if it's user text
    if (type == MessageType.text || type == MessageType.liveLocation) {
      _simulateAutoReply(rideId, text);
    }
  }

  void shareMyLocation({
    required String rideId,
    required String locationName,
    required double latitude,
    required double longitude,
  }) {
    sendMessage(
      rideId: rideId,
      text: '📍 Live location shared: $locationName',
      type: MessageType.liveLocation,
      locationData: GeoPoint(
        latitude: latitude,
        longitude: longitude,
        title: locationName,
        subtitle: 'Updated just now',
      ),
    );
  }

  void _simulateAutoReply(String rideId, String triggerText) {
    _isTyping = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 1600), () {
      _isTyping = false;
      final list = _rideMessages.putIfAbsent(rideId, () => []);

      final driverUser = const User(
        id: 'usr_1',
        name: 'Marcus Vance (Driver)',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
        email: 'marcus.v@ridesharex.com',
        phone: '+1 (555) 432-8765',
        rating: 4.96,
        totalRides: 142,
        isVerified: true,
        isDriver: true,
      );

      String replyText = 'Got it! I see your live ping. ETA is approx 4 minutes. See you shortly!';
      if (triggerText.toLowerCase().contains('luggage') || triggerText.toLowerCase().contains('bag')) {
        replyText = 'Trunk has plenty of room for 2 suitcases and backpacks. No problem at all!';
      } else if (triggerText.toLowerCase().contains('running late') || triggerText.toLowerCase().contains('traffic')) {
        replyText = 'No worries, take your time! I have pulled over at the designated curb with hazard lights on.';
      } else if (triggerText.toLowerCase().contains('paid') || triggerText.toLowerCase().contains('fare') || triggerText.toLowerCase().contains('split')) {
        replyText = 'Payment received with thanks! Ride fare split is all settled on my dashboard.';
      }

      final botMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        rideId: rideId,
        sender: driverUser,
        text: replyText,
        timestamp: DateTime.now(),
        type: MessageType.text,
        isMe: false,
      );

      list.add(botMessage);
      notifyListeners();
    });
  }

  void _initSampleMessages() {
    final now = DateTime.now();
    final driverMarcus = const User(
      id: 'usr_1',
      name: 'Marcus Vance (Driver)',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      email: 'marcus.v@ridesharex.com',
      phone: '+1 (555) 432-8765',
      rating: 4.96,
      totalRides: 142,
      isVerified: true,
      isDriver: true,
    );

    final userMaya = const User(
      id: 'usr_4',
      name: 'Maya Lin',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      email: 'maya.lin@ridesharex.com',
      phone: '+1 (555) 345-6789',
      rating: 4.92,
      totalRides: 31,
      isVerified: true,
    );

    _rideMessages['ride_101'] = [
      ChatMessage(
        id: 'm1',
        rideId: 'ride_101',
        sender: driverMarcus,
        text: 'Hello everyone! Heading out from Salesforce Tower in 10 minutes. Car is cooled and ready.',
        timestamp: now.subtract(const Duration(minutes: 25)),
        isMe: false,
      ),
      ChatMessage(
        id: 'm2',
        rideId: 'ride_101',
        sender: userMaya,
        text: "Great! I'm waiting near the north glass revolving doors.",
        timestamp: now.subtract(const Duration(minutes: 20)),
        isMe: false,
      ),
      ChatMessage(
        id: 'm3',
        rideId: 'ride_101',
        sender: User.currentUser,
        text: "I've arrived at the designated pickup zone near 1st Street.",
        timestamp: now.subtract(const Duration(minutes: 15)),
        isMe: true,
      ),
      ChatMessage(
        id: 'm4',
        rideId: 'ride_101',
        sender: driverMarcus,
        text: 'Live location updated. Approaching corner of Mission & 1st.',
        timestamp: now.subtract(const Duration(minutes: 10)),
        type: MessageType.liveLocation,
        locationData: const GeoPoint(
          latitude: 37.7897,
          longitude: -122.3972,
          title: 'Tesla Model 3 • Midnight Silver (6TRX921)',
          subtitle: 'Speed: 22 mph • 0.3 mi away',
        ),
        isMe: false,
      ),
      ChatMessage(
        id: 'm5',
        rideId: 'ride_101',
        sender: driverMarcus,
        text: 'Fare split reminder: Total \$43.50 divided equally among 3 riders (\$17.33/rider with tolls & tip).',
        timestamp: now.subtract(const Duration(minutes: 5)),
        type: MessageType.systemAlert,
        isMe: false,
      ),
    ];
  }
}
