import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bookmark_event.dart';
import 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  BookmarkBloc() : super(const BookmarkState()) {
    on<LoadPdfEvent>(_onLoadPdf);
    on<AddPageBookmark>(_onAddPageBookmark);
    on<AddLineBookmark>(_onAddLineBookmark);
    on<RemoveBookmark>(_onRemoveBookmark);
    on<ClearBookmarks>(_onClearBookmarks);
    _restoreBookmarks();  // Restore bookmarks when BLoC is initialized
  }

  void _onLoadPdf(LoadPdfEvent event, Emitter<BookmarkState> emit) {
    emit(state.copyWith(pdfPath: event.pdfPath));
    // Navigate to last bookmarked page if available
    _goToLastBookmark(); 
  }

  void _onAddPageBookmark(AddPageBookmark event, Emitter<BookmarkState> emit) async {
    final updatedBookmarks = Map<int, Set<int>>.from(state.pageBookmarks);
    updatedBookmarks[event.pageIndex] = {0}; // Add a new bookmark at index 0
    emit(state.copyWith(pageBookmarks: updatedBookmarks));
    await _savePageBookmark(updatedBookmarks);
  }

  void _onAddLineBookmark(AddLineBookmark event, Emitter<BookmarkState> emit) async {
    final updatedLineBookmarks = Map<int, Set<int>>.from(state.lineBookmarks);
    final lines = updatedLineBookmarks[event.pageIndex] ?? <int>{};
    lines.add(event.lineIndex);
    updatedLineBookmarks[event.pageIndex] = lines;
    emit(state.copyWith(lineBookmarks: updatedLineBookmarks));
    await _saveLineBookmark(updatedLineBookmarks);
  }

  void _onRemoveBookmark(RemoveBookmark event, Emitter<BookmarkState> emit) async {
    if (event.lineIndex == null) {
      final updatedBookmarks = Map<int, Set<int>>.from(state.pageBookmarks);
      updatedBookmarks.remove(event.pageIndex);
      emit(state.copyWith(pageBookmarks: updatedBookmarks));
      await _savePageBookmark(updatedBookmarks);
    } else {
      final updatedLineBookmarks = Map<int, Set<int>>.from(state.lineBookmarks);
      final lines = updatedLineBookmarks[event.pageIndex];
      if (lines != null) {
        lines.remove(event.lineIndex);
        if (lines.isEmpty) {
          updatedLineBookmarks.remove(event.pageIndex);
        } else {
          updatedLineBookmarks[event.pageIndex] = lines;
        }
        emit(state.copyWith(lineBookmarks: updatedLineBookmarks));
        await _saveLineBookmark(updatedLineBookmarks);
      }
    }
  }

  void _onClearBookmarks(ClearBookmarks event, Emitter<BookmarkState> emit) async {
    emit(state.copyWith(pageBookmarks: {}, lineBookmarks: {}));
    await _clearAllBookmarks();
  }

  // Helper methods for persistence
  Future<void> _savePageBookmark(Map<int, Set<int>> pageBookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = pageBookmarks.keys.map((page) => page.toString()).toList();
    await prefs.setStringList('pageBookmarks', bookmarks);
  }

  Future<void> _saveLineBookmark(Map<int, Set<int>> lineBookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in lineBookmarks.entries) {
      final pageIndex = entry.key;
      final lines = entry.value.map((line) => line.toString()).toList();
      await prefs.setStringList('lineBookmarks_$pageIndex', lines);
    }
  }

  Future<void> _clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pageBookmarks');
    final keys = prefs.getKeys().where((key) => key.startsWith('lineBookmarks_')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> _restoreBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final pageBookmarks = prefs.getStringList('pageBookmarks')?.map(int.parse).toSet() ?? {};
    final lineBookmarks = <int, Set<int>>{};

    for (var pageIndex in pageBookmarks) {
      final lines = prefs.getStringList('lineBookmarks_$pageIndex')?.map(int.parse).toSet() ?? {};
      lineBookmarks[pageIndex] = lines;
    }

    emit(state.copyWith(
      pageBookmarks: Map.fromIterable(pageBookmarks, key: (e) => e, value: (e) => <int>{}),
      lineBookmarks: lineBookmarks,
    ));
  }

  Future<void> _goToLastBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPageIndex = prefs.getInt('lastPageIndex');
    final lastLineIndex = prefs.getInt('lastLineIndex');

    if (lastPageIndex != null) {
      add(AddPageBookmark(lastPageIndex));
      if (lastLineIndex != null) {
        add(AddLineBookmark(lastPageIndex, lastLineIndex));
      }
    }
  }
}
