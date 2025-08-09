import 'package:drift/drift.dart';
import '../database.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:zineapp2023/models/newUser.dart';
import 'package:zineapp2023/utilities/custom_logger.dart';

part 'user_dao.g.dart';

final logger = customLogger();

@DriftAccessor(tables: [UsersTable])
class UserDao extends DatabaseAccessor<AppDb> with _$UserDaoMixin {
  UserDao(AppDb db) : super(db);

  Future<String> createUserImagePath(NewUserModel userData) async {
    try {
      final sanitizedUrl = Uri.encodeFull(userData.dp!.trim());
      final response = await http.get(Uri.parse(sanitizedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load image from URL');
      }
      final imageBytes = response.bodyBytes;
      final directory = await getApplicationDocumentsDirectory();
      final userDirectoryPath =
          '${directory.path}/${userData.name}/${userData.id}';
      final userDirectory = Directory(userDirectoryPath);
      if (!await userDirectory.exists()) {
        await userDirectory.create(recursive: true);
      }
      final filePath = '${userDirectory.path}/dp.png';
      final file = File(filePath);
      userData.dp != null ? await file.writeAsBytes(imageBytes) : '';
      return filePath;
    } catch (e) {
      logger.e("Error in creating userDp path: $e");
      return '';
    }
  }

  Future<int> upsertUserDB(NewUserModel userData) async {
    String filePath =
        userData.dp != null ? await createUserImagePath(userData) : "";
    final userCompanion = UsersTableCompanion(
      id: Value(userData.id!),
      name: Value(userData.name!),
      email: Value(userData.email),
      type: Value(userData.type),
      dp: Value(filePath),
      registered:
          Value(userData.registered != null ? userData.registered! : false),
      emailVerified: Value(userData.registered),
      pushToken: Value(userData.pushToken),
    );
    try {
      final insertedId = await into(usersTable)
          .insert(userCompanion, mode: InsertMode.replace);
      logger.d('User upserted successfully with ID: ${userCompanion.id.value}');
      return insertedId;
    } catch (e) {
      logger.e('Error in upserting user: $e');
      return -1;
    }
  }

  Future<UserDB?> getUserDetailsFromLocalDB(String emailId) async {
    try {
      final user = await (select(usersTable)
            ..where((t) => t.email.equals(emailId)))
          .getSingleOrNull();
      if (user != null) {
        logger.d("User found: ${user.name}");
      } else {
        logger.d("User not found");
      }
      return user;
    } catch (e) {
      logger.e("Error: getUserDetailsFromLocalDb: $e");
      return null;
    }
  }
}
