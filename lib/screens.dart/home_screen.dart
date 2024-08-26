import 'package:bookmarkpdf/bloc/bookmark_bloc.dart';
import 'package:bookmarkpdf/bloc/bookmark_event.dart';
import 'package:bookmarkpdf/screens.dart/pdf_Viewer_screen.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkForSavedPdf();
  }

  Future<void> _checkForSavedPdf() async {
    final prefs = await SharedPreferences.getInstance();
    final pdfPath = prefs.getString('lastPdfPath');

    if (pdfPath != null && pdfPath.isNotEmpty) {
      // Automatically load the saved PDF
      BlocProvider.of<BookmarkBloc>(context).add(LoadPdfEvent(pdfPath));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PDFViewerScreen()),
      );
    }
  }

  Future<void> savePdfAndBookmark(String pdfPath, int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPdfPath', pdfPath);
    await prefs.setInt('lastPageIndex', pageIndex);
  }

  Future<void> _selectPdf(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      String pdfPath = result.files.single.path!;

      // Save the PDF path when it's selected
      await savePdfAndBookmark(pdfPath, 0);

      // Dispatch the LoadPdfEvent
      BlocProvider.of<BookmarkBloc>(context).add(LoadPdfEvent(pdfPath));

      // Navigate to the PDF Viewer Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PDFViewerScreen()),
      );
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Load PDF'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _selectPdf(context),
          child: const Text('Select PDF from Device'),
        ),
      ),
    );
  }
}
