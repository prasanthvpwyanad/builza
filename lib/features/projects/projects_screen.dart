import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/demo/sample_projects.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Projects', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Manage clients, agreements and project balances', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add project')),
        const SizedBox(height: 12),
        ...sampleProjects.map(
          (project) => Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => openProjectDetails(context, project),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, color: AppColors.blue),
                        const SizedBox(width: 8),
                        Expanded(child: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w800))),
                        const Icon(Icons.chevron_right, color: AppColors.muted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Client: ${project.client}  •  ${project.location}', style: const TextStyle(color: AppColors.muted)),
                    const Divider(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Project balance', style: TextStyle(color: AppColors.muted)),
                        Text(project.balance, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.green)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(label: Text(project.status), visualDensity: VisualDensity.compact),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
