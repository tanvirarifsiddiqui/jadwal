
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:jadwal/users/searches/search_mosque.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MapAndSearchFragmentScreen extends StatefulWidget {
  const MapAndSearchFragmentScreen({super.key});

  @override
  State<MapAndSearchFragmentScreen> createState() => _MapAndSearchFragmentScreenState();
}

class _MapAndSearchFragmentScreenState extends State<MapAndSearchFragmentScreen> {
  late final WebViewController _controller;

  //Requesting Location Permission
  // bool locationEnabled = false;
  Future<void> requestLocationPermission() async {
    final LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        // Location services are not enabled, ask the user to enable them.
        return;
      }

      // Request location permission.
      final LocationPermission requestedPermission =
      await Geolocator.requestPermission();
      if (requestedPermission == LocationPermission.always) {
        // Permission granted, you can now access the user's location.
        // You can use Geolocator to get the user's current location.
      } else {
        // Permission denied, handle it accordingly.
      }
    } else if (permission == LocationPermission.always) {
      // Permission has already been granted.
      // You can use Geolocator to get the user's current location.
    }
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com/maps/search/mosques'));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.brown.shade800,
        title: SizedBox(
          height: 38,
          child:GestureDetector(
            onTap: () {
              Get.to(()=>SearchMosqueScreen());
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.brown[900],
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.brown.shade200,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Search mosques in Jadwal",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ),


        ),
      ),
      body: WebViewWidget(controller: _controller),
        bottomNavigationBar: BottomAppBar(
          color: Colors.brown.shade900,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              const SizedBox(width: 16,),
              Text('Mosques in Map',style: TextStyle(fontSize: 22,fontWeight: FontWeight.w500,color: Colors.brown.shade200)),
              const Spacer(),
              NavigationControls(webViewController: _controller),
              // Add any other bottom bar elements here
            ],
          ),
        )
    );
  }
}

  // bottom navigation control
class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: Colors.grey,),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios,color: Colors.grey),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay,color: Colors.grey),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }
}
