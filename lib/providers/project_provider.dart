import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../models/project_model.dart';

class ProjectProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<ProjectModel> get projects => _filteredProjects;
  bool get isLoading => _isLoading;

  // Sample image URLs for new projects
  final List<String> _sampleImageUrls = [
    'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=500',
    'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=500',
    'https://images.unsplash.com/photo-1497435334941-8c899ee9e8e9?w=500',
    'https://images.unsplash.com/photo-1522407183863-c0bf2256188c?w=500',
    'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=500',
    'https://images.unsplash.com/photo-1744137285276-57ca4048f805?w=500',
    'https://images.unsplash.com/photo-1739989934209-fc27e42bb76c?w=500',
  ];

  Future<void> fetchProjects(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore.collection('projects').where('userId', isEqualTo: userId).get();

      _projects =
          querySnapshot.docs.map((doc) => ProjectModel.fromMap(doc.data())).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by createdAt in memory

      _filteredProjects = List.from(_projects);
    } catch (e) {
      print('Error fetching projects: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProject({
    required String userId,
    required String name,
    required String description,
    required LatLng location,
  }) async {
    try {
      final projectId = _uuid.v4();
      final randomImageUrl = _sampleImageUrls[_uuid.v4().hashCode % _sampleImageUrls.length];

      final project = ProjectModel(
        id: projectId,
        userId: userId,
        name: name,
        description: description,
        imageUrl: randomImageUrl,
        location: location,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('projects').doc(projectId).set(project.toMap());

      _projects.insert(0, project);
      _filteredProjects = List.from(_projects);
      notifyListeners();
    } catch (e) {
      print('Error creating project: $e');
      rethrow;
    }
  }

  void searchProjects(String query) {
    if (query.isEmpty) {
      _filteredProjects = List.from(_projects);
    } else {
      _filteredProjects =
          _projects
              .where(
                (project) =>
                    project.name.toLowerCase().contains(query.toLowerCase()) ||
                    project.description.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
    notifyListeners();
  }

  ProjectModel? getProjectById(String id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
}
