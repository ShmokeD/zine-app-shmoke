import 'package:drift/drift.dart';
import '../database.dart';
import 'package:zineapp2023/utilities/custom_logger.dart';

part 'room_dao.g.dart';

final logger = customLogger();

@DriftAccessor(tables: [RoomsTable])
class RoomDao extends DatabaseAccessor<AppDb> with _$RoomDaoMixin {
  RoomDao(AppDb db) : super(db);

  Future<int> insertRoomToDB(RoomsTableCompanion room) async {
    try {
      final existingRoom = await (select(roomsTable)
            ..where((t) => t.id.equals(room.id.value)))
          .getSingleOrNull();
      int insertedId;
      if (existingRoom != null) {
        insertedId =
            await into(roomsTable).insert(room, mode: InsertMode.replace);
        logger.d('Room updated successfully with ID: $insertedId');
      } else {
        insertedId = -1;
        await into(roomsTable).insert(room, mode: InsertMode.insert);
        logger.d('Room inserted successfully with ID: ${room.id}');
      }
      return insertedId;
    } catch (e) {
      logger.e('Error inserting room');
      return -1;
    }
  }

  Future<List<Room>> getAllRoomsDB() async {
    try {
      final rooms = await select(roomsTable).get();
      if (rooms.isNotEmpty) {
        logger.d('Successfully fetched ${rooms.length} rooms');
      } else {
        logger.d('No rooms found in the database');
      }
      return rooms;
    } catch (e) {
      logger.e('Error fetching rooms: $e');
      return [];
    }
  }

  Future<List<Room>> getAllProjectsDB() async {
    try {
      final rooms = await select(roomsTable).get();
      final projects =
          rooms.where((room) => room.type != 'announcement').toList();

      if (projects.isNotEmpty) {
        logger.d('Successfully fetched ${projects.length} projects');
      } else {
        logger.d('No projects found in the database');
      }

      return projects;
    } catch (e) {
      logger.e('Error fetching projects: $e');
      return [];
    }
  }

  Future<List<Room>> getAllAnnouncementsDB() async {
    try {
      final rooms = await select(roomsTable).get();
      final announcements =
          rooms.where((room) => room.type == 'announcement').toList();
      logger.d("Number of announcements is ${announcements.length}");
      if (announcements.isNotEmpty) {
        logger.d('Successfully fetched ${announcements.length} announcements');
      } else {
        logger.d('No announcements found in the database');
      }

      return announcements;
    } catch (e) {
      logger.e('Error fetching announcements: $e');
      return [];
    }
  }

  Future<int> deleteUnsyncedRooms() async {
    try {
      final unsyncedRooms = await (select(roomsTable)
            ..where((t) => t.isSynced.equals(false)))
          .get();
      if (unsyncedRooms.isNotEmpty) {
        for (var room in unsyncedRooms) {
          logger.d("Deleting unsynced room with ID: ${room.id}");
        }
        await (delete(roomsTable)..where((t) => t.isSynced.equals(false))).go();
        logger.d("Successfully deleted unsynced rooms");
        return -1;
      } else {
        logger.d("No unsynced rooms found to delete.");
        return 0;
      }
    } catch (e) {
      logger.e("Error in deleting unsynced rooms: $e");
      return 0;
    }
  }

  Future<void> initializeIsSyncedColumn() async {
    try {
      await (update(roomsTable)).write(
      const RoomsTableCompanion(
        isSynced: Value(false),
      ),
      );

      logger.d("All rooms updated to unsynced (isSynced = FALSE).");
    } catch (e) {
      logger.e("Error initializing isSynced column: $e");
    }
  }
}
