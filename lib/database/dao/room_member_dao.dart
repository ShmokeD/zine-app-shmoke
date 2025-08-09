import 'package:drift/drift.dart';
import '../database.dart';
import 'package:zineapp2023/utilities/custom_logger.dart';
import 'package:zineapp2023/models/newUser.dart';

part 'room_member_dao.g.dart';

final logger = customLogger();

@DriftAccessor(tables: [RoomMemberTable, RoomMemberMappingTable])
class RoomMemberDao extends DatabaseAccessor<AppDb> with _$RoomMemberDaoMixin {
  RoomMemberDao(super.db);

  Future<RoomMemberDB?> fetchRoomMemberById(int memberId) async {
    return (select(roomMemberTable)..where((tbl) => tbl.id.equals(memberId)))
        .getSingleOrNull();
  }

  Future<void> saveRoomMemberMapping(int roomId, List<int> memberIds) async {
    try {
      await batch((batch) {
        for (final memberId in memberIds) {
          batch.insert(
            roomMemberMappingTable,
            RoomMemberMappingTableCompanion.insert(
              roomId: roomId,
              memberId: memberId,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
      logger.d("Room member mappings saved successfully for room ID: $roomId");
    } catch (e) {
      logger.e("Error saving room member mappings: $e");
    }
  }

  Future<Map<String, RoomMemberModel>> getRoomMembersByRoomId(
      int roomId) async {
    try {
      final query = select(roomMemberTable).join([
        innerJoin(
          roomMemberMappingTable,
          roomMemberMappingTable.memberId.equalsExp(roomMemberTable.id),
        )
      ])
        ..where(roomMemberMappingTable.roomId.equals(roomId));

      final results = await query.get();

      final roomMembersMap = {
        for (var row in results)
          row.readTable(roomMemberTable).id.toString(): RoomMemberModel(
            id: row.readTable(roomMemberTable).id,
            name: row.readTable(roomMemberTable).name,
            email: row.readTable(roomMemberTable).email,
            role: row.readTable(roomMemberTable).role,
            dpUrl: row.readTable(roomMemberTable).dpUrl,
          )
      };

      return roomMembersMap;
    } catch (e) {
      logger.e("Error fetching room members by room ID: $e");
      return {};
    }
  }
}
