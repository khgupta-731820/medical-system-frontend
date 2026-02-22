import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/routes.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/utils/helpers.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/cards/application_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';

class PendingApplicationsScreen extends StatefulWidget {
  const PendingApplicationsScreen({super.key});

  @override
  State<PendingApplicationsScreen> createState() => _PendingApplicationsScreenState();
}

class _PendingApplicationsScreenState extends State<PendingApplicationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadApplications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AdminProvider>();
      if (!provider.isLoadingMore && provider.hasMoreData) {
        provider.getPendingApplications();
      }
    }
  }

  Future<void> _loadApplications() async {
    await context.read<AdminProvider>().getPendingApplications(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Pending Applications',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.pendingApplications.isEmpty) {
            return const LoadingWidget();
          }

          if (provider.pendingApplications.isEmpty) {
            return EmptyWidget(
              icon: Icons.check_circle_outline,
              title: 'No Pending Applications',
              message: 'All applications have been reviewed.',
              onRefresh: _loadApplications,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadApplications,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendingApplications.length +
                  (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.pendingApplications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final application = provider.pendingApplications[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ApplicationCard(
                    application: application,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        Routes.applicationReview,
                        arguments: application.id,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Staff Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('All'),
                onTap: () {
                  Navigator.pop(context);
                  _loadApplications();
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Doctors'),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter
                },
              ),
              ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Lab Technicians'),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_pharmacy),
                title: const Text('Pharmacists'),
                onTap: () {
                  Navigator.pop(context);
                  // Apply filter
                },
              ),
            ],
          ),
        );
      },
    );
  }
}