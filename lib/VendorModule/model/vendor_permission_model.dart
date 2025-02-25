class UserPermissions {

   bool workorderView =false;

   bool workorderEdit =false;


  UserPermissions({

    required this.workorderView,

    required this.workorderEdit,

  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(

      workorderView: json['workorder_view'],

      workorderEdit: json['workorder_edit'],
      //  workorderDelete: json['workorder_delete'],

      // documentsDelete: json['documents_delete'],
    );
  }
}
