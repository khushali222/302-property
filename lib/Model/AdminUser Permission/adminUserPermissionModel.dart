class adminUserPermissionModel {
  int? statusCode;
  UserPermissionData? data;
  String? message;

  adminUserPermissionModel({this.statusCode, this.data, this.message});

  adminUserPermissionModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    data = json['data'] != null
        ? new UserPermissionData.fromJson(json['data'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class UserPermissionData {
  TenantPermission? tenantPermission;
  StaffPermission? staffPermission;
  VendorPermission? vendorPermission;
  String? sId;
  String? adminId;
  bool? isDelete;
  int? iV;

  UserPermissionData(
      {this.tenantPermission,
      this.staffPermission,
      this.vendorPermission,
      this.sId,
      this.adminId,
      this.isDelete,
      this.iV});

  UserPermissionData.fromJson(Map<String, dynamic> json) {
    tenantPermission = json['tenant_permission'] != null
        ? new TenantPermission.fromJson(json['tenant_permission'])
        : null;
    staffPermission = json['staff_permission'] != null
        ? new StaffPermission.fromJson(json['staff_permission'])
        : null;
    vendorPermission = json['vendor_permission'] != null
        ? new VendorPermission.fromJson(json['vendor_permission'])
        : null;
    sId = json['_id'];
    adminId = json['admin_id'];
    isDelete = json['is_delete'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tenantPermission != null) {
      data['tenant_permission'] = this.tenantPermission!.toJson();
    }
    if (this.staffPermission != null) {
      data['staff_permission'] = this.staffPermission!.toJson();
    }
    if (this.vendorPermission != null) {
      data['vendor_permission'] = this.vendorPermission!.toJson();
    }

    data['admin_id'] = this.adminId;

    return data;
  }
}

class TenantPermission {
  bool? propertyView;
  bool? financialView;
  bool? financialAdd;
  bool? financialEdit;
  bool? documentsAdd;
  bool? workorderView;
  bool? workorderAdd;
  bool? workorderEdit;
  bool? workorderDelete;
  bool? documentsView;
  bool? documentsEdit;
  bool? documentsDelete;

  TenantPermission(
      {this.propertyView,
      this.financialView,
      this.financialAdd,
      this.financialEdit,
      this.documentsAdd,
      this.workorderView,
      this.workorderAdd,
      this.workorderEdit,
      this.workorderDelete,
      this.documentsView,
      this.documentsEdit,
      this.documentsDelete});

  TenantPermission.fromJson(Map<String, dynamic> json) {
    propertyView = json['property_view'];
    financialView = json['financial_view'];
    financialAdd = json['financial_add'];
    financialEdit = json['financial_edit'];
    documentsAdd = json['documents_add'];
    workorderView = json['workorder_view'];
    workorderAdd = json['workorder_add'];
    workorderEdit = json['workorder_edit'];
    workorderDelete = json['workorder_delete'];
    documentsView = json['documents_view'];
    documentsEdit = json['documents_edit'];
    documentsDelete = json['documents_delete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['property_view'] = this.propertyView;
    data['financial_view'] = this.financialView;
    data['financial_add'] = this.financialAdd;
    data['financial_edit'] = this.financialEdit;
    data['documents_add'] = this.documentsAdd;
    data['workorder_view'] = this.workorderView;
    data['workorder_add'] = this.workorderAdd;
    data['workorder_edit'] = this.workorderEdit;
    data['workorder_delete'] = this.workorderDelete;
    data['documents_view'] = this.documentsView;
    data['documents_edit'] = this.documentsEdit;
    data['documents_delete'] = this.documentsDelete;
    return data;
  }
}

class StaffPermission {
  bool? propertydetailView;
  bool? workorderdetailView;
  bool? paymentView;
  bool? paymentAdd;
  bool? paymentEdit;
  bool? paymentDelete;
  bool? propertyView;
  bool? leaseAdd;
  bool? workorderEdit;
  bool? propertyAdd;
  bool? propertyEdit;
  bool? propertyDelete;
  bool? tenantView;
  bool? tenantAdd;
  bool? tenantEdit;
  bool? tenantDelete;
  bool? leaseView;
  bool? leaseEdit;
  bool? leaseDelete;
  bool? leasedetailView;
  bool? workorderView;
  bool? workorderAdd;
  bool? workorderDelete;

  StaffPermission(
      {this.propertydetailView,
      this.workorderdetailView,
      this.paymentView,
      this.paymentAdd,
      this.paymentEdit,
      this.paymentDelete,
      this.propertyView,
      this.leaseAdd,
      this.workorderEdit,
      this.propertyAdd,
      this.propertyEdit,
      this.propertyDelete,
      this.tenantView,
      this.tenantAdd,
      this.tenantEdit,
      this.tenantDelete,
      this.leaseView,
      this.leaseEdit,
      this.leaseDelete,
      this.leasedetailView,
      this.workorderView,
      this.workorderAdd,
      this.workorderDelete});

  StaffPermission.fromJson(Map<String, dynamic> json) {
    propertydetailView = json['propertydetail_view'];
    workorderdetailView = json['workorderdetail_view'];
    paymentView = json['payment_view'];
    paymentAdd = json['payment_add'];
    paymentEdit = json['payment_edit'];
    paymentDelete = json['payment_delete'];
    propertyView = json['property_view'];
    leaseAdd = json['lease_add'];
    workorderEdit = json['workorder_edit'];
    propertyAdd = json['property_add'];
    propertyEdit = json['property_edit'];
    propertyDelete = json['property_delete'];
    tenantView = json['tenant_view'];
    tenantAdd = json['tenant_add'];
    tenantEdit = json['tenant_edit'];
    tenantDelete = json['tenant_delete'];
    leaseView = json['lease_view'];
    leaseEdit = json['lease_edit'];
    leaseDelete = json['lease_delete'];
    leasedetailView = json['leasedetail_view'];
    workorderView = json['workorder_view'];
    workorderAdd = json['workorder_add'];
    workorderDelete = json['workorder_delete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['propertydetail_view'] = this.propertydetailView;
    data['workorderdetail_view'] = this.workorderdetailView;
    data['payment_view'] = this.paymentView;
    data['payment_add'] = this.paymentAdd;
    data['payment_edit'] = this.paymentEdit;
    data['payment_delete'] = this.paymentDelete;
    data['property_view'] = this.propertyView;
    data['lease_add'] = this.leaseAdd;
    data['workorder_edit'] = this.workorderEdit;
    data['property_add'] = this.propertyAdd;
    data['property_edit'] = this.propertyEdit;
    data['property_delete'] = this.propertyDelete;
    data['tenant_view'] = this.tenantView;
    data['tenant_add'] = this.tenantAdd;
    data['tenant_edit'] = this.tenantEdit;
    data['tenant_delete'] = this.tenantDelete;
    data['lease_view'] = this.leaseView;
    data['lease_edit'] = this.leaseEdit;
    data['lease_delete'] = this.leaseDelete;
    data['leasedetail_view'] = this.leasedetailView;
    data['workorder_view'] = this.workorderView;
    data['workorder_add'] = this.workorderAdd;
    data['workorder_delete'] = this.workorderDelete;
    return data;
  }
}

class VendorPermission {
  bool? workorderEdit;
  bool? workorderView;

  VendorPermission({this.workorderEdit, this.workorderView});

  VendorPermission.fromJson(Map<String, dynamic> json) {
    workorderEdit = json['workorder_edit'];
    workorderView = json['workorder_view'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['workorder_edit'] = this.workorderEdit;
    data['workorder_view'] = this.workorderView;
    return data;
  }
}
