import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../scramble/presentation/scramble_visualizer.dart';
import '../domain/typing_game_state.dart';

class TypingGamePage extends ConsumerStatefulWidget {
  const TypingGamePage({super.key});

  @override
  ConsumerState<TypingGamePage> createState() => _TypingGamePageState();
}

class _TypingGamePageState extends ConsumerState<TypingGamePage>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final GlobalKey<ScrambleVisualizerState> _visualizerKey = GlobalKey();

  late AnimationController _animationController;
  final List<String> _moveQueue = [];
  bool _isAnimating = false;
  String? _currentMove;
  bool _isCheatSheetPinned = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _onMoveAnimationComplete();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    final resolved = _visualizerKey.currentState?.resolveLogicalMove(rawTyped) ?? rawTyped;
    final moves = resolved.split(RegExp(r'\s+'));
    for (final m in moves) {
      if (m.isNotEmpty) {
        _moveQueue.add(m);
      }
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
      setState(() {});
      
      final state = ref.read(typingGameStateProvider);
      if (state.isSolved) {
        _showClearDialog();
      }
      return;
    }

    _isAnimating = true;
    _currentMove = _moveQueue.removeAt(0);

    final faceChar = _currentMove!.isNotEmpty ? _currentMove![0].toUpperCase() : '';
    if (!['U', 'D', 'F', 'B', 'R', 'L', 'M', 'E', 'S', 'X', 'Y', 'Z'].contains(faceChar)) {
      // Invalid move, skip without animation
      // However, we still apply it just in case logic updates (it won't do much)
      ref.read(typingGameStateProvider.notifier).applySingleMove(_currentMove!);
      _processNextMove();
      return;
    }

    _animationController.forward(from: 0);
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
                      animation: _animationController,
                      builder: (context, child) {
                        return ScrambleVisualizer(
                          key: _visualizerKey,
                          cubeState: state,
                          animatingMove: _isAnimating ? _currentMove : null,
                          animationProgress: _animationController.value,
                        );
                      },
                    ),
                  ),
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
        ],
      ),
      floatingActionButton: _isCheatSheetPinned ? null : FloatingActionButton.extended(
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
                    activeColor: Colors.amber,
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
                  'U', 'F', 'R', 'D', 'B', 'L',
                  "U'", "F'", "R'", "D'", "B'", "L'",
                  'U2', 'F2', 'R2', 'D2', 'B2', 'L2',
                ]),
                _buildCheatSheetSection('2層回し (ワイド)', [
                  'u', 'f', 'r', 'd', 'b', 'l',
                ]),
                _buildCheatSheetSection('中間スライス', [
                  'M', "M'", 'E', "E'", 'S', "S'",
                ]),
                _buildCheatSheetSection('持ち替え (全体回転)', [
                  'x', "x'", 'y', "y'", 'z', "z'",
                ]),
                _buildCheatSheetSection('定石アルゴリズム', [
                  'sexy', "sexy'", 'sune', 'antisune',
                ]),
              ],
            ),
          ),
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
