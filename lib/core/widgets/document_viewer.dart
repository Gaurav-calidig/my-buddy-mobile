import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../utils/utils.dart';

/// Document viewer page for displaying PDF and image files.
/// 
/// Automatically detects file type from URL and renders appropriate
/// viewer (PDF viewer for PDFs, image viewer for images).
class DocumentViewerPage extends StatelessWidget {

  const DocumentViewerPage({
    super.key,
    required this.url,
  });
  
  /// URL of the document to display
  final String url;

  @override
  Widget build(BuildContext context) {
    // Determine file type from URL to choose appropriate viewer
    final type = AppUtils.getFileTypeFromUrl(url);

    final isImage = type == 'image' ;
    final isPdf = type == 'pdf';

    return Scaffold(
      appBar: AppBar(
        title:  Text("Document Viewer"),
      ),
      body: isImage
          ? _buildImageView(context)
          : isPdf
          ? _buildPdfView(context)
          : Center(child: Text("Something Went Wrong")), // Fallback for unsupported types
    );
  }

  /// Builds image viewer with network image display.
  Widget _buildImageView(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        image: DecorationImage(image: NetworkImage(url)),
      ),
    );

  /// Builds PDF viewer using Syncfusion PDF viewer widget.
  Widget _buildPdfView(BuildContext context) => SfPdfViewer.network(url);
}
