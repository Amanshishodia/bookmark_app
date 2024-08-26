import 'dart:io';
import 'package:bookmarkpdf/screens.dart/bookmarkManagement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:bookmarkpdf/bloc/bookmark_bloc.dart';
import 'package:bookmarkpdf/bloc/bookmark_event.dart';
import 'package:bookmarkpdf/bloc/bookmark_state.dart';

class PDFViewerScreen extends StatefulWidget {
  final int? initialPageNumber;  // Add this line

  const PDFViewerScreen({super.key, this.initialPageNumber}); // Add this line

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfViewerController _pdfViewerController;
  late BookmarkBloc _bookmarkBloc;
  int? _lastPageNumber;

  @override
  void initState() {
    super.initState();
    _bookmarkBloc = BlocProvider.of<BookmarkBloc>(context);
    _pdfViewerController = PdfViewerController();

    _bookmarkBloc.stream.listen((state) {
      if (state.pdfPath != null) {
        _restorePageAndLine(state);
      }
    });
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _restorePageAndLine(BookmarkState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.pageBookmarks.isNotEmpty) {
        final lastPageIndex = state.pageBookmarks.keys.lastOrNull;
        if (lastPageIndex != null) {
          _pdfViewerController.jumpToPage(lastPageIndex);
        }
      }
    });
  }

  void _handlePageChanged(int pageNumber) {
    if (pageNumber != _lastPageNumber) {
      _lastPageNumber = pageNumber;
    }
  }

  void _bookmarkCurrentPage() {
    if (_lastPageNumber != null) {
      BlocProvider.of<BookmarkBloc>(context).add(AddPageBookmark(_lastPageNumber!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Page ${_lastPageNumber!} bookmarked')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showBookmarkList,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _bookmarkCurrentPage,
          ),
        ],
      ),
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          if (state.pdfPath == null) {
            return Center(child: Text('No PDF Loaded'));
          }

          return SfPdfViewer.file(
            File(state.pdfPath!),
            controller: _pdfViewerController,
            onPageChanged: (PdfPageChangedDetails details) {
              final pageNumber = details.newPageNumber;
              if (pageNumber != null) {
                _handlePageChanged(pageNumber);
              }
            },
            onDocumentLoadFailed: (exception) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load document')),
              );
            },
            onDocumentLoaded: (details) {
              if (widget.initialPageNumber != null) {
                _pdfViewerController.jumpToPage(widget.initialPageNumber!);
              }
            },
          );
        },
      ),
    );
  }

  void _showBookmarkList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookmarkScreen()),
    );
  }
}
