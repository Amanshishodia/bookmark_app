import 'package:bookmarkpdf/screens.dart/pdf_Viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookmarkpdf/bloc/bookmark_bloc.dart';
import 'package:bookmarkpdf/bloc/bookmark_event.dart';
import 'package:bookmarkpdf/bloc/bookmark_state.dart';


class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
      ),
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          final pageBookmarks = state.pageBookmarks.keys.toList();
          if (pageBookmarks.isEmpty) {
            return Center(child: Text('No bookmarks available'));
          }

          return ListView.builder(
            itemCount: pageBookmarks.length,
            itemBuilder: (context, index) {
              final pageIndex = pageBookmarks[index];
              return ListTile(
                title: Text('Page $pageIndex'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PDFViewerScreen(
                        initialPageNumber: pageIndex, // Pass the page number
                      ),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    BlocProvider.of<BookmarkBloc>(context).add(
                      RemoveBookmark(pageIndex: pageIndex),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
