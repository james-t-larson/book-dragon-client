import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/tourney_service.dart';
import '../repositories/constants_repository.dart';
import '../blocs/constants/constants_bloc.dart';
import '../blocs/tourney/tourney_bloc.dart';
import '../blocs/tourney/tourney_event.dart';
import '../blocs/tourney/tourney_state.dart';
import '../repositories/tourney_repository.dart';
import '../view_models/constants_view_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/join_or_create_dialog.dart';

/// The Tourney Hall (Challenges) screen.
///
/// Creates its own [TourneyBloc] in [initState] so the taunt timer and
/// any polling are scoped exclusively to this screen's lifetime.
class TourneyScreen extends StatefulWidget {
  final User user;
  final String token;
  final http.Client? httpClient;

  const TourneyScreen({
    super.key,
    required this.user,
    required this.token,
    this.httpClient,
  });

  @override
  State<TourneyScreen> createState() => _TourneyScreenState();
}

class _TourneyScreenState extends State<TourneyScreen>
    with SingleTickerProviderStateMixin {
  late final TourneyBloc _bloc;
  ConstantsViewModel? _constantsViewModel;
  late final AnimationController _dragonBobController;
  late final Animation<double> _dragonBobAnimation;
  bool _isInitializingConstants = true;

  @override
  void initState() {
    super.initState();
    _bloc = TourneyBloc(
      repository: TourneyRepository(
        service: TourneyService(
          token: widget.token,
          client: widget.httpClient,
        ),
      ),
    )..add(FetchInitialData());

    _initConstants();

    // Gentle hovering animation for the flying dragon
    _dragonBobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _dragonBobAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _dragonBobController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initConstants() async {
    final prefs = await SharedPreferences.getInstance();
    final service = TourneyService(token: widget.token, client: widget.httpClient);
    final repository = ConstantsRepository(service: service, prefs: prefs);
    final bloc = ConstantsBloc(repository: repository);
    
    if (mounted) {
      setState(() {
        _constantsViewModel = ConstantsViewModel(bloc: bloc)..loadConstants();
        _isInitializingConstants = false;
      });
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _dragonBobController.dispose();
    super.dispose();
  }

  void _showJoinOrCreateDialog(BuildContext context, ConstantsViewModel cvm) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: _bloc,
        child: JoinOrCreateDialog(
          constantsViewModel: cvm,
        ),
      ),
    );
  }

  void _shareInviteLink() {
    SharePlus.instance.share(
      ShareParams(text: _bloc.state.inviteLinkText),
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
    if (_isInitializingConstants || _constantsViewModel == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF2E1C15),
        body: Center(child: CircularProgressIndicator(color: AppColors.shimmer)),
      );
    }

    return MultiProvider(
      providers: [
        BlocProvider<TourneyBloc>.value(value: _bloc),
        ChangeNotifierProvider.value(value: _constantsViewModel!),
      ],
      child: BlocBuilder<TourneyBloc, TourneyState>(
        builder: (context, state) {
          // Manage animation based on state
          if (state.hasActiveChallenge) {
            if (!_dragonBobController.isAnimating) {
              _dragonBobController.repeat(reverse: true);
            }
          } else {
            if (_dragonBobController.isAnimating) {
              _dragonBobController.stop();
            }
          }
          
          return Consumer<ConstantsViewModel>(
            builder: (context, cvm, _) {
              return Scaffold(
                backgroundColor: const Color(0xFF2E1C15),
                extendBodyBehindAppBar: true,
                appBar: _buildAppBar(state),
                body: _buildBody(context, state, cvm),
              );
            },
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App Bar
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar(TourneyState state) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: state.hasActiveChallenge
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  state.activeTourney!.name,
                  style: GoogleFonts.medievalSharp(
                    fontSize: 20,
                    color: AppColors.shimmer,
                  ),
                ),
                if (state.dailyMinutesLeftText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.dailyMinutesLeftText!,
                    style: GoogleFonts.rosarivo(
                      fontSize: 14,
                      color: AppColors.shimmer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            )
          : Text(
              'Tourney Hall',
              style: GoogleFonts.medievalSharp(
                color: AppColors.onBackground,
              ),
            ),
      actions: [
        if (!state.hasActiveChallenge)
          IconButton(
            key: const Key('tourney_add_button'),
            icon: const Icon(Icons.add, color: AppColors.shimmer, size: 28),
            onPressed: () => _showJoinOrCreateDialog(context, _constantsViewModel!),
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

  Widget _buildBody(BuildContext context, TourneyState state, ConstantsViewModel cvm) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background — tourney hall
        Positioned.fill(
          child: Image.asset(
            'assets/images/rooms/tourney-hall.png',
            fit: BoxFit.cover,
            // Graceful fallback if asset not yet generated:
            errorBuilder: (context, error, stackTrace) => Container(
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
        if (state.isLoading || cvm.isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.shimmer),
          ),

        // ---- Active challenge elements ----

        // Overall progress bar (bottom)
        if (state.hasActiveChallenge)
          Positioned(
            bottom: 30, // Just above the bottom edge
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.shimmer.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Overall Tourney Progress',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 16,
                      color: AppColors.shimmer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: state.overallProgressPercentage,
                      minHeight: 12,
                      backgroundColor: AppColors.background.withValues(alpha: 0.6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.shimmer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Flying dragon (only when challenge is active)
        if (state.hasActiveChallenge)
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
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

        // Knight + taunt bubble (only when challenge active & today incomplete)
        if (state.hasActiveChallenge && !state.isDailyComplete)
          Positioned(
            bottom: screenSize.height * 0.18,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Taunt chat bubble above the knight
                if (state.currentTaunt.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, left: 60),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: ChatBubble(
                        key: ValueKey<String>(state.currentTaunt),
                        text: state.currentTaunt,
                      ),
                    ),
                  ),
                // Knight character
                Image.asset(
                  'assets/images/characters/knight.png',
                  width: 160,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.shield,
                    size: 100,
                    color: AppColors.shimmer.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

        // Error snackbar-like display (Tourney errors)
        if (state.errorMessage != null)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildErrorBanner(state.errorMessage!),
          ),

        // Error snackbar-like display (Constants errors)
        if (cvm.errorMessage != null)
          Positioned(
            bottom: 80,
            left: 20,
            right: 20,
            child: _buildErrorBanner(cvm.errorMessage!),
          ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: GoogleFonts.rosarivo(
          color: AppColors.onPrimary,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
