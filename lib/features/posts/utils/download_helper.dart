import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class DownloadHelper {
  static Future<void> downloadAndSaveImage(BuildContext context, String url, String filename) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Web test mode: Downloading disabled (Requires Android/iOS).')),
      );
      return;
    }

    try {
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied.')),
            );
          }
          return;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading image...')),
        );
      }

      final tempDir = await getTemporaryDirectory();
      final savePath = '${tempDir.path}/$filename';

      await Dio().download(url, savePath);
      await Gal.putImage(savePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  static void showDownloadDialog(BuildContext context, String url, String filename) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: const Text('是否下载图片？(Download original image?)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('否 (No)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                downloadAndSaveImage(context, url, filename);
              },
              child: const Text('是 (Yes)'),
            ),
          ],
        );
      },
    );
  }
}
