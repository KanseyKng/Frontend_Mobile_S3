// lib/screens/ChatScreen/chat_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Halo, apakah Nugget Ayam masih tersedia?',
      'time': '14:32',
      'isFromSeller': false,
      'isRead': false,
      'productPreview': {
        'name': 'Frozen Chicken Nugget',
        'price': 'Rp35.000',
      },
    },
    {
      'text':
          'Halo Kak Andi 👋\nIya, Nugget Ayam masih tersedia. Kakak mau pesan berapa?',
      'time': '14:33',
      'isFromSeller': true,
      'isRead': true,
    },
    {
      'text': 'Saya mau 2 pack. Bisa dikirim hari ini?',
      'time': '14:34',
      'isFromSeller': false,
      'isRead': false,
    },
    {
      'text':
          'Bisa Kak. Pesanan akan kami proses setelah pembayaran berhasil.',
      'time': '14:34',
      'isFromSeller': true,
      'isRead': true,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'isFromSeller': false,
        'isRead': false,
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _buildDateBadge(),
                  const SizedBox(height: 12),
                  ..._messages.map(_buildMessage),
                ],
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          // Avatar
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Center(
                  child: Text(
                    'AP',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Andi Pratama',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Row(
                children: const [
                  SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Text(
          'Hari Ini, 24 Mei 2024',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isFromSeller = msg['isFromSeller'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isFromSeller ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bubble
          Align(
            alignment:
                isFromSeller ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isFromSeller
                    ? const Color(0xFF0267D2)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isFromSeller ? 16 : 2),
                  topRight: Radius.circular(isFromSeller ? 2 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: isFromSeller
                    ? null
                    : Border.all(
                        color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                msg['text'] as String,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  height: 1.5,
                  color: isFromSeller ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ),

          // Product Preview (kalau ada)
          if (msg['productPreview'] != null) ...[
            const SizedBox(height: 6),
            _buildProductPreview(msg['productPreview']),
          ],

          // Time + Read Receipt
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isFromSeller ? 0 : 4,
              right: isFromSeller ? 4 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg['time'] as String,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                if (isFromSeller) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all,
                      size: 13, color: Color(0xFF2563EB)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreview(Map<String, dynamic> preview) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood,
                color: AppColors.textMuted, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preview['name'] as String,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview['price'] as String,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Lihat Produk',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Attachment
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(Icons.attach_file,
                  color: Color(0xFF94A3B8), size: 20),
            ),
            const SizedBox(width: 4),
            // Input
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const Icon(Icons.emoji_emotions_outlined,
                        color: Color(0xFF94A3B8), size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF0267D2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send,
                    color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}