class Rentaladded {
  final int rentalCount;
  final int propertyCountLimit;
  final String message;

  Rentaladded({
    required this.rentalCount,
    required this.propertyCountLimit,
    required this.message,
  });

  factory Rentaladded.fromJson(Map<String, dynamic> json) {
    return Rentaladded(
      rentalCount: json['rentalCount'],
      propertyCountLimit: json['propertyCountLimit'],
      message: json['message'],
    );
  }
}

class Staffadded {
  final int rentalCount;
  final int staffCountLimit;
  final String message;

  Staffadded({
    required this.rentalCount,
    required this.staffCountLimit,
    required this.message,
  });

  factory Staffadded.fromJson(Map<String, dynamic> json) {
    return Staffadded(
      rentalCount: json['rentalCount'],
      staffCountLimit: json['staffCountLimit'],
      message: json['message'],
    );
  }
}

class Rentalwneradded {
  final int rentalCount;
  final int rentalOwnerCountLimit;
  final String message;

  Rentalwneradded({
    required this.rentalCount,
    required this.rentalOwnerCountLimit,
    required this.message,
  });

  factory Rentalwneradded.fromJson(Map<String, dynamic> json) {
    return Rentalwneradded(
      rentalCount: json['rentalCount'],
      rentalOwnerCountLimit: json['rentalOwnerCountLimit'],
      message: json['message'],
    );
  }
}
