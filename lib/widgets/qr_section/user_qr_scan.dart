import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jadwal/mosques/profile/user_mosque_profile.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}): super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose(){
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            buildQrView(context),
            Positioned(bottom:100, child: buildReslt()),
            Positioned(top:80, child: buildControlButton()),
          ],
        )
      ),
  );

  Widget buildReslt() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white24,
      borderRadius: BorderRadius.circular(8)
    ),
    child: const Text("Scan Mosque QR Code!"));

  Widget buildControlButton() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8)
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
            onPressed: ()async{
              await controller?.toggleFlash();
              setState(() {});
            },
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot){
                if(snapshot.data != null){
                  return Icon(
                    snapshot.data! ? Icons.flash_on:Icons.flash_off
                  );
                }
                else {
                  return Container();
                }
              },
            ),)
      ],
    ),
  );

  Widget buildQrView(BuildContext context)=>QRView(
      key: qrKey,
      onQRViewCreated: onQRViewCreated,
    overlay: QrScannerOverlayShape(
      borderRadius: 10,
      borderLength: 20,
      borderWidth: 10,
      borderColor: Colors.greenAccent,
      cutOutSize: MediaQuery.of(context).size.width * 0.8,
    ),
  );

  void onQRViewCreated(QRViewController controller){
    (() => this.controller= controller);

    controller.scannedDataStream.listen((barcode) {
      Get.to(()=>UserMosqueProfile(mosqueId: int.parse(barcode.code.toString())));
    });
  }


}
