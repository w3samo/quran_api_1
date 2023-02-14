import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class TafseerService {
  Future<dynamic> getTafseer(
      {required String surahNum, required String ayahNum}) async {
    String url = 'http://api.quran-tafseer.com/tafseer/1/$surahNum/$ayahNum';

    http.Response response = await http.get(Uri.parse(url), headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.varyHeader: 'Origin, Accept-Language, Cookie'
    });

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      return null;
    }
  }
}
