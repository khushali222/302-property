import 'dart:convert';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:three_zero_two_property/Model/applicant_summery_model.dart';
import '../../../../repository/applicant_summery_repo.dart';

import '../../../../../constant/constant.dart';

class ApprovedContent extends StatefulWidget {
  final String applicantId;
  applicant_summery_details applicantDetail;

  ApprovedContent({required this.applicantId, required this.applicantDetail});

  @override
  State<ApprovedContent> createState() => _ApprovedContentState();
}

class _ApprovedContentState extends State<ApprovedContent> {
  ApplicantSummeryRepository applicantSummeryRepository =
      ApplicantSummeryRepository();
  ApproveRejectApplicantDetail? applicantDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchApplicantDetails();
  }

  Future<void> fetchApplicantDetails() async {
    try {
      ApproveRejectApplicantDetail detail = await applicantSummeryRepository
          .fetchApprovedDetail(widget.applicantId);
      setState(() {
        applicantDetail = detail;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Failed to load applicant details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ?  Center(
              child: SpinKitSpinningLines(
              color: blueColor,
              size: 40.0,
            ))
          : applicantDetail != null
              ? LayoutBuilder(
                builder: (context,contraints) {
                  if(contraints.maxWidth > 600)
                    {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 205,
                          width: MediaQuery.of(context).size.width * .4,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: const Color.fromRGBO(21, 43, 81, 1),
                            ),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const SizedBox(width: 15),
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(21, 43, 81, 1),
                                      border: Border.all(
                                          color: const Color.fromRGBO(21, 43, 81, 1)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.user,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const SizedBox(width: 2),
                                          Text(
                                            '${widget.applicantDetail.applicantFirstName ?? 'N/A'} ${widget.applicantDetail.applicantLastName ?? 'N/A'}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(21, 43, 81, 1),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                  const Spacer(),
                                  const SizedBox(width: 15),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const SizedBox(width: 75),
                                  const FaIcon(
                                    FontAwesomeIcons.phone,
                                    size: 25,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${widget.applicantDetail.applicantPhoneNumber ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const SizedBox(width: 75),
                                  const FaIcon(
                                    FontAwesomeIcons.home,
                                    size: 25,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${widget.applicantDetail.leaseData!.rentalAdress ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color.fromRGBO(21, 43, 81, 1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  SizedBox(width: 75),
                                  Text(
                                    'Approved',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromRGBO(38, 194, 44, 1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 165,
                        width: MediaQuery.of(context).size.width * .9,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color.fromRGBO(21, 43, 81, 1),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 15),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(21, 43, 81, 1),
                                    border: Border.all(
                                        color: const Color.fromRGBO(21, 43, 81, 1)),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Center(
                                    child: FaIcon(
                                      FontAwesomeIcons.user,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const SizedBox(width: 2),
                                        Text(
                                          '${widget.applicantDetail.applicantFirstName ?? 'N/A'} ${widget.applicantDetail.applicantLastName ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(21, 43, 81, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                                const Spacer(),
                                const SizedBox(width: 15),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const SizedBox(width: 65),
                                const FaIcon(
                                  FontAwesomeIcons.phone,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.applicantDetail.applicantPhoneNumber ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 65),
                                const FaIcon(
                                  FontAwesomeIcons.home,
                                  size: 15,
                                  color: Color.fromRGBO(21, 43, 81, 1),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${widget.applicantDetail.leaseData!.rentalAdress ?? 'N/A'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              children: [
                                SizedBox(width: 65),
                                Text(
                                  'Approved',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromRGBO(38, 194, 44, 1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                }
              )
              : const Center(child: Text('No details found')),
    );
  }
}
