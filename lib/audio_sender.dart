import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';

// Audio file must be opus ogg
// Reference: https://gist.github.com/HDR/7d5d4ce8bbe4b715d788a9bc9f99e02d#Waveform-Example
Future<void> sendAudio(
  DotEnv env,
  String channelID,
  File file, [
  int durationSecs = 9,
]) async {
  Map<String, String> headers([String contentType = 'application/json']) => {
        'Authorization': 'Bot ${env['DISCORD_TOKEN']}',
        'Content-Type': contentType
      };

  final {'upload_url': audioURL, 'upload_filename': audioFilename} =
      jsonDecode((await post(
    Uri.https('discord.com', '/api/v10/channels/$channelID/attachments'),
    headers: headers(),
    body: jsonEncode({
      'files': [
        {'filename': 'audio.ogg', 'file_size': await file.length(), 'id': 2}
      ]
    }),
  ))
          .body)['attachments'][0];

  await put(
    Uri.parse(audioURL),
    body: file.readAsBytesSync(),
    headers: headers('audio/ogg'),
  );

  await post(
    Uri.https('discord.com', '/api/v10/channels/$channelID/messages'),
    headers: headers(),
    body: jsonEncode({
      'flags': 8192,
      'attachments': [
        {
          'id': 0,
          'filename': 'audio.ogg',
          'uploaded_filename': audioFilename,
          'duration_secs': durationSecs,
          'waveform':
              'acU6Va9UcSVZzsVw7IU/80s0Kh/pbrTcwmpR9da4mvQejIMykkgo9F2FfeCd235K/atHZtSAmxKeTUgKxAdNVO8PAoZq1cHNQXT/PHthL2sfPZGSdxNgLH0AuJwVeI7QZJ02ke40+HkUcBoDdqGDZeUvPqoIRbE23Kr+sexYYe4dVq+zyCe3ci/6zkMWbVBpCjq8D8ZZEFo/lmPJTkgjwqnqHuf6XT4mJyLNphQjvFH9aRqIZpPoQz1sGwAY2vssQ5mTy5J5muGo+n82b0xFROZwsJpumDsFi4Da/85uWS/YzjY5BdxGac8rgUqm9IKh7E6GHzOGOy0LQIz3O4ntTg==', // TODO: get waveform from audio (needs to be base64 encoded byte array of 256 entries)
        },
      ],
    }),
  );
}
