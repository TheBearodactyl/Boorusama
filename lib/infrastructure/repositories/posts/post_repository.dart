import 'dart:convert';

import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/infrastructure/apis/providers/danbooru.dart';

class PostRepository implements IPostRepository {
  //TODO: shouldn't use concrete type
  final Danbooru _api;

  PostRepository(this._api);

  //TODO: update to remove duplicate code
  @override
  Future<List<Post>> getPosts(String tagString, int page) async {
    var uri = Uri.https(_api.url, "/posts.json", {
      "login": _api.username,
      "api_key": _api.apiKey,
      "page": page.toString(),
      "tags": tagString,
      "limit": "200",
    });

    var respond = await _api.client.get(uri);

    if (respond.statusCode == 200) {
      var content = jsonDecode(respond.body);
      var posts = List<Post>();
      for (var item in content) {
        try {
          posts.add(Post.fromJson(item));
        } catch (e) {
          print("Cant parse $item[id]");
        }
      }
      return posts;
      // return content.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception("Unable to perform request!");
    }
  }
}