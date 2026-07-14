import 'package:chat_demo/import.dart';

class ConfirmDialogUtil {
  static Future<bool> show(
    BuildContext context, {
    required String message,
    String cancelText = '取消',
    String confirmText = '确定',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: FontStyleUtils.blackTitle,
                ),
              ),
              Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => backPage(context, false),
                        child: Text(cancelText, style: FontStyleUtils.blackTitle),
                      ),
                    ),
                    Container(width: 1, height: 48, color: Color(0xFFE5E5E5)),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => backPage(context, true),
                        child: Text(
                          confirmText,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
      },
    );
    return result == true;
  }
}
