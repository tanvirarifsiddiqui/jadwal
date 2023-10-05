import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
class QRMosqueGenerated extends StatelessWidget {
  final int mosqueId;
  const QRMosqueGenerated({Key? key, required this.mosqueId}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade500,
      appBar: AppBar(
        title: const Text("QR Code for this mosque"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImage(
                  data: mosqueId.toString(),
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 40,),
              const Text("Scan this QR code to find Desired Mosque",style: TextStyle(color: Colors.white),)
            ],
          ),
        ),
      ),
    );
  }
}
