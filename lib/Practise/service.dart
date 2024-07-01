import 'dart:convert';

import 'package:http/http.dart' as http;

class Apiservice {
  final String url = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Post>> fetchData() async {
    var response = await http.get(Uri.parse(url));
    print(Uri.splitQueryString(url));
    // print(response.body);
    List responseJson = json.decode(response.body);
    return responseJson.map((post) => Post.fromJson(post)).toList();
  }
}

class Post {
  String? id;
  String? userId;
  String? title;
  String? body;

  Post(
      {required this.id,
      required this.userId,
      required this.title,
      required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'].toString(),
        userId: json['userId'].toString(),
        title: json['title'],
        body: json['body']);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title:': title,
      'body': body,
    };
  }
}
