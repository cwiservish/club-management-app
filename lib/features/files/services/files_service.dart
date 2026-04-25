import '../models/file_item.dart';

class FilesService {
  List<FileItem> getFiles() {
    return const [
      FileItem(
        id: '1',
        name: 'Tournament Rules 2026.pdf',
        size: '2.4 MB',
        date: 'Mar 12, 2026',
      ),
      FileItem(
        id: '2',
        name: 'Parent Code of Conduct.pdf',
        size: '1.1 MB',
        date: 'Jan 15, 2026',
      ),
      FileItem(
        id: '3',
        name: 'Spring Schedule Final.xlsx',
        size: '450 KB',
        date: 'Feb 28, 2026',
      ),
    ];
  }
}
