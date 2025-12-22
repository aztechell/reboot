import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ImageService {
  ImageService({required this.apiKey});

  final String apiKey;

  /// Calls Stability API to edit the image with provided prompts.
  Future<Uint8List> processImage({
    required Uint8List imageBytes,
    required String searchPrompt,
    required String prompt,
    required String negativePrompt,
  }) async {
    final url = Uri.parse('https://api.stability.ai/v2beta/stable-image/edit/search-and-replace');

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll({
        'authorization': 'Bearer $apiKey',
        'accept': 'image/*',
      })
      ..files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'input.png'))
      ..fields['search_prompt'] = searchPrompt
      ..fields['prompt'] = prompt
      ..fields['negative_prompt'] = negativePrompt
      ..fields['output_format'] = 'jpeg';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw ImageProcessException(response.statusCode, response.body);
  }
}

class ImageProcessException implements Exception {
  ImageProcessException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ImageProcessException($statusCode): $body';
}
