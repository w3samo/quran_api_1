import 'dart:convert';

import 'package:flutter/services.dart';

class JsonHelper {
  Future<dynamic> readJson() async {
    final String response =
        await rootBundle.loadString('assets/hafs_smart_v8.json');
    final data = await json.decode(response);

    return data;
  }
}
