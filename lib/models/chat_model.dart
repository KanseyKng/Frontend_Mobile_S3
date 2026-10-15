// lib/models/chat_model.dart
class ChatMessage {
  final String text;
  final String time;
  final bool isFromSeller; // true = penjual, false = pembeli
  final bool isRead;
  final ChatProductPreview? productPreview;

  const ChatMessage({
    required this.text,
    required this.time,
    required this.isFromSeller,
    this.isRead = false,
    this.productPreview,
  });
}

class ChatProductPreview {
  final String name;
  final String price;
  final String imageUrl;

  const ChatProductPreview({
    required this.name,
    required this.price,
    this.imageUrl = '',
  });
}