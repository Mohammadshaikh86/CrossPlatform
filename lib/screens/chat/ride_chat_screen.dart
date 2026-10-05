import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/common/user_avatar.dart';
import '../fare_split/fare_split_screen.dart';
import '../tracking/live_tracking_screen.dart';

class RideChatScreen extends StatefulWidget {
  final Ride ride;

  const RideChatScreen({super.key, required this.ride});

  @override
  State<RideChatScreen> createState() => _RideChatScreenState();
}

class _RideChatScreenState extends State<RideChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final List<String> _quickReplies = [
    '📍 I am at the pickup point',
    '🚗 Where are you right now?',
    '⏱️ Running 2 mins late',
    '💼 Trunk luggage space check',
    '💳 Paid my fare split share!',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(rideId: widget.ride.id, text: text);
    _textController.clear();
    _scrollToBottom();
  }

  void _handleShareLocation() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.shareMyLocation(
      rideId: widget.ride.id,
      locationName: 'Designated Curbside (Mission St & 1st)',
      latitude: widget.ride.originCoords.latitude,
      longitude: widget.ride.originCoords.longitude,
    );
    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 Live GPS pin broadcasted to carpool participants!'),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.getMessagesForRide(widget.ride.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.directions_car_filled_rounded, size: 12, color: Color(0xFFF59E0B)),
                  SizedBox(width: 4),
                  Text(
                    'RideShareX',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.ride.originName.split('(').first.trim()} ➔ ${widget.ride.destinationName.split('(').first.trim()}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.ride.driver.name} (Driver) • ${widget.ride.passengers.length} Riders',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation_outlined, color: Colors.black87),
            tooltip: 'Live Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveTrackingScreen(ride: widget.ride),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.black87),
            tooltip: 'Split Fare',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FareSplitScreen(ride: widget.ride),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              tabs: const [
                Tab(text: 'Group Carpool Chat'),
                Tab(text: 'Driver 1-on-1 Direct'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Security / GPS Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield_outlined, size: 13, color: Colors.black87),
                    SizedBox(width: 6),
                    Text(
                      'End-to-End Encrypted Carpool Chat',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _handleShareLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, size: 12, color: Color(0xFF92400E)),
                        SizedBox(width: 4),
                        Text(
                          'Share GPS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(
                  message: msg,
                  onLocationTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LiveTrackingScreen(ride: widget.ride),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Typing Indicator Simulation
          if (chatProvider.isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.ride.driver.name} is typing...',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),

          // Canned Quick Reply Chips
          QuickReplyChips(
            replies: _quickReplies,
            onSelected: (reply) {
              chatProvider.sendMessage(rideId: widget.ride.id, text: reply);
              _scrollToBottom();
            },
          ),
          const SizedBox(height: 8),

          // Bottom Input Field Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_location_alt_outlined, color: Colors.black87),
                    tooltip: 'Drop Live Location',
                    onPressed: _handleShareLocation,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _handleSendText(),
                      decoration: InputDecoration(
                        hintText: 'Message carpool group...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 18),
                      onPressed: _handleSendText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
