import 'package:flutter/material.dart';
import 'package:taski/core/utils/spacer.dart';
import 'package:taski/main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  
  int _currentStep = 0;
  bool _isTyping = false;
  
  // User responses
  List<String> _selectedPreferences = [];
  String _userName = '';
  String _firstTask = '';
  
  // Chat messages
  final List<ChatMessage> _messages = [];
  
  // Step data
  final List<ConversationStep> _steps = [
    ConversationStep(
      id: 0,
      botMessage: "Hi! I'm your AI assistant. I'm here to help you get the most out of Taski! 🤖\n\nWhat would you like to use Taski for? You can select multiple options.",
      type: StepType.preferences,
      options: [
        "Task Management",
        "AI Conversations", 
        "Calendar Scheduling",
        "Project Planning",
        "Habit Tracking",
        "Goal Setting",
        "Time Management",
        "Team Collaboration",
      ],
    ),
    ConversationStep(
      id: 1,
      botMessage: "Great choices! Now, what should I call you? I'll use your name to personalize our conversations.",
      type: StepType.name,
    ),
    ConversationStep(
      id: 2,
      botMessage: "Perfect! Now let's create your first task. What would you like to accomplish today?",
      type: StepType.task,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  void _startConversation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(_steps[0].botMessage);
    });
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handlePreferenceSelection(String option) {
    setState(() {
      if (_selectedPreferences.contains(option)) {
        _selectedPreferences.remove(option);
      } else {
        _selectedPreferences.add(option);
      }
    });
  }

  void _handleContinue() {
    switch (_steps[_currentStep].type) {
      case StepType.preferences:
        if (_selectedPreferences.isNotEmpty) {
          _addUserMessage("I'd like to use Taski for: ${_selectedPreferences.join(', ')}");
          _proceedToNextStep();
        }
        break;
      case StepType.name:
        if (_textController.text.trim().isNotEmpty) {
          _userName = _textController.text.trim();
          _addUserMessage("My name is $_userName");
          _textController.clear();
          _proceedToNextStep();
        }
        break;
      case StepType.task:
        if (_textController.text.trim().isNotEmpty) {
          _firstTask = _textController.text.trim();
          _addUserMessage("I want to: $_firstTask");
          _textController.clear();
          _proceedToNextStep();
        }
        break;
    }
  }

  void _proceedToNextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      
      // Add bot message for next step
      Future.delayed(Duration(milliseconds: 800), () {
        _addBotMessage(_steps[_currentStep].botMessage);
      });
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    _addBotMessage("Perfect! Welcome to Taski, $_userName! 🎉\n\nLet me set up your account with your preferences...");
    Future.delayed(Duration(seconds: 2), () {
      _addBotMessage("All set! You're ready to start being more productive. Let's get started!");
      Future.delayed(Duration(seconds: 1), () {
        print('Onboarding completed!');
        print('Preferences: $_selectedPreferences');
        print('Name: $_userName');
        print('First Task: $_firstTask');
        // TODO: Navigate to main app
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Getting Started",
          style: textTheme.titleLarge?.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: config.sw(20), vertical: config.sh(16)),
              itemCount: _messages.length + 1, // +1 for current step input
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _messages[index];
                } else {
                  // Current step input
                  return _buildCurrentStepInput();
                }
              },
            ),
          ),
          
          // Input area
          Container(
            padding: EdgeInsets.all(config.sw(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: config.sp(16),
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: _getInputHint(),
                        hintStyle: textTheme.bodyMedium?.copyWith(
                          fontSize: config.sp(16),
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: config.sw(20),
                          vertical: config.sh(12),
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          _handleContinue();
                        }
                      },
                    ),
                  ),
                ),
                XMargin(12),
                GestureDetector(
                  onTap: _handleContinue,
                  child: Container(
                    width: config.sw(44),
                    height: config.sh(44),
                    decoration: BoxDecoration(
                      color: _canContinue() ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: config.sp(20),
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

  Widget _buildCurrentStepInput() {
    final currentStep = _steps[_currentStep];
    
    switch (currentStep.type) {
      case StepType.preferences:
        return _buildPreferencesInput();
      case StepType.name:
        return Container(); // Handled by text input
      case StepType.task:
        return Container(); // Handled by text input
    }
  }

  Widget _buildPreferencesInput() {
    return Container(
      margin: EdgeInsets.only(bottom: config.sh(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select your preferences:",
            style: TextStyle(
              fontSize: config.sp(14),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          YMargin(12),
          Wrap(
            spacing: config.sw(8),
            runSpacing: config.sh(8),
            children: _steps[0].options.map((option) {
              final isSelected = _selectedPreferences.contains(option);
              
              return GestureDetector(
                onTap: () => _handlePreferenceSelection(option),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: config.sw(16),
                    vertical: config.sh(10),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: config.sp(14),
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedPreferences.isNotEmpty) ...[
            YMargin(16),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: config.sp(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInputHint() {
    switch (_steps[_currentStep].type) {
      case StepType.preferences:
        return "Select your preferences above";
      case StepType.name:
        return "Enter your name...";
      case StepType.task:
        return "What would you like to accomplish?";
    }
  }

  bool _canContinue() {
    switch (_steps[_currentStep].type) {
      case StepType.preferences:
        return _selectedPreferences.isNotEmpty;
      case StepType.name:
        return _textController.text.trim().isNotEmpty;
      case StepType.task:
        return _textController.text.trim().isNotEmpty;
    }
  }
}

enum StepType { preferences, name, task }

class ConversationStep {
  final int id;
  final String botMessage;
  final StepType type;
  final List<String> options;

  ConversationStep({
    required this.id,
    required this.botMessage,
    required this.type,
    this.options = const [],
  });
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.only(bottom: config.sh(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            // Bot avatar
            Container(
              width: config.sw(32),
              height: config.sh(32),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: config.sp(18),
              ),
            ),
            XMargin(12),
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: config.sw(16),
                    vertical: config.sh(12),
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomLeft: isUser ? Radius.circular(18) : Radius.circular(4),
                      bottomRight: isUser ? Radius.circular(4) : Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: config.sp(15),
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                YMargin(4),
                Text(
                  _formatTime(timestamp),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: config.sp(11),
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          if (isUser) ...[
            XMargin(12),
            // User avatar
            Container(
              width: config.sw(32),
              height: config.sh(32),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: config.sp(18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
} 