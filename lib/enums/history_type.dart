enum HistoryType {
  tenant,
  property,
  lease,
  mortgage,
  applicant;

  String get apiPath {
    switch (this) {
      case HistoryType.tenant:
        return 'tenant';
      case HistoryType.property:
        return 'property';
      case HistoryType.lease:
        return 'lease';
      case HistoryType.mortgage:
        return 'mortgage';
      case HistoryType.applicant:
        return 'applicant';
    }
  }
}
