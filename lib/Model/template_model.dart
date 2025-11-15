class Template {
  final String id;
  final String name;
  final String subject;
  final String body;

  Template({
    required this.id,
    required this.name,
    required this.subject,
    required this.body,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['template_id'],
      name: json['name'],
      subject: json['subject'],
      body: json['body'],
    );
  }
}
