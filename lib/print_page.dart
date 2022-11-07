
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrintScreen extends StatefulWidget {
  final String data;
  PrintScreen(this.data);

  @override
  _PrintScreenState createState() => _PrintScreenState();
}

class _PrintScreenState extends State<PrintScreen> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {initPrinter()});
  }

  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 2));

    if (!mounted) return;
    bluetoothPrint.scanResults.listen(
          (val) {
        if (!mounted) return;
        setState(() => {_devices = val});
        if (_devices.isEmpty)
          setState(() {
            _devicesMsg = "No Devices";
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Printer'),
       // backgroundColor: Colors.redAccent,
      ),
      body: _devices.isEmpty
          ? Center(
        child: Text(_devicesMsg ?? ''),
      )
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (c, i) {
          return ListTile(
            leading: Icon(Icons.print),
            title: Text(_devices[i].name ?? ''),
            subtitle: Text(_devices[i].address ?? '' ),
            onTap: () {
              _startPrint(_devices[i]);
            },
          );
        },
      ),
    );
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);

      Map<String, dynamic> config = Map();
      List<LineText> list = [];

      list.add(
        LineText(
          type: LineText.TYPE_TEXT,
          content: widget.data,
          align: LineText.ALIGN_RIGHT,
        ),
      );
      bluetoothPrint.printReceipt(config, list);
    }
  }
}
