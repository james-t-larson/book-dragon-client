import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/tourney_service.dart';
import '../view_models/tourney_view_model.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/join_or_create_dialog.dart';

/// The Tourney Hall (Challenges) screen.
///
/// Creates its own [TourneyViewModel] in [initState] so the taunt timer and
/// any polling are scoped exclusively to this screen's lifetime.
class TourneyScreen extends StatefulWidget {
  final User user;
  final String token;

  const TourneyScreen({super.key, required this.user, required this.token});

  @override
  State<TourneyScreen> createState() => _TourneyScreenState();
}

class _TourneyScreenState extends State<TourneyScreen>
    with SingleTickerProviderStateMixin {
  late final TourneyViewModel _viewModel;
  late final AnimationController _dragonBobController;
  late final Animation<double> _dragonBobAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = TourneyViewModel(
      service: TourneyService(token: widget.token),
      userDragonColor: widget.user.dragonColor ?? 'red',
    )..fetchInitialData();

    // Gentle hovering animation for the flying dragon
    _dragonBobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _dragonBobAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _dragonBobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _dragonBobController.dispose();
    super.dispose();
  }

  void _showJoinOrCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => JoinOrCreateDialog(viewModel: _viewModel),
    );
  }

  void _shareInviteLink() {
    SharePlus.instance.share(
      ShareParams(text: _viewModel.inviteLinkText),
    );
  }

  // Resolve the flying dragon asset path (matches sleeping asset names).
  String get _flyingDragonAsset {
    final color = widget.user.dragonColor?.toLowerCase() ?? 'red';
    const valid = {'pink', 'blue', 'moss', 'white', 'red', 'gold'};
    final name = valid.contains(color) ? color : 'red';
    return 'assets/images/dragons/flying/$name.png';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF2E1C15),
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: _buildBody(context),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // App Bar
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: _viewModel.hasActiveChallenge
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _viewModel.activeTourney!.name,
                  style: GoogleFonts.medievalSharp(
                    fontSize: 20,
                    color: AppColors.shimmer,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _viewModel.overallProgressPercentage,
                      minHeight: 8,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.shimmer,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Text(
              'Tourney Hall',
              style: GoogleFonts.medievalSharp(
                color: AppColors.onBackground,
              ),
            ),
      actions: [
        if (!_viewModel.hasActiveChallenge)
          IconButton(
            key: const Key('tourney_add_button'),
            icon: const Icon(Icons.add, color: AppColors.shimmer, size: 28),
            onPressed: _showJoinOrCreateDialog,
            tooltip: 'Join or Create Tourney',
          )
        else
          IconButton(
            key: const Key('tourney_share_button'),
            icon: const Icon(Icons.share, color: AppColors.shimmer, size: 26),
            onPressed: _shareInviteLink,
            tooltip: 'Share Invite Code',
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background — tourney hall
        Positioned.fill(
          child: Image.asset(
            'assets/images/rooms/tourney_hall.png',
            fit: BoxFit.cover,
            // Graceful fallback if asset not yet generated:
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A0F0A), Color(0xFF3A2518)],
                ),
              ),
            ),
          ),
        ),

        // Loading indicator
        if (_viewModel.isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.shimmer),
          ),

        // ---- Active challenge elements ----

        // Flying dragon (only when challenge is active)
        if (_viewModel.hasActiveChallenge)
          Positioned(
            top: screenSize.height * 0.2,
            left: screenSize.width * 0.15,
            child: AnimatedBuilder(
              animation: _dragonBobAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _dragonBobAnimation.value),
                  child: child,
                );
              },
              child: Image.asset(
                _flyingDragonAsset,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),

        // Knight + taunt bubble (only when challenge active & today incomplete)
        if (_viewModel.hasActiveChallenge && !_viewModel.isDailyComplete) ...[
          // Knight character
          Positioned(
            bottom: screenSize.height * 0.08,
            right: screenSize.width * 0.05,
            child: Image.asset(
              'assets/images/characters/knight.png',
              width: 160,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.shield,
                size: 100,
                color: AppColors.shimmer.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Taunt chat bubble above the knight
          if (_viewModel.currentTaunt.isNotEmpty)
            Positioned(
              bottom: screenSize.height * 0.32,
              right: screenSize.width * 0.02,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: ChatBubble(
                  key: ValueKey<String>(_viewModel.currentTaunt),
                  text: _viewModel.currentTaunt,
                ),
              ),
            ),
        ],

        // Error snackbar-like display
        if (_viewModel.errorMessage != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _viewModel.errorMessage!,
                style: GoogleFonts.rosarivo(
                  color: AppColors.onPrimary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
