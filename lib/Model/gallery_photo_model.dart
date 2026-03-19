/// Model for a single gallery photo from /api/rentals/gallery/{rental_id}
class GalleryPhoto {
  final String id;
  final String image;
  final String description;
  final bool isCover;
  final String createdAt;
  final String updatedAt;

  GalleryPhoto({
    required this.id,
    required this.image,
    required this.description,
    required this.isCover,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      id: json['_id']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isCover: json['is_cover'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'image': image,
        'description': description,
        'is_cover': isCover,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  GalleryPhoto copyWith({
    String? id,
    String? image,
    String? description,
    bool? isCover,
    String? createdAt,
    String? updatedAt,
  }) {
    return GalleryPhoto(
      id: id ?? this.id,
      image: image ?? this.image,
      description: description ?? this.description,
      isCover: isCover ?? this.isCover,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Response from GET/POST/PUT/DELETE /api/rentals/gallery/{rental_id}
class GalleryResponse {
  final String rentalId;
  final String? propertyAddress;
  final List<GalleryPhoto> photos;
  final int totalPhotos;

  GalleryResponse({
    required this.rentalId,
    this.propertyAddress,
    required this.photos,
    required this.totalPhotos,
  });

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final photosList = data['photos'] as List<dynamic>? ?? [];
    return GalleryResponse(
      rentalId: data['rental_id']?.toString() ?? '',
      propertyAddress: data['property_address']?.toString(),
      photos: photosList
          .map((e) => GalleryPhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPhotos: (data['total_photos'] is int)
          ? data['total_photos'] as int
          : int.tryParse(data['total_photos']?.toString() ?? '0') ?? 0,
    );
  }
}
