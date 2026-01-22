import 'package:hive/hive.dart';

part 'toggles_data.g.dart';

@HiveType(typeId: 1)
class TogglesData extends HiveObject {
  @HiveField(0)
  bool darkMode;

  @HiveField(1)
  bool compactHeader;

  TogglesData({this.darkMode = false, this.compactHeader = false});
}
