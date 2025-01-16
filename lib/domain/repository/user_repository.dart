import '../models/user.dart';

abstract class UserRepository {
  Future<int> insertUser(User user);
  Future<List<User>> getUsers();
  Future<int> updateUser(User user);
  Future<int> deleteUser(int id);
}