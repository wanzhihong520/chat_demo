import 'package:chat_demo/import.dart' hide LatLng;
import 'package:tencent_map_flutter/tencent_map_flutter.dart' hide Position;
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  TencentMapController? _controller;
  @override
  void initState() {
    super.initState();
  }

  void _initData() async {
    _controller?.moveCamera(
      CameraPosition(
        position: LatLng(
          UserPro.position!.latitude,
          UserPro.position!.longitude,
        ),
        zoom: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: SizedBox(
                  width: double.infinity,
                  child: TencentMap(
                    onMapCreated: (TencentMapController controller) {
                      _controller = controller;
                      _initData();
                    },
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 100, color: Colors.black.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }
}
