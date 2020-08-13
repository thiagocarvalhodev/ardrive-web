import 'package:moor/moor.dart';

@DataClassName('FolderEntry')
class FolderEntries extends Table {
  TextColumn get id => text()();
  TextColumn get driveId => text().customConstraint('REFERENCES drives(id)')();
  TextColumn get parentFolderId =>
      text().nullable().customConstraint('REFERENCES folderEntries(id)')();

  TextColumn get name => text().withLength(min: 1)();
  TextColumn get path => text().withLength(min: 1)();

  /// Whether or not this folder has been hydrated entries that are earlier than the drive's latest state block number.
  BoolColumn get hydratedWithInitialEntries => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
