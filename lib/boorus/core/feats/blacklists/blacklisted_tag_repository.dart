// Project imports:

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';

abstract class GlobalBlacklistedTagRepository {
  Future<BlacklistedTag> addTag(String tag);
  Future<void> removeTag(int tagId);
  Future<List<BlacklistedTag>> getBlacklist();
}
