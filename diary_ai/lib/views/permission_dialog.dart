import 'package:flutter/material.dart';

class PermissionDialogItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  PermissionDialogItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class PermissionDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final List<PermissionDialogItem> requiredItems;
  final List<PermissionDialogItem> optionalItems;

  const PermissionDialog({
    Key? key,
    required this.onConfirm,
    this.onCancel,
    required this.requiredItems,
    required this.optionalItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.security,
                size: 32,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 16),
            // 제목
            Text(
              '권한 허용 필요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            // 설명
            Text(
              '앱의 정상적인 동작을 위해\n다음 권한들이 필요합니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // 권한 목록
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (requiredItems.isNotEmpty) ...[
                    const Text('[필수 권한]',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...requiredItems
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildPermissionItem(
                                icon: item.icon,
                                title: item.title,
                                description: item.description,
                                color: item.color,
                              ),
                            ))
                        .toList(),
                  ],
                  if (optionalItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('[선택 권한]',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...optionalItems
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildPermissionItem(
                                icon: item.icon,
                                title: item.title,
                                description: item.description,
                                color: item.color,
                              ),
                            ))
                        .toList(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 버튼들
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: TextButton(
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 확인 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
