part of my_reunify_app;

/// ===============================================
/// CHAT INBOX PAGE (replaces Notifications/Alerts)
/// ===============================================

class ChatInboxPage extends StatefulWidget {
  final EnhancedMockDataRepository repository;
  final bool isParent;

  const ChatInboxPage({
    super.key,
    required this.repository,
    required this.isParent,
  });

  @override
  State<ChatInboxPage> createState() => _ChatInboxPageState();
}

class _ChatInboxPageState extends State<ChatInboxPage> {
  List<ConversationThread> _threads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    final threads = await widget.repository.getConversationThreads(
      isParent: widget.isParent,
    );
    if (mounted) {
      setState(() {
        _threads = threads;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : _threads.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _threads.length,
                itemBuilder: (context, index) {
                  final t = _threads[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SmartCard(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChatPage(
                                  conversationId: t.conversationId,
                                  otherPartyLabel:
                                      widget.isParent ? 'Contact' : 'Family',
                                  repository: widget.repository,
                                  isParent: widget.isParent,
                                ),
                          ),
                        );
                        _loadThreads();
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        t.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                              t.hasUnread
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatTime(t.lastActivity),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        t.hasUnread
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (t.hasUnread)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Future<void> _startNewChat() async {
    // For demo: open a generic new conversation
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatPage(
              conversationId: 'new_${DateTime.now().millisecondsSinceEpoch}',
              otherPartyLabel: widget.isParent ? 'Community Member' : 'Family',
              repository: widget.repository,
              isParent: widget.isParent,
            ),
      ),
    );
    _loadThreads();
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Conversations with families will appear here',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startNewChat,
            icon: const Icon(Icons.edit),
            label: const Text('Start a Conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}
