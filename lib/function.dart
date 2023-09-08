import 'dart:convert';

List<Welcome> welcomeFromJson(String str) => List<Welcome>.from(json.decode(str).map((x) => Welcome.fromJson(x)));

String welcomeToJson(List<Welcome> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Welcome {
    String quote;
    String author;
    String category;

    Welcome({
        required this.quote,
        required this.author,
        required this.category,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        quote: json["quote"],
        author: json["author"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "quote": quote,
        "author": author,
        "category": category,
    };
}
