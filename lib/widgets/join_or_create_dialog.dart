import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../view_models/tourney_view_model.dart';
import '../view_models/constants_view_model.dart';
import '../widgets/button.dart';

/// A tabbed dialog for joining or creating a tourney challenge.
///
/// Triggered by the [+] button on the tourney screen when no challenge is
/// active. Contains two tabs:
///   1. **Join Tourney** – invite-code text field + Join button.
///   2. **Create Tourney** – name field, two dropdowns, Start button.
class JoinOrCreateDialog extends StatefulWidget {
  final TourneyViewModel viewModel;
  final ConstantsViewModel constantsViewModel;

  const JoinOrCreateDialog({
    super.key,
    required this.viewModel,
    required this.constantsViewModel,
  });

  @override
  State<JoinOrCreateDialog> createState() => _JoinOrCreateDialogState();
}

class _JoinOrCreateDialogState extends State<JoinOrCreateDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _inviteCodeController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inviteCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    final cvm = widget.constantsViewModel;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tourney Hall',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 22,
                      color: AppColors.shimmer,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.muted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.shimmer,
            labelColor: AppColors.shimmer,
            unselectedLabelColor: AppColors.muted,
            tabs: [
              Tab(
                icon: const Icon(Icons.mail_outline),
                child: Text(
                  'Join Tourney',
                  style: GoogleFonts.rosarivo(fontSize: 12),
                ),
              ),
              Tab(
                icon: const Icon(Icons.add_box_outlined),
                child: Text(
                  'Create Tourney',
                  style: GoogleFonts.rosarivo(fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tab views
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJoinTab(vm),
                _buildCreateTab(vm, cvm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Join tab
  // ---------------------------------------------------------------------------

  Widget _buildJoinTab(TourneyViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Enter an invite code to join an existing tourney.',
            textAlign: TextAlign.center,
            style: GoogleFonts.rosarivo(
              fontSize: 14,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _inviteCodeController,
            style: GoogleFonts.rosarivo(color: AppColors.onSurface),
            decoration: InputDecoration(
              labelText: 'Invite Code',
              labelStyle: GoogleFonts.rosarivo(color: AppColors.muted),
              prefixIcon:
                  const Icon(Icons.vpn_key, color: AppColors.secondaryLight),
              filled: true,
              fillColor: AppColors.background.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.secondary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            onPressed: vm.isLoading
                ? null
                : () async {
                    final code = _inviteCodeController.text.trim();
                    if (code.isEmpty) return;
                    await vm.joinChallenge(code);
                    if (vm.hasActiveChallenge && mounted) {
                      Navigator.pop(context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: vm.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : Text(
                    'Join',
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.onPrimary,
                      fontSize: 16,
                    ),
                  ),
          ),
          if (vm.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              vm.errorMessage!,
              style: GoogleFonts.rosarivo(
                fontSize: 12,
                color: AppColors.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Create tab
  // ---------------------------------------------------------------------------

  Widget _buildCreateTab(TourneyViewModel vm, ConstantsViewModel cvm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: vm),
            ChangeNotifierProvider.value(value: cvm),
          ],
          child: Consumer2<TourneyViewModel, ConstantsViewModel>(
            builder: (context, vm, cvm, _) {
              final constants = cvm.tourneyConfig;
              return Column(
                children: [
                  const SizedBox(height: 12),
                  // Tournament Name
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                    onChanged: vm.setDraftName,
                    decoration: InputDecoration(
                      labelText: 'Tournament Name',
                      labelStyle: GoogleFonts.rosarivo(color: AppColors.muted),
                      prefixIcon: const Icon(Icons.flag,
                          color: AppColors.secondaryLight),
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.secondary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Daily Commitment dropdown
                  DropdownButtonFormField<int>(
                    initialValue: vm.draftDailyMinutes,
                    dropdownColor: AppColors.surface,
                    style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Daily Commitment',
                      labelStyle: GoogleFonts.rosarivo(color: AppColors.muted),
                      prefixIcon: const Icon(Icons.timer,
                          color: AppColors.secondaryLight),
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: constants?.dailyGoalMinutes
                            .map((opt) => DropdownMenuItem(
                                  value: opt.value,
                                  child: Text(opt.label),
                                ))
                            .toList() ??
                        [],
                    onChanged: vm.setDraftDailyMinutes,
                  ),
                  const SizedBox(height: 16),

                  // Overall Duration dropdown
                  DropdownButtonFormField<int>(
                    initialValue: vm.draftOverallDays,
                    dropdownColor: AppColors.surface,
                    style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Overall Duration',
                      labelStyle: GoogleFonts.rosarivo(color: AppColors.muted),
                      prefixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.secondaryLight),
                      filled: true,
                      fillColor: AppColors.background.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: constants?.overallGoalDays
                            .map((opt) => DropdownMenuItem(
                                  value: opt.value,
                                  child: Text(opt.label),
                                ))
                            .toList() ??
                        [],
                    onChanged: vm.setDraftOverallDays,
                  ),
                  const SizedBox(height: 20),

                  // Start Challenge button
                  AppButton(
                    onPressed: (vm.isValidDraft && !vm.isLoading)
                        ? () async {
                            final navigator = Navigator.of(context);
                            await vm.createChallenge(
                              vm.draftName,
                              vm.draftDailyMinutes!,
                              vm.draftOverallDays!,
                            );
                            if (vm.hasActiveChallenge && mounted) {
                              navigator.pop();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.3),
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : Text(
                            'Start Challenge',
                            style: GoogleFonts.medievalSharp(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                  ),

                  if (vm.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.errorMessage!,
                      style: GoogleFonts.rosarivo(
                        fontSize: 12,
                        color: AppColors.primaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
