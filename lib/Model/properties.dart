import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constant.dart';

// Define the Rental model with nested classes
class Rentals {
  String? id;
  String? rentalId;
  String? adminId;
  String? rentalOwnerId;
  String? propertyId;
  String? rentalAddress;
  bool? isRentOn;
  String? rentalCity;
  String? rentalState;
  String? rentalCountry;
  String? rentalPostcode;
  String? rentalImage;
  String? staffMemberId;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  RentalOwnerData? rentalOwnerData;
  PropertyTypeData? propertyTypeData;
  StaffMemberData? staffMemberData;

  Rentals({
     this.id,
     this.rentalId,
     this.adminId,
     this.rentalOwnerId,
     this.propertyId,
     this.rentalAddress,
     this.isRentOn,
     this.rentalCity,
     this.rentalState,
     this.rentalCountry,
     this.rentalPostcode,
     this.rentalImage,
     this.staffMemberId,
     this.createdAt,
     this.updatedAt,
     this.isDelete,
     this.rentalOwnerData,
     this.propertyTypeData,
     this.staffMemberData,
  });

  // Define the fromJson method within the Rental class
  factory Rentals.fromJson(Map<String, dynamic> json) {
    return Rentals(
      id: json['_id'],
      rentalId: json['rental_id'] ?? "",
      adminId: json['admin_id']?? "",
      rentalOwnerId: json['rentalowner_id']?? "",
      propertyId: json['property_id']?? "",
      rentalAddress: json['rental_adress']?? "",
      isRentOn: json['is_rent_on']?? "",
      rentalCity: json['rental_city']?? "",
      rentalState: json['rental_state']?? "",
      rentalCountry: json['rental_country']?? "",
      rentalPostcode: json['rental_postcode']?? "",
      rentalImage: json['rental_image']?? "",
      staffMemberId: json['staffmember_id']?? "",
      createdAt: json['createdAt']?? "",
      updatedAt: json['updatedAt']?? "",
      isDelete: json['is_delete']?? "",
       rentalOwnerData: RentalOwnerData.fromJson(json['rental_owner_data']?? {}),
       propertyTypeData: PropertyTypeData.fromJson(json['property_type_data']?? {}),
       staffMemberData: StaffMemberData.fromJson(json['staffmember_data']?? {})
    );
  }
}
class RentalOwnerData {
  String? id;
  String? rentalOwnerId;
  String? adminId;
  String? rentalOwnerFirstName;
  String? rentalOwnerLastName;
  String? rentalOwnerCompanyName;
  String? rentalOwnerPrimaryEmail;
  String? rentalOwnerAlternativeEmail;
  String? rentalOwnerPhoneNumber;
  String? rentalOwnerHomeNumber;
  String? rentalOwnerBuisinessNumber;
  String? city;
  String? Address;
  String? state;
  String? country;
  String? postalCode;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  List<dynamic>? processorList;

  RentalOwnerData({
     this.id,
     this.rentalOwnerId,
     this.adminId,
     this.rentalOwnerFirstName,
     this.rentalOwnerLastName,
     this.rentalOwnerCompanyName,
     this.rentalOwnerPrimaryEmail,
     this.rentalOwnerAlternativeEmail,
     this.rentalOwnerPhoneNumber,
     this.rentalOwnerHomeNumber,
     this.rentalOwnerBuisinessNumber,
     this.city,
     this.state,
     this.Address,
     this.country,
     this.postalCode,
     this.createdAt,
     this.updatedAt,
     this.isDelete,
     this.processorList,
  });

  factory RentalOwnerData.fromJson(Map<String, dynamic> json) {
    return RentalOwnerData(
      id: json['_id']?? "",
      rentalOwnerId: json['rentalowner_id']?? "",
      adminId: json['admin_id']?? "",
      rentalOwnerFirstName: json['rentalOwner_firstName']?? "",
      rentalOwnerLastName: json['rentalOwner_lastName']?? "",
      rentalOwnerCompanyName: json['rentalOwner_companyName']?? "",
      rentalOwnerPrimaryEmail: json['rentalOwner_primaryEmail']?? "",
      rentalOwnerAlternativeEmail: json['rentalOwner_alternateEmail']?? "",
      rentalOwnerPhoneNumber: json['rentalOwner_phoneNumber']?? "",
      rentalOwnerHomeNumber: json['rentalOwner_homeNumber']?? "",
      rentalOwnerBuisinessNumber: json['rentalOwner_businessNumber']?? "",
      city: json['city']?? "",
      state: json['state']?? "",
      Address: json['street_address']?? "",
      country: json['country']?? "",
      postalCode: json['postal_code']?? "",
      createdAt: json['createdAt']?? "",
      updatedAt: json['updatedAt']?? "",
      isDelete: json['is_delete']?? "",
      processorList: json['processor_list']?? "",
    );
  }
}
class PropertyTypeData {
  String? id;
  String? adminId;
  String? propertyId;
  String? propertyType;
  String? propertySubType;
  bool? isMultiunit;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;

  PropertyTypeData({
     this.id,
     this.adminId,
     this.propertyId,
     this.propertyType,
     this.propertySubType,
     this.isMultiunit,
     this.createdAt,
     this.updatedAt,
     this.isDelete,
  });

  factory PropertyTypeData.fromJson(Map<String, dynamic> json) {
    return PropertyTypeData(
      id: json['_id']?? "",
      adminId: json['admin_id']?? "",
      propertyId: json['property_id']?? "",
      propertyType: json['property_type']?? "",
      propertySubType: json['propertysub_type']?? "",
      isMultiunit: json['is_multiunit']?? "",
      createdAt: json['createdAt']?? "",
      updatedAt: json['updatedAt']?? "",
      isDelete: json['is_delete']?? "",
    );
  }
}
class StaffMemberData {
  String? id;
  String? adminId;
  String? staffmemberName;


  StaffMemberData({
    this.id,
    this.adminId,
    this.staffmemberName,

  });
  factory StaffMemberData.fromJson(Map<String, dynamic> json) {
    return StaffMemberData(
      id: json['_id']?? "",
      adminId: json['admin_id']?? "",
      staffmemberName: json['staffmember_name']?? "",
    );
  }
}

// Fetch rental owner data
// Future<List<Rentals>> fetchRentalOwner() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? id = prefs.getString("adminId");
//   if (id == null) {
//     throw Exception('No adminId found in SharedPreferences');
//   }
//
//   final response = await http.get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'));
//   if (response.statusCode == 200) {
//     List<dynamic> jsonResponse = json.decode(response.body);
//     return jsonResponse.map((data) => Rentals.fromJson(data)).toList();
//   } else {
//     throw Exception('Failed to load data');
//   }
// }
