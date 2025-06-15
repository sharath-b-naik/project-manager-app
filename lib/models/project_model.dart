import 'package:latlong2/latlong.dart';

enum ProjectStatus { pending, ongoing, completed }

class ProjectModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String imageUrl;
  final LatLng location;
  final DateTime createdAt;
  final List<String> images;
  final List<String> videos;
  final ProjectStatus status;

  ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
    this.images = const [],
    this.videos = const [],
    this.status = ProjectStatus.pending,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      location: LatLng(map['location']['latitude'] ?? 0.0, map['location']['longitude'] ?? 0.0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      images: List<String>.from(map['images'] ?? []),
      videos: List<String>.from(map['videos'] ?? []),
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == 'ProjectStatus.${map['status'] ?? 'pending'}',
        orElse: () => ProjectStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': {'latitude': location.latitude, 'longitude': location.longitude},
      'createdAt': createdAt.millisecondsSinceEpoch,
      'images': images,
      'videos': videos,
      'status': status.toString().split('.').last,
    };
  }
}
