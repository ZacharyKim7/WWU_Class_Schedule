/*
**  Purpose: To grab the raw HTML document from 
*/

//"flutter pub add http" if you are missing the package from your environment.
//Note ios and android need permissions if developing for that.

import 'dart:async';
import 'package:http/http.dart' as http;

Future<String> fetchHtml() async {
  const String url =
      'https://classopen.wallawalla.edu/classopenps.php?strm=f2024&submit=Search';
  final response = await http.get(Uri.parse(url));
  return response.body;
}
