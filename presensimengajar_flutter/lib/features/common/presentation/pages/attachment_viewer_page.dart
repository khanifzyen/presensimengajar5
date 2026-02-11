import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class AttachmentViewerPage extends StatefulWidget {
  final String url;
  final String fileName;
  final bool isPdf;

  const AttachmentViewerPage({
    super.key,
    required this.url,
    required this.fileName,
    required this.isPdf,
  });

  @override
  State<AttachmentViewerPage> createState() => _AttachmentViewerPageState();
}

class _AttachmentViewerPageState extends State<AttachmentViewerPage> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPdf) {
      _downloadFileForPreview();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadFileForPreview() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.fileName}');

      await Dio().download(widget.url, file.path);

      if (mounted) {
        setState(() {
          _localPath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat file: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveToGalleryOrDownloads() async {
    setState(() => _isDownloading = true);
    try {
      if (Platform.isAndroid && !widget.isPdf && !await Gal.hasAccess()) {
        await Gal.requestAccess();
      }

      var dio = Dio();

      if (widget.isPdf) {
        // Save PDF to external Download directory
        Directory? downloadDir;
        if (Platform.isAndroid) {
          downloadDir = Directory('/storage/emulated/0/Download');
          if (!await downloadDir.exists()) {
            downloadDir = await getExternalStorageDirectory();
          }
        } else {
          downloadDir = await getApplicationDocumentsDirectory();
        }

        String savePath = '${downloadDir?.path}/${widget.fileName}';
        await dio.download(widget.url, savePath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File disimpan di $savePath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Save Image to Gallery using Gal
        var response = await dio.get(
          widget.url,
          options: Options(responseType: ResponseType.bytes),
        );
        await Gal.putImageBytes(
          Uint8List.fromList(response.data),
          name: widget.fileName,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar disimpan di Galeri'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName, style: const TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _saveToGalleryOrDownloads,
            tooltip: 'Download',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (widget.isPdf) {
      if (_localPath != null) {
        return PDFView(
          filePath: _localPath,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          onError: (error) {
            debugPrint(error.toString());
          },
          onPageError: (page, error) {
            debugPrint('$page: ${error.toString()}');
          },
        );
      } else {
        return const Center(child: Text('Gagal memuat PDF'));
      }
    } else {
      // Image
      return Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            widget.url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                Text('Gagal memuat gambar'),
              ],
            ),
          ),
        ),
      );
    }
  }
}
