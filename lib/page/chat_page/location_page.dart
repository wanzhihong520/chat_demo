import 'package:chat_demo/import.dart';
import 'package:crypto/crypto.dart';
import 'package:tencent_map_flutter/tencent_map_flutter.dart' hide LatLng;
import 'package:latlong2/latlong.dart' as geo;

class LocationPage extends StatefulWidget {
  final String? receiver;
  final String? groupID;

  const LocationPage({super.key, this.receiver, this.groupID});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  static const _mapKey = 'W2VBZ-ZZFK3-KIG3W-RFSBC-HQH4S-IYBCJ';
  static const _mapSecret = '7btuQAXAT4nwqvZVlN3FxOKuSZWRa7TM';
  TencentMapController? _controller;
  int currentIndex = 0;
  int _locationRequestId = 0;
  geo.LatLng? latLng;
  Response? response;
  bool isLocation = true;
  final Map<String, dynamic> location = {
    "desc": '',
    "longitude": 0.0,
    "latitude": 0.0,
  };

  List<Map> get _pois {
    final data = response?.data;
    if (data is! Map || data['result'] is! Map) return const [];
    final pois = data['result']['pois'];
    if (pois is! List) return const [];
    return pois.whereType<Map>().toList();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> getLocation(double lat, double lng) async {
    final requestId = ++_locationRequestId;
    location['longitude'] = lng;
    location['latitude'] = lat;
    location['desc'] = '';
    try {
      final query = 'get_poi=1&key=$_mapKey&location=$lat,$lng';
      final path = '/ws/geocoder/v1/?$query';
      final sig = md5.convert(utf8.encode('$path$_mapSecret')).toString();
      var result = await Dio().get('https://apis.map.qq.com$path&sig=$sig');
      var data = result.data is Map ? result.data as Map : const {};
      // Some keys do not enable signature validation. Retry without sig so
      // reverse geocoding still works for those keys.
      if (data['status'] != 0) {
        result = await Dio().get('https://apis.map.qq.com$path');
        data = result.data is Map ? result.data as Map : const {};
      }
      if (requestId != _locationRequestId) return;
      final resultData = data['result'];
      final pois = resultData is Map && resultData['pois'] is List
          ? resultData['pois'] as List
          : const [];
      final first = pois.isNotEmpty && pois.first is Map ? pois.first : null;
      final formatted =
          resultData is Map && resultData['formatted_addresses'] is Map
          ? resultData['formatted_addresses'] as Map
          : const {};
      final recommend = '${formatted['recommend'] ?? ''}'.trim();
      final address = resultData is Map
          ? '${resultData['address'] ?? ''}'.trim()
          : '';
      final poiTitle = first is Map ? '${first['title'] ?? ''}'.trim() : '';
      final poiAddress = first is Map ? '${first['address'] ?? ''}'.trim() : '';
      final desc = [
        recommend,
        address,
        poiTitle,
        poiAddress,
      ].firstWhere((value) => value.isNotEmpty, orElse: () => '');
      if (desc.trim().isNotEmpty) location['desc'] = desc.trim();
      if (!mounted) return;
      setState(() => response = result);
    } catch (error) {
      debugPrint('腾讯地图逆地理编码失败: $error');
      if (mounted) setState(() => response = null);
    }
  }

  void _onMapPositionChanged(geo.LatLng position) {
    latLng = position;
    getLocation(position.latitude, position.longitude);
  }

  void _location(Location current) {
    setState(() => isLocation = false);
    _controller?.moveCamera(
      CameraPosition(position: current.position, zoom: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TencentMap(
                    compassEnabled: false,
                    myLocationEnabled: isLocation,
                    userLocationType: UserLocationType.noTracking,
                    onLocation: (current) {
                      if (isLocation) _location(current);
                    },
                    onMapCreated: (controller) {
                      _controller = controller;
                    },
                    onCameraMoveEnd: (position) {
                      final point = position.position;
                      if (point != null) {
                        _onMapPositionChanged(point);
                      }
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0),
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("取消", style: FontStyleUtils.whiteTitle).withOnTap(
                          () {
                            backPage(context);
                          },
                        ),
                        ContainerUtils(
                          height: 32,
                          padding: [12, 12, 4, 4],
                          radius: 4,
                          color: Colors.green,
                          child: Text("发送", style: FontStyleUtils.whiteTitle),
                        ).withOnTap(() async {
                          final desc = (location['desc'] as String).trim();
                          if (desc.isEmpty) {
                            showToast('正在获取当前位置，请稍后再试');
                            return;
                          }
                          final message = await ChatUtil.sendLocation(
                            desc: desc,
                            longitude: location['longitude'],
                            latitude: location['latitude'],
                            receiver: widget.groupID?.isNotEmpty != true
                                ? widget.receiver
                                : null,
                            groupID: widget.groupID?.isNotEmpty == true
                                ? widget.groupID
                                : null,
                          );
                          if (context.mounted) backPage(context, message);
                        }),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 32,
                ).withCenter().withPadding(padding: [0, 0, 0, 16]),
              ],
            ),
          ),
          _pois.isEmpty
              ? Center(
                  child: Text(
                    "加载中，如长时间加载，请查看位置权限是否开启。",
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(18),
                  itemBuilder: (context, index) {
                    final poi = _pois[index];
                    return Container(
                      color: Color.fromRGBO(245, 245, 245, 1),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${poi['title'] ?? ''}',
                                style: FontStyleUtils.blackTitle,
                              ),
                              Text(
                                '${poi['address'] ?? ''}',
                                style: FontStyleUtils.graySmallBody,
                                maxLines: 2,
                              ),
                            ],
                          ).withExpanded(),
                          currentIndex == index
                              ? Icon(Icons.check, size: 24, color: Colors.green)
                              : SizedBox(width: 24),
                        ],
                      ),
                    ).withOnTap(() {
                      _locationRequestId++;
                      setState(() {
                        currentIndex = index;
                        final poi =
                            response!.data['result']['pois'][index] as Map;
                        final title = '${poi['title'] ?? ''}'.trim();
                        final address = '${poi['address'] ?? ''}'.trim();
                        location['desc'] = [
                          title,
                          address,
                        ].where((value) => value.isNotEmpty).join(' ');
                        location['longitude'] = latLng?.longitude ?? 0.0;
                        location['latitude'] = latLng?.latitude ?? 0.0;
                      });
                    });
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: _pois.length,
                ).withExpanded(),
        ],
      ),
    );
  }
}
