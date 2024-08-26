// ignore_for_file: public_member_api_docs, sort_constructors_first
// bookmark_event.dart

import 'package:equatable/equatable.dart';

abstract  class BookmarkEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoadPdfEvent extends BookmarkEvent {
  final String pdfPath;

  LoadPdfEvent(
    this.pdfPath,
  );

  @override
  List<Object?> get props => [pdfPath];
}

class AddPageBookmark extends BookmarkEvent {
  final int pageIndex;

  AddPageBookmark(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class AddLineBookmark extends BookmarkEvent {
  final int pageIndex;
  final int lineIndex;

   AddLineBookmark(this.pageIndex, this.lineIndex);

  @override
  List<Object?> get props => [pageIndex, lineIndex];
}

class RemoveBookmark extends BookmarkEvent {
  final int pageIndex;
  final int? lineIndex;

  RemoveBookmark({required this.pageIndex, this.lineIndex});

  @override
  List<Object?> get props => [pageIndex, lineIndex];
}

class ClearBookmarks extends BookmarkEvent {
   ClearBookmarks();

  @override
  List<Object?> get props => [];
}
