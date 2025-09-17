import 'dart:async';

import 'package:diary_ai/models/message.dart';
import 'package:flutter/material.dart';
import 'package:diary_ai/models/location_history.dart';

class LocDiaryChatDialog extends StatefulWidget {
  final List<String> photoPaths;
  final LocationHistory location;
  const LocDiaryChatDialog({
    Key? key,
    required this.photoPaths,
    required this.location,
  }) : super(key: key);

  @override
  State<LocDiaryChatDialog> createState() => _LocDiaryChatDialogState();
}

class _LocDiaryChatDialogState extends State<LocDiaryChatDialog> {
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? _aiResponseSubscription;
  String _currentAiResponse = '';
  final List<Message> _messages = [];
  //  [
  //   Message(
  //     role:'notice',
  //     content:'AI와 대화하면서 일기를 작성해보세요. AI와 주고받은 대화로 일기가 작성됩니다.'),
  //   Message(
  //     role: 'assistant',
  //     content: '안녕? 스타벅스 강남점에 갔구나? 마신건 아이스 아메리카노인가? 요즘 더워서 아이스 아메리카노없인 힘들지 많이 힘들지?'),
  //   Message(
  //     role: 'user',
  //     content: '응 출근길에 들러서 하나 샀어. 역시 직장인은 모닝 커피가 있어야 일을 할 수 있지 '),
  //   Message(
  //     role: 'assistant',
  //     content: '그렇구나 오늘 출근길 컨디션은 어때?'),
  //   Message(
  //     role: 'user',
  //     content: '어제 피곤해서 일찍 잤더니 컨디션이 나쁘지 않아.'),
  //   Message(
  //     role: 'assistant',
  //     content: '컨디션 좋다니 다행이다. 아침에 커피 주문할 때 사람이 붐비진 않았어?'),
  //   Message(
  //     role: 'user',
  //     content: '조금 붐비긴 했는데 생각보다 빨리 받았어.'),
  //   Message(
  //     role: 'assistant',
  //     content: '오늘도 출근하느라 고생했어! 오늘도 내일도 화이팅!'),
  // ];

  bool _isLoading = false;
  int _chatCount = 0;
  String? _diarySummary;

  @override
  void initState() {
    super.initState();
    _requestFirstGreeting();
  }

  void _requestFirstGreeting() async {
    setState(() => _isLoading = true);
    // final aiServices = AIServices.instance;
    // await aiServices.initialize();
    // final preset =
    //     Provider.of<SettingsProvider>(context, listen: false).characterPreset;
    // final prompt = PromptUtils.buildPrompt(
    //   context: context,
    //   createdAt: widget.location.timestamp,
    //   locationDiaries: [
    //     {
    //       'locationName': widget.location.placeName,
    //       'content': '', // 첫 인사이므로 내용 없음
    //     }
    //   ],
    //   photoCount: widget.photoPaths.length,
    // );
    // final response = await aiServices.getAIResponse(
    //   prompt,
    //   [],
    // );
    setState(() {
      // _currentAiResponse = response;
      _messages.add(Message(role: 'assistant', content: _currentAiResponse));
      _isLoading = false;
    });
  }

  void _sendMessage() async {
    // 채팅 기능 제거됨
  }

  Future<bool> _handleCloseRequest() async {
    final hasChat =
        _messages.any((m) => m.role == 'user' || m.role == 'assistant');
    if (hasChat) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('일기 작성'),
          content: Text('지금까지의 대화로 일기를 작성할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('끄기'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('작성'),
            ),
          ],
        ),
      );
      if (result == true) {
        Navigator.of(context).pop(_messages);
        return false;
      } else if (result == false) {
        Navigator.of(context).pop();
        return false;
      }
      return false;
    } else {
      Navigator.of(context).pop();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleCloseRequest,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.location.place?['name'] ??
                              widget.location.placeName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'AI와 대화',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: _handleCloseRequest,
                  ),
                ],
              ),
              SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isUser = msg.role == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isUser)
                              Padding(
                                padding:
                                    const EdgeInsets.only(right: 6.0, top: 2),
                                child: Icon(Icons.smart_toy,
                                    color: Colors.purple, size: 20),
                              ),
                            Flexible(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Colors.purple[100]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  msg.content,
                                  style: TextStyle(
                                      color: Colors.black87, fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('AI가 답변 중...'),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.purple),
                    onPressed:
                        _isLoading || _chatCount >= 4 ? null : _sendMessage,
                  ),
                ],
              ),
              if (_diarySummary != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _diarySummary);
                    },
                    child: Text('대화 내용으로 일기 작성하기'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
