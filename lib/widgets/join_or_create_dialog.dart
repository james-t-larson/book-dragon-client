import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../blocs/tourney/tourney_bloc.dart';
import '../blocs/tourney/tourney_state.dart';
import '../blocs/tourney/tourney_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_models/constants_view_model.dart';
import '../widgets/button.dart';

/// A tabbed dialog for joining or creating a tourney challenge.
///
/// Triggered by the [+] button on the tourney screen when no challenge is
/// active. Contains two tabs:
///   1. **Join Tourney** – invite-code text field + Join button.
///   2. **Create Tourney** – name field, two dropdowns, Start button.
class JoinOrCreateDialog extends StatefulWidget {
  final ConstantsViewModel constantsViewModel;

  const JoinOrCreateDialog({
    super.key,
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

  String _draftName = '';
  int? _draftDailyMinutes;
  int? _draftOverallDays;

  bool get _isValidDraft =>
      _draftName.trim().isNotEmpty &&
      _draftDailyMinutes != null &&
      _draftOverallDays != null;

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
                _buildJoinTab(),
                _buildCreateTab(cvm),
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

  Widget _buildJoinTab() {
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
          context.watch<TourneyBloc>().state.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                )
              : AppButton(
                  onPressed: () {
                    final code = _inviteCodeController.text.trim();
                    if (code.isEmpty) return;
                    context.read<TourneyBloc>().add(JoinChallenge(code));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  child: Text(
                    'Join',
                    style: GoogleFonts.medievalSharp(
                      color: AppColors.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
          BlocConsumer<TourneyBloc, TourneyState>(
            listener: (context, state) {
              if (state.hasActiveChallenge) {
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              if (state.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.errorMessage!,
                    style: GoogleFonts.rosarivo(
                      fontSize: 12,
                      color: AppColors.primaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Create tab
  // ---------------------------------------------------------------------------

  Widget _buildCreateTab(ConstantsViewModel cvm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: ChangeNotifierProvider.value(
          value: cvm,
          child: Consumer<ConstantsViewModel>(
            builder: (context, cvm, _) {
              final constants = cvm.tourneyConfig;
              return Column(
                children: [
                  const SizedBox(height: 12),
                  // Tournament Name
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.rosarivo(color: AppColors.onSurface),
                    onChanged: (val) => setState(() => _draftName = val),
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
                    initialValue: _draftDailyMinutes,
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
                    onChanged: (val) => setState(() => _draftDailyMinutes = val),
                  ),
                  const SizedBox(height: 16),

                  // Overall Duration dropdown
                  DropdownButtonFormField<int>(
                    initialValue: _draftOverallDays,
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
                    onChanged: (val) => setState(() => _draftOverallDays = val),
                  ),
                  const SizedBox(height: 20),

                  // Start Challenge button
                  context.watch<TourneyBloc>().state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : AppButton(
                          onPressed: _isValidDraft
                              ? () {
                                  context.read<TourneyBloc>().add(
                                        CreateChallenge(
                                          name: _draftName,
                                          dailyMins: _draftDailyMinutes!,
                                          overallDays: _draftOverallDays!,
                                        ),
                                      );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.3),
                          ),
                          child: Text(
                            'Start Challenge',
                            style: GoogleFonts.medievalSharp(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ),

                  BlocConsumer<TourneyBloc, TourneyState>(
                    listener: (context, state) {
                      if (state.hasActiveChallenge) {
                        Navigator.pop(context);
                      }
                    },
                    builder: (context, state) {
                      if (state.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            state.errorMessage!,
                            style: GoogleFonts.rosarivo(
                              fontSize: 12,
                              color: AppColors.primaryLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
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
