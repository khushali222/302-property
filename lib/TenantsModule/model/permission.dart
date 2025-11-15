class UserPermissions {
  final bool propertyView;
  final bool financialView;
  final bool financialAdd;
  final bool financialEdit;
  final bool workorderView;
  final bool workorderAdd;
  final bool workorderEdit;
   bool? workorderDelete;
  final bool documentsView;
  final bool documentsAdd;
  final bool documentsEdit;
   bool? documentsDelete;

  UserPermissions({
    required this.propertyView,
    required this.financialView,
    required this.financialAdd,
    required this.financialEdit,
    required this.workorderView,
    required this.workorderAdd,
    required this.workorderEdit,
     this.workorderDelete,
    required this.documentsView,
    required this.documentsAdd,
    required this.documentsEdit,
     this.documentsDelete,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      propertyView: json['property_view'],
      financialView: json['financial_view'],
      financialAdd: json['financial_add'],
      financialEdit: json['financial_edit'],
      workorderView: json['workorder_view'],
      workorderAdd: json['workorder_add'],
      workorderEdit: json['workorder_edit'],
    //  workorderDelete: json['workorder_delete'],
      documentsView: json['documents_view'],
      documentsAdd: json['documents_add'],
      documentsEdit: json['documents_edit'],
     // documentsDelete: json['documents_delete'],
    );
  }
}
