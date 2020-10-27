import 'dart:io' as io;
import 'dart:ui';
import 'dart:isolate';

import 'package:boorusama/application/posts/post_download/file_name_generator.dart';
import 'package:boorusama/application/posts/post_download/i_download_service.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadService implements IDownloadService {
  final FileNameGenerator fileNameGenerator;

  DownloadService(this.fileNameGenerator);

  ReceivePort _port = ReceivePort();
  bool _permissionReady;
  String _localPath;
  String _savedDir;

  @override
  void download(Post post, String url) async {
    final filePath = fileNameGenerator.generateFor(post, url);
    final exist = await io.File(filePath).exists();

    if (exist) return;

    await FlutterDownloader.enqueue(
        url: url,
        fileName: filePath,
        savedDir: _savedDir,
        showNotification: true,
        openFileFromNotification: true);
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    final savedDir = io.Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    _savedDir = savedDir.path;
  }

  Future<bool> _checkPermission(TargetPlatform platform) async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      // final task = _tasks?.firstWhere((task) => task.taskId == id);
      // if (task != null) {
      //   setState(() {
      //     task.status = status;
      //     task.progress = progress;
      //   });
      // }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @override
  Future<Null> init(TargetPlatform platform) async {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);

    _permissionReady = false;
    final directory = platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    _localPath = directory.path + io.Platform.pathSeparator + 'Download';
    _permissionReady = await _checkPermission(platform);

    _prepare();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
  }
}
