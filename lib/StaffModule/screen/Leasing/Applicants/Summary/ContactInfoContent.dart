import 'package:three_zero_two_property/services/app_log.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:three_zero_two_property/widgets/no_internet_view.dart';
import 'package:three_zero_two_property/provider/network_retry_state.dart';
import 'package:three_zero_two_property/Model/applicant_summery_model.dart';
import '../../../../repository/applicant_summery_repo.dart';

import '../../../../../constant/constant.dart';

/// Contact Info tab — merges the old Approved and Rejected tabs into one
/// card list (matches the web ContactInfoTab: one card per status record,
/// status word colored green/red).
class ContactInfoContent extends StatefulWidget {
  final String applicantId;
  applicant_summery_details applicantDetail;

  ContactInfoContent(
      {Key? key, required this.applicantId, required this.applicantDetail})
      : super(key: key);

  @override
  State<ContactInfoContent> createState() => _ContactInfoContentState();
}

class _ContactInfoContentState extends State<ContactInfoContent>
    with NetworkRetryState {
  ApplicantSummeryRepository applicantSummeryRepository =
      ApplicantSummeryRepository();
  ApproveRejectApplicantDetail? approvedDetail;
  ApproveRejectApplicantDetail? rejectedDetail;
  bool isLoading = true;

  /// Required by [NetworkRetryState]: re-issue this view's own load.
  /// The data calls `initState` makes; controllers and defaults are not
  /// repeated, so a reload keeps what the user was looking at.
  @override
  Future<void> reloadData() async {
    if (!mounted) return;
    setState(() {
      fetchDetails();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    // Each endpoint throws when no record exists for that status — that's
    // expected (an applicant may have only one of the two), so catch each
    // independently and keep whichever records came back.
    try {
      approvedDetail = await applicantSummeryRepository
          .fetchApprovedDetail(widget.applicantId);
    } catch (error) {
      logError('No approved record: $error');
    }
    try {
      rejectedDetail = await applicantSummeryRepository
          .fetchRejectedDetail(widget.applicantId);
    } catch (error) {
      logError('No rejected record: $error');
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _displayOrNA(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty || v.toLowerCase() == 'null') return 'N/A';
    return v;
  }

  String _address(ApproveRejectApplicantDetail? detail) {
    final fromDetail = _displayOrNA(detail?.rentalAddress);
    if (fromDetail != 'N/A') return fromDetail;
    return _displayOrNA(widget.applicantDetail.leaseData?.rentalAdress);
  }

  String _initials() {
    final first = widget.applicantDetail.applicantFirstName?.trim() ?? '';
    final last = widget.applicantDetail.applicantLastName?.trim() ?? '';
    final buffer = StringBuffer();
    if (first.isNotEmpty) buffer.write(first[0].toUpperCase());
    if (last.isNotEmpty) buffer.write(last[0].toUpperCase());
    return buffer.isEmpty ? '?' : buffer.toString();
  }

  static const Color _labelGrey = Color(0xFF626262);

  Widget _contactCard(
      {required String status, ApproveRejectApplicantDetail? detail}) {
    final Color statusColor = status == 'Approved'
        ? const Color(0xFF26C22C)
        : const Color(0xFFFF3B3B);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDBE0E5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: blueColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '${widget.applicantDetail.applicantFirstName ?? 'N/A'} ${widget.applicantDetail.applicantLastName ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.phone_outlined,
                    color: _labelGrey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _displayOrNA(
                        widget.applicantDetail.applicantPhoneNumber),
                    style: const TextStyle(
                      fontSize: 16,
                      color: _labelGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.home_outlined,
                    color: _labelGrey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _address(detail),
                    style: const TextStyle(
                      fontSize: 16,
                      color: _labelGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              status,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This view lives inside another screen's tab, so it shows the
    // compact offline state rather than taking over the whole page.
    if (isOffline) {
      return NoInternetView(compact: true, onRetry: retryNow);
    }
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 200),
        child: Center(
          child: SpinKitSpinningLines(
            color: blueColor,
            size: 40.0,
          ),
        ),
      );
    }
    final cards = <Widget>[];
    if (approvedDetail != null) {
      cards.add(_contactCard(status: 'Approved', detail: approvedDetail));
    }
    if (rejectedDetail != null) {
      cards.add(_contactCard(status: 'Rejected', detail: rejectedDetail));
    }
    if (cards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 200),
        child: Center(child: Text('No details found')),
      );
    }
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F6F9),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: cards,
      ),
    );
  }
}
