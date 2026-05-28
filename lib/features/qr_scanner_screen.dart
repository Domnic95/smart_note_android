import 'package:flutter/material.dart';
import 'package:note_app/Google_Ads/BannerAds/BannerAdManager.dart';
import 'package:note_app/Google_Ads/ShowAds.dart';
import 'package:note_app/styles/app_theme.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? result;
  bool _isScanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<bool> onBackPress({void Function()? callback}) async {
    return await ShowInterstitialAds()
        .showBackClickInterstitialAds(callback: callback);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPress(
        callback: () => Navigator.pop(context),
      ),
      child: Scaffold(
        bottomNavigationBar: const BannerAdManager(),
        appBar: AppBar(
          flexibleSpace:
              NotebookAppBarDecoration.flexibleSpaceForTheme(context),
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: const Text('QR Scanner'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 7,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: (result != null)
                    ? Text('Result: ${result!.code}')
                    : const Text('Scan a code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      if (_isScanned) return;

      _isScanned = true;

      await controller.pauseCamera();

      if (!mounted) return;

      setState(() {
        result = scanData;
      });

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(scanData.code);
      }
    });
  }
}
