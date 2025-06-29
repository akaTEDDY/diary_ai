import 'package:flutter/material.dart';

class LocDiaryChatDialog extends StatefulWidget {
  final List<String> photoPaths;
  final String locationName;
  final String? initialPrompt;
  const LocDiaryChatDialog({
    Key? key,
    required this.photoPaths,
    required this.locationName,
    this.initialPrompt,
  }) : super(key: key);

  @override
  State<LocDiaryChatDialog> createState() => _LocDiaryChatDialogState();
}

class _LocDiaryChatDialogState extends State<LocDiaryChatDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'notice': 'AI와 대화하면서 일기를 작성해보세요. AI와 주고받은 대화로 일기가 작성됩니다.'},
    {
      'ai': '안녕? 스타벅스 강남점에 갔구나? 마신건 아이스 아메리카노인가? 요즘 더워서 아이스 아메리카노없인 힘들지 많이 힘들지?'
    },
    {'user': '응 출근길에 들러서 하나 샀어. 역시 직장인은 모닝 커피가 있어야 일을 할 수 있지 '},
    {'ai': '그렇구나 오늘 출근길 컨디션은 어때?'},
    {'user': '어제 피곤해서 일찍 잤더니 컨디션이 나쁘지 않아.'},
    {'ai': '컨디션 좋다니 다행이다. 아침에 커피 주문할 때 사람이 붐비진 않았어?'},
    {'user': '조금 붐비긴 했는데 생각보다 빨리 받았어.'},
    {'ai': '오늘도 출근하느라 고생했어! 오늘도 내일도 화이팅!'},
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'user': text});
      _controller.clear();
      _isLoading = true;
    });
    // TODO: AI 응답 받아오기 (임시 딜레이)
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _messages.add({'ai': 'AI의 응답 예시: "$text"에 대해 질문/피드백'});
      _isLoading = false;
    });
  }

  Future<bool> _handleCloseRequest() async {
    final hasChat =
        _messages.any((m) => m.containsKey('user') || m.containsKey('ai'));
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
                          widget.locationName,
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
                      if (msg.containsKey('notice')) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              msg['notice']!,
                              style: TextStyle(
                                color: Colors.purple[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      final isUser = msg.containsKey('user');
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
                                  isUser ? msg['user']! : msg['ai']!,
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
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
