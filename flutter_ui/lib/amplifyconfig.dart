import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String getAmplifyConfig() {
  return jsonEncode({
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "storage": {
      "plugins": {
        "awsS3StoragePlugin": {
          "bucket": dotenv.env['AWS_BUCKET_NAME'],
          "region": dotenv.env['AWS_REGION'],
          "defaultAccessLevel": "guest" // public / protected / private
        }
      }
    }
  });
}
