import '../../widgets/community/file_section.dart';

class AttachmentStore {
  static final AttachmentStore _instance = AttachmentStore._internal();
  factory AttachmentStore() => _instance;
  AttachmentStore._internal();

  final List<FileAttachment> _attachments = [];

  List<FileAttachment> get attachments => List.unmodifiable(_attachments);

  void add(FileAttachment attachment) {
    _attachments.insert(0, attachment);
  }

  void addAll(List<FileAttachment> list) {
    _attachments.insertAll(0, list);
  }

  void removeWhere(bool Function(FileAttachment) test) {
    _attachments.removeWhere(test);
  }

  void clear() {
    _attachments.clear();
  }
}
