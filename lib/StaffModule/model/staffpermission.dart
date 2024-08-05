
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