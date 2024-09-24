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

  // New variables for additional permissions
  bool? settingView;
  bool? propertytypeView;
  bool? propertytypeAdd;
  bool? propertytypeEdit;
  bool? propertytypeDelete;
  bool? rentalownerView;
  bool? rentalownerAdd;
  bool? rentalownerEdit;
  bool? rentalownerDelete;
  bool? applicantView;
  bool? applicantAdd;
  bool? applicantEdit;
  bool? applicantDelete;
  bool? vendorView;
  bool? vendorAdd;
  bool? vendorEdit;
  bool? vendorDelete;

  StaffPermission({
    this.propertydetailView,
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
    this.workorderDelete,

    // New permissions
    this.settingView,
    this.propertytypeView,
    this.propertytypeAdd,
    this.propertytypeEdit,
    this.propertytypeDelete,
    this.rentalownerView,
    this.rentalownerAdd,
    this.rentalownerEdit,
    this.rentalownerDelete,
    this.applicantView,
    this.applicantAdd,
    this.applicantEdit,
    this.applicantDelete,
    this.vendorView,
    this.vendorAdd,
    this.vendorEdit,
    this.vendorDelete,
  });

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

    // Deserialize new permissions
    settingView = json['setting_view'];
    propertytypeView = json['propertytype_view'];
    propertytypeAdd = json['propertytype_add'];
    propertytypeEdit = json['propertytype_edit'];
    propertytypeDelete = json['propertytype_delete'];
    rentalownerView = json['rentalowner_view'];
    rentalownerAdd = json['rentalowner_add'];
    rentalownerEdit = json['rentalowner_edit'];
    rentalownerDelete = json['rentalowner_delete'];
    applicantView = json['applicant_view'];
    applicantAdd = json['applicant_add'];
    applicantEdit = json['applicant_edit'];
    applicantDelete = json['applicant_delete'];
    vendorView = json['vendor_view'];
    vendorAdd = json['vendor_add'];
    vendorEdit = json['vendor_edit'];
    vendorDelete = json['vendor_delete'];
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

    // Serialize new permissions
    data['setting_view'] = this.settingView;
    data['propertytype_view'] = this.propertytypeView;
    data['propertytype_add'] = this.propertytypeAdd;
    data['propertytype_edit'] = this.propertytypeEdit;
    data['propertytype_delete'] = this.propertytypeDelete;
    data['rentalowner_view'] = this.rentalownerView;
    data['rentalowner_add'] = this.rentalownerAdd;
    data['rentalowner_edit'] = this.rentalownerEdit;
    data['rentalowner_delete'] = this.rentalownerDelete;
    data['applicant_view'] = this.applicantView;
    data['applicant_add'] = this.applicantAdd;
    data['applicant_edit'] = this.applicantEdit;
    data['applicant_delete'] = this.applicantDelete;
    data['vendor_view'] = this.vendorView;
    data['vendor_add'] = this.vendorAdd;
    data['vendor_edit'] = this.vendorEdit;
    data['vendor_delete'] = this.vendorDelete;

    return data;
  }
}
