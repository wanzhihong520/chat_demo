import 'package:chat_demo/import.dart';

class PhoneInfoPage extends StatefulWidget {
  const PhoneInfoPage({super.key});

  @override
  State<PhoneInfoPage> createState() => _PhoneInfoPageState();
}

class _PhoneInfoPageState extends State<PhoneInfoPage> {
  Map<String, dynamic>? _deviceInfo;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final info = await DeviceInfoPlugin.getDeviceInfo();
      if (!mounted) return;
      setState(() {
        _deviceInfo = info;
        _errorMessage = null;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message ?? '暂时无法获取手机信息';
      });
    } on MissingPluginException {
      if (!mounted) return;
      setState(() {
        _errorMessage = '当前平台暂未提供手机信息';
      });
    } on StateError catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
      });
    }
  }

  String _value(String key) {
    final value = _deviceInfo?[key];
    if (value == null || value.toString().trim().isEmpty) return '未知';
    return value.toString();
  }

  Widget _row(String label, String value) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label, style: FontStyleUtils.blackTitle),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: FontStyleUtils.blackBody,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _deviceInfo == null && _errorMessage == null;

    return Scaffold(
      appBar: AppBar(title: Text('手机信息', style: FontStyleUtils.blackTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!, style: FontStyleUtils.blackBody),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loadDeviceInfo,
                        child: const Text('重新获取'),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _row('设备厂商', _value('manufacturer')),
                    Divider(height: 1, color: Colors.grey[200]),
                    _row('设备型号', _value('model')),
                    Divider(height: 1, color: Colors.grey[200]),
                    _row('系统版本', _value('androidVersion')),
                  ],
                ),
    );
  }
}
