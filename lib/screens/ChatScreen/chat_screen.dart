// lib/screens/ChatScreen/chat_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/chatbot_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatbotService = ChatbotService();

  bool _isLoading = false;

  // Data pesan
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Halo Kak! 👋 Saya Ikobana Assistant. Ada yang bisa saya bantu hari ini? Mau tanya stok, tips penyimpanan, atau rekomendasi produk?',
      'time': 'Sekarang',
      'isFromUser': false,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    final timeString = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'text': text,
        'time': timeString,
        'isFromUser': true,
      });
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    // Panggil API
    final aiReply = await _chatbotService.sendMessage(text, _messages);

    if (mounted) {
      setState(() {
        _messages.add({
          'text': aiReply,
          'time': '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          'isFromUser': false,
        });
        _isLoading = false;
      });
      _scrollToBottom();
    }
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessage(_messages[index]);
                },
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
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Stack(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Center(
                  child: Icon(Icons.smart_toy_outlined, color: Color(0xFF1D4ED8), size: 22),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 10, height: 10,
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
                'Ikobana Assistant',
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
                    width: 6, height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
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

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isFromUser = msg['isFromUser'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isFromUser ? const Color(0xFF0267D2) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isFromUser ? 16 : 2),
                  topRight: Radius.circular(isFromUser ? 2 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: isFromUser ? null : Border.all(color: const Color(0xFFF1F5F9).withValues(alpha: 0.8)),
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
                  color: isFromUser ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4, left: isFromUser ? 0 : 4, right: isFromUser ? 4 : 0),
            child: Text(
              msg['time'] as String,
              style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9).withValues(alpha: 0.8)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Ikobana Assistant sedang mengetik...', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: Color(0xFF1E293B)),
                  decoration: const InputDecoration(
                    hintText: 'Tanya sesuatu...',
                    hintStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : const Color(0xFF0267D2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}