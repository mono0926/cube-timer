import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scramble/presentation/scramble_visualizer.dart';
import '../domain/typing_game_state.dart';

class TypingGamePage extends ConsumerStatefulWidget {
  const TypingGamePage({super.key});

  @override
  ConsumerState<TypingGamePage> createState() => _TypingGamePageState();
}

class _TypingGamePageState extends ConsumerState<TypingGamePage>
    with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final GlobalKey<ScrambleVisualizerState> _visualizerKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _curvedAnimation;
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;
  late ConfettiController _confettiController;

  final List<({String visual, String logical})> _moveQueue = [];
  bool _isAnimating = false;
  String? _currentMove; // logical
  String? _currentVisualMove; // visual
  bool _isCheatSheetPinned = false;

  // Track the current sequence for commands or multi-move inputs
  List<String> _currentSequence = [];
  int _sequenceIndex = -1;
  String? _sequenceLabel; // e.g. "sexy"

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _onMoveAnimationComplete();
          }
        });
    _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _celebrationController.dispose();
    _confettiController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    if (value.trim().isEmpty) {
      _focusNode.requestFocus();
      return;
    }

    final rawTyped = value.trim();

    if (rawTyped.toLowerCase() == 'last') {
      _moveQueue.clear();
      _isAnimating = false;
      _currentMove = null;
      _currentSequence = [];
      _sequenceIndex = -1;
      _sequenceLabel = null;
      ref.read(typingGameStateProvider.notifier).setNearlySolved();
      _textController.clear();
      _focusNode.requestFocus();
      setState(() {});
      return;
    }
    final visualResolved =
        _visualizerKey.currentState?.resolveLogicalMove(rawTyped, map: false) ??
        rawTyped;
    final visualMoves = visualResolved
        .split(RegExp(r'\s+'))
        .where((m) => m.isNotEmpty)
        .toList();

    if (rawTyped != visualResolved) {
      // It's a command
      _currentSequence = visualMoves;
      _sequenceIndex = 0;
      _sequenceLabel = rawTyped;
    } else {
      _currentSequence = [];
      _sequenceIndex = -1;
      _sequenceLabel = null;
    }

    for (final vm in visualMoves) {
      final logicalMove =
          _visualizerKey.currentState?.resolveLogicalMove(vm) ?? vm;
      _moveQueue.add((visual: vm, logical: logicalMove));
    }
    _textController.clear();

    if (!_isAnimating) {
      _processNextMove();
    }
    _focusNode.requestFocus();
  }

  void _processNextMove() {
    if (_moveQueue.isEmpty) {
      _isAnimating = false;
      _currentMove = null;
      _currentVisualMove = null;
      _currentSequence = [];
      _sequenceIndex = -1;
      _sequenceLabel = null;
      setState(() {});

      final state = ref.read(typingGameStateProvider);
      if (state.isSolved) {
        _startCelebration();
      }
      return;
    }

    _isAnimating = true;
    final next = _moveQueue.removeAt(0);
    _currentMove = next.logical;
    _currentVisualMove = next.visual;

    if (_currentSequence.isNotEmpty) {
      _sequenceIndex = _currentSequence.length - _moveQueue.length - 1;
      // If we finished the sequence, clear it
      if (_sequenceIndex >= _currentSequence.length) {
        _currentSequence = [];
        _sequenceIndex = -1;
        _sequenceLabel = null;
      }
    }

    final move = _currentMove!;
    final faceChar = move.isNotEmpty ? move[0].toUpperCase() : '';
    final validFaces = [
      'U',
      'D',
      'F',
      'B',
      'R',
      'L',
      'M',
      'E',
      'S',
      'X',
      'Y',
      'Z',
    ];
    if (!validFaces.contains(faceChar)) {
      // Invalid move, skip without animation
      ref.read(typingGameStateProvider.notifier).applySingleMove(move);
      _processNextMove();
      return;
    }

    // Adjust duration for double moves (e.g. R2)
    final isDoubleMove = move.contains('2');
    _animationController.duration = Duration(
      milliseconds: isDoubleMove ? 800 : 400,
    );

    _animationController.forward(from: 0);
    HapticFeedback.lightImpact();
    setState(() {});
  }

  void _onMoveAnimationComplete() {
    // Apply the completed move to the state
    if (_currentMove != null) {
      ref.read(typingGameStateProvider.notifier).applySingleMove(_currentMove!);
    }

    // Process next in queue
    _processNextMove();
  }

  Future<void> _startCelebration() async {
    _isAnimating = false;
    _currentMove = null;
    _currentVisualMove = null;
    setState(() {});

    _confettiController.play();
    unawaited(HapticFeedback.heavyImpact());

    await _celebrationController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      _showClearDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(typingGameStateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('タイピングゲーム'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.5,
                  colors: [
                    Colors.purple.shade900,
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _animationController,
                        _celebrationController,
                      ]),
                      builder: (context, child) {
                        final victoryRotation = _celebrationAnimation.value * 2 * pi;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateX(victoryRotation * 2)
                            ..rotateY(victoryRotation)
                            ..rotateZ(victoryRotation * 3),
                            child: ScrambleVisualizer(
                              key: _visualizerKey,
                              cubeState: state,
                              animatingMove: _isAnimating ? _currentMove : null,
                              displayMove:
                                  _isAnimating ? _currentVisualMove : null,
                              animationProgress: _curvedAnimation.value,
                            ),
                        );
                      },
                    ),
                  ),
                ),
                if (_currentSequence.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: _buildSequenceDisplay(),
                  ),
                if (!_isCheatSheetPinned)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 2,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white10,
                          hintText: '例: R U F\'',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                        ),
                        onSubmitted: _onSubmitted,
                      ),
                    ),
                  ),
                if (_isCheatSheetPinned)
                  Expanded(
                    child: Container(
                      color: Colors.grey[900],
                      child: _buildCheatSheetContent(isPinned: true),
                    ),
                  )
                else
                  const SizedBox(height: 32),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
              createParticlePath: _drawStar,
            ),
          ),
        ],
      ),
      floatingActionButton: _isCheatSheetPinned
          ? null
          : FloatingActionButton.extended(
              onPressed: _showCheatSheet,
              icon: const Icon(Icons.help_outline),
              label: const Text('チートシート'),
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
            ),
    );
  }

  void _showCheatSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildCheatSheetContent(isPinned: false),
          ),
        );
      },
    );
  }

  Widget _buildCheatSheetContent({required bool isPinned}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '回転記号チートシート',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  const Text('常時表示', style: TextStyle(color: Colors.white70)),
                  Switch(
                    value: _isCheatSheetPinned,
                    activeThumbColor: Colors.amber,
                    onChanged: (val) {
                      setState(() {
                        _isCheatSheetPinned = val;
                      });
                      if (!isPinned && val) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheatSheetSection('基本回転 (外側)', [
                  'U',
                  'F',
                  'R',
                  'D',
                  'B',
                  'L',
                  "U'",
                  "F'",
                  "R'",
                  "D'",
                  "B'",
                  "L'",
                  'U2',
                  'F2',
                  'R2',
                  'D2',
                  'B2',
                  'L2',
                ]),
                _buildCheatSheetSection('2層回し (ワイド)', [
                  'u',
                  'f',
                  'r',
                  'd',
                  'b',
                  'l',
                ]),
                _buildCheatSheetSection('中間スライス', [
                  'M',
                  "M'",
                  'E',
                  "E'",
                  'S',
                  "S'",
                ]),
                _buildCheatSheetSection('持ち替え (全体回転)', [
                  'x',
                  "x'",
                  'y',
                  "y'",
                  'z',
                  "z'",
                ]),
                _buildCheatSheetSection('定石アルゴリズム', [
                  'sexy',
                  "sexy'",
                  'sune',
                  'antisune',
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSequenceDisplay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_sequenceLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _sequenceLabel!,
              style: const TextStyle(
                color: Colors.purpleAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          children: List.generate(_currentSequence.length, (index) {
            final isActive = index == _sequenceIndex;
            final isDone = index < _sequenceIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.purpleAccent
                    : (isDone ? Colors.white12 : Colors.white24),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isActive
                    ? [
                        const BoxShadow(
                          color: Colors.purpleAccent,
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _currentSequence[index],
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : (isDone ? Colors.white38 : Colors.white),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCheatSheetSection(String title, List<String> moves) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: moves.map((move) {
              return ActionChip(
                label: Text(
                  move,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.grey.shade700,
                side: BorderSide.none,
                onPressed: () {
                  if (!_isCheatSheetPinned) {
                    Navigator.of(context).pop();
                  }
                  _textController.text = move;
                  _onSubmitted(move);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// A custom Path to draw a star
  Path _drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (3.141592653589793 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = size.width / 2;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(-90);

    path.moveTo(
      size.width / 2,
      halfWidth + externalRadius * cos(fullAngle),
    );

    for (var step = 1; step <= numberOfPoints; step++) {
      path.lineTo(
        halfWidth + externalRadius * cos(fullAngle + step * degreesPerStep),
        halfWidth + externalRadius * sin(fullAngle + step * degreesPerStep),
      );
      path.lineTo(
        halfWidth +
            internalRadius *
                cos(fullAngle + step * degreesPerStep + halfDegreesPerStep),
        halfWidth +
            internalRadius *
                sin(fullAngle + step * degreesPerStep + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  void _showClearDialog() {
    _moveQueue.clear();
    _isAnimating = false;
    _currentMove = null;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('クリア！'),
          content: const Text('キューブが揃いました。'),
          actions: [
            TextButton(
              onPressed: () {
                _celebrationController.reset();
                _confettiController.stop();
                ref.read(typingGameStateProvider.notifier).reset();
                Navigator.of(context).pop();
                _focusNode.requestFocus();
              },
              child: const Text('もう一度'),
            ),
          ],
        );
      },
    );
  }
}
