import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';
import '../common/user_avatar.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLocationTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.systemAlert) {
      return _buildSystemAlert();
    }

    final isMe = message.isMe;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            UserAvatar(
              name: message.sender.name,
              imageUrl: message.sender.avatarUrl,
              radius: 14,
              isVerified: message.sender.isVerified,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      message.sender.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),

                // Message Body Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isMe ? Colors.black : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // Location snippet attachment card if type is liveLocation
                      if (message.type == MessageType.liveLocation) ...[
                        _buildLocationSnippet(context),
                        const SizedBox(height: 8),
                      ],

                      Text(
                        message.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF111827),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isMe ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSystemAlert() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 14, color: Color(0xFF92400E)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSnippet(BuildContext context) {
    return InkWell(
      onTap: onLocationTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD97706), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, size: 14, color: Color(0xFFD97706)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.locationData?.title ?? 'Live Location Point',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    message.locationData?.subtitle ?? 'Tap to track live on map',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 14, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}

class QuickReplyChips extends StatelessWidget {
  final List<String> replies;
  final ValueChanged<String> onSelected;

  const QuickReplyChips({
    super.key,
    required this.replies,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: replies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final reply = replies[index];
          return ActionChip(
            label: Text(
              reply,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onPressed: () => onSelected(reply),
          );
        },
      ),
    );
  }
}
