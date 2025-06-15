import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_manager_app/utils/app_colors.dart';
import 'package:provider/provider.dart';

import '../../providers/project_provider.dart';
import '../projects/project_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        if (projectProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final projects = projectProvider.projects;

        if (projects.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No projects to display on map', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: projects.isNotEmpty ? projects.first.location : LatLng(40.7128, -74.0060),
            zoom: 5.0,
            minZoom: 3.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.project_manager_app',
            ),
            MarkerLayer(
              markers:
                  projects.map((project) {
                    return Marker(
                      point: project.location,
                      width: 40,
                      height: 40,
                      builder: (context) {
                        return GestureDetector(
                          onTap: () {
                            _showProjectBottomSheet(context, project);
                          },
                          child: Container(
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }

  void _showProjectBottomSheet(BuildContext context, project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        project.imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(project.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${project.location.latitude.toStringAsFixed(4)}, ${project.location.longitude.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProjectDetailScreen(project: project)),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
