import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:zineapp2023/utilities/custom_logger.dart';

import 'dao/user_dao.dart';
import 'dao/room_dao.dart';
import 'dao/room_member_dao.dart';

part 'database.g.dart';

final logger = customLogger();

@DataClassName('Room')
class RoomsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get dpUrl => text().nullable()();
  IntColumn get timestamp => integer().nullable()();
  IntColumn get lastMessageTimestamp => integer().nullable()();
  IntColumn get unreadMessages => integer().nullable()();
  IntColumn get userLastSeen => integer().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserDB')
class UsersTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant('Anonymous'))();
  TextColumn get email => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get pushToken => text().nullable()();
  BoolColumn get registered => boolean().withDefault(const Constant(false))();
  TextColumn get dp => text().withDefault(const Constant(''))();
  BoolColumn get emailVerified => boolean().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoomMemberDB')
class RoomMemberTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().withDefault(const Constant('Anonymous'))();
  TextColumn get email => text().nullable()();
  TextColumn get role => text().nullable()();
  BoolColumn get registered => boolean().withDefault(const Constant(false))();
  TextColumn get dpUrl => text().withDefault(const Constant(''))();
  BoolColumn get emailVerified => boolean().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RoomMemberMapping')
class RoomMemberMappingTable extends Table {
  IntColumn get roomId =>
      integer().customConstraint('REFERENCES rooms_table(id) NOT NULL')();
  IntColumn get memberId =>
      integer().customConstraint('REFERENCES room_member_table(id) NOT NULL')();

  @override
  Set<Column> get primaryKey => {roomId, memberId};
}

@DataClassName('MessageDB')
class MessagesTable extends Table {
  IntColumn get id => integer()();
  TextColumn get type => text()();
  TextColumn get textData => text().nullable()();
  IntColumn get fileId =>
      integer().nullable().customConstraint('REFERENCES file_table(id)')();
  IntColumn get pollId =>
      integer().nullable().customConstraint('REFERENCES poll_table(id)')();
  IntColumn get timestamp => integer().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get roomId =>
      integer().nullable().customConstraint('REFERENCES rooms_table(id)')();
  IntColumn get sentFromId =>
      integer().customConstraint('REFERENCES room_member_table(id) NOT NULL')();
  IntColumn get replyToId =>
      integer().nullable().customConstraint('REFERENCES messages_table(id)')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PollDB')
class PollTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get lastVoted => integer().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PollOptionDB')
class PollOptionTable extends Table {
  IntColumn get pollId =>
      integer().customConstraint('REFERENCES poll_table(id) NOT NULL')();
  IntColumn get id => integer()();
  TextColumn get value => text()();
  IntColumn get numVotes => integer()();
  BoolColumn get isVoted => boolean().withDefault(const Constant(false))();
  BoolColumn get voterId => boolean().withDefault(const Constant(false))();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FileDB')
class FileTable extends Table {
  IntColumn get id => integer()();
  TextColumn get uri => text()();
  TextColumn get filePath => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get name => text()();
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    RoomsTable,
    MessagesTable,
    UsersTable,
    FileTable,
    PollTable,
    PollOptionTable,
    RoomMemberTable,
    RoomMemberMappingTable
  ],
  daos: [
    UserDao,
    RoomDao,
    RoomMemberDao,
    // Add other DAOs here
  ]
)
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());
  @override
  int get schemaVersion => 1;


  static Future<void> deleteLocalDb(AppDb db) async {
    try {

      await db.batch((batch) {
        batch.deleteAll(db.roomsTable);
        batch.deleteAll(db.messagesTable);
        batch.deleteAll(db.usersTable);
        batch.deleteAll(db.fileTable);
        batch.deleteAll(db.pollTable);
        batch.deleteAll(db.pollOptionTable);
        batch.deleteAll(db.roomMemberTable);
      });
      logger.d("Local DB Cleared");
    } catch (e) {
      logger.e("Error clearing tables: $e");
    }
  }

  static LazyDatabase _openConnection() {
    logger.d("Initializing LazyDatabase connection...");
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'app.db'));
      if (await file.exists()) {
        logger.i("Old database present.");
      }
      return NativeDatabase(file);
    });
  }
}
