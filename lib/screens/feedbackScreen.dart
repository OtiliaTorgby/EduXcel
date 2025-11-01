import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math; // for min/max

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _feedbackFocus = FocusNode();

  // Animation controllers
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final AnimationController _submitController; // drives progress -> success

  bool _isSubmitting = false;

  // limits
  final int _feedbackMax = 500;

  // email regex for basic validation
  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z]{2,})+$",
  );

  // --- UI THEME COLORS ---
  static const Color deepPurple = Color(0xFF6A1B9A);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const LinearGradient headerGradient = LinearGradient(
    colors: [deepPurple, accentPurple],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  // -------------------------

  @override
  void initState() {
    super.initState();

    // shake animation (used on invalid submit)
    _shakeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0).chain(CurveTween(curve: Curves.ease)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 8.0).chain(CurveTween(curve: Curves.ease)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0).chain(CurveTween(curve: Curves.ease)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 4.0).chain(CurveTween(curve: Curves.ease)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0).chain(CurveTween(curve: Curves.ease)), weight: 1),
    ]).animate(_shakeController);

    // submit animation: 0.0 -> 0.6 = progress, 0.6 -> 1.0 = success scale
    _submitController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    // Add listeners to rebuild when focus changes for highlighting
    _emailFocus.addListener(_handleFocusChange);
    _feedbackFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {}); // Rebuilds the widgets to update decoration based on focus
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    feedbackController.dispose();
    _emailFocus
      ..removeListener(_handleFocusChange)
      ..dispose();
    _feedbackFocus
      ..removeListener(_handleFocusChange)
      ..dispose();
    _shakeController.dispose();
    _submitController.dispose();
    super.dispose();
  }

  // Trigger a friendly shake when form invalid
  Future<void> _playShake() async {
    try {
      await _shakeController.forward(from: 0.0);
    } catch (_) {}
  }

  // main submit flow: validate -> animate -> success dialog -> clear
  Future<void> _validateAndSubmit() async {
    // close keyboard
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      HapticFeedback.lightImpact(); // Add haptic feedback on fail
      _playShake();
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    // animate progress portion
    try {
      await _submitController.animateTo(0.6,
          duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    } catch (_) {}

    // simulate network delay
    await Future.delayed(const Duration(milliseconds: 650));
    HapticFeedback.vibrate(); // Vibrate on success

    // finish animation to 1.0 (success pop)
    try {
      await _submitController.animateTo(1.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOutBack);
    } catch (_) {}

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // show animated success dialog
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Success',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: curved,
          child: Center(
            child: Material(
              color: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Slightly larger radius
              child: SizedBox(
                width: math.min(MediaQuery.of(context).size.width * 0.9, 400), // Max width control
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 64, color: deepPurple), // Larger icon
                      const SizedBox(height: 16),
                      const Text(
                        'Thanks — Feedback Received!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We appreciate your time. Your feedback will help us make the EduXcel better.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // reset submit animation for next use
    try {
      await _submitController.animateBack(0.0,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } catch (_) {}

    // clear inputs and focus back to email
    if (mounted) {
      emailController.clear();
      feedbackController.clear();
      _emailFocus.requestFocus();
      // small confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback submitted successfully')),
      );
    }
  }

  String? _emailValidator(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) return 'Email cannot be empty';
    if (!_emailRegex.hasMatch(trimmedValue)) return 'Enter a valid email address';
    return null;
  }

  String? _feedbackValidator(String? value) {
    final trimmedValue = value?.trim();
    if (trimmedValue == null || trimmedValue.isEmpty) return 'Feedback cannot be empty';
    if (trimmedValue.length < 10) return 'Please provide at least 10 characters';
    if (trimmedValue.length > _feedbackMax) return 'Feedback is too long';
    return null;
  }

  // Helper to create themed InputDecoration
  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    required bool isFocused,
  }) {
    final focusedBorderColor = isFocused ? accentPurple : Colors.grey.shade400;

    return InputDecoration(
      prefixIcon: Icon(icon, color: isFocused ? deepPurple : Colors.grey.shade600),
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(color: isFocused ? deepPurple : Colors.black54),
      fillColor: Colors.grey.shade50, // Slight fill for depth
      filled: true,
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // Use BorderSide.none for a cleaner look
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: focusedBorderColor, width: 2.0), // Highlight on focus
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // The AppBar is only used for the back button and system style
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: headerGradient),
          child: SafeArea(
            bottom: true, // Let SafeArea handle the bottom padding
            child: Column(
              children: [
                // Custom Header Title (Placed inside the gradient, below status bar)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20),
                  child: Column(
                    children: [
                      const Text(
                        'Send Feedback',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'We value your thoughts — tell us what we can improve.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Scrollable Form Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // form card with shake animation wrapper
                          AnimatedBuilder(
                            animation: _shakeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_shakeAnimation.value, 0),
                                child: child,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16), // Slightly larger radius
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.15), // Stronger shadow
                                      blurRadius: 16,
                                      offset: const Offset(0, 8)),
                                ],
                              ),
                              padding: const EdgeInsets.all(20), // Increased internal padding
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Email field
                                    TextFormField(
                                      controller: emailController,
                                      focusNode: _emailFocus,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.email],
                                      decoration: _inputDecoration(
                                        labelText: 'Your Email',
                                        hintText: 'you@example.com',
                                        icon: Icons.email_outlined,
                                        isFocused: _emailFocus.hasFocus,
                                      ),
                                      validator: _emailValidator,
                                      onFieldSubmitted: (_) => _feedbackFocus.requestFocus(),
                                    ),
                                    const SizedBox(height: 18),

                                    // Feedback field with live char count
                                    TextFormField(
                                      controller: feedbackController,
                                      focusNode: _feedbackFocus,
                                      keyboardType: TextInputType.multiline,
                                      minLines: 5, // Taller minimum height
                                      maxLines: 10,
                                      maxLength: _feedbackMax,
                                      textInputAction: TextInputAction.newline,
                                      decoration: _inputDecoration(
                                        labelText: 'Your Feedback',
                                        hintText: 'What worked well? What could we improve?',
                                        icon: Icons.feedback_outlined,
                                        isFocused: _feedbackFocus.hasFocus,
                                      ).copyWith(
                                        // Specific adjustments for multiline field
                                        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                                        prefixIcon: null, // Remove prefix icon from multiline field for better alignment
                                      ),
                                      validator: _feedbackValidator,
                                    ),

                                    const SizedBox(height: 20),

                                    // Submit + Clear row with animated button
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AnimatedBuilder(
                                            animation: _submitController,
                                            builder: (context, child) {
                                              // use submit controller value to switch between states
                                              final v = _submitController.value;
                                              // progress circle visible when v is in the middle range
                                              final showProgress = v > 0.05 && v < 0.7;
                                              final showCheck = v >= 0.9;
                                              return ElevatedButton(
                                                onPressed: _isSubmitting ? null : _validateAndSubmit,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: deepPurple,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 16), // Taller button
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                ),
                                                child: SizedBox(
                                                  height: 18,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Opacity(
                                                        opacity: showProgress || showCheck ? 0.0 : 1.0,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: const [
                                                            Icon(Icons.send, size: 18),
                                                            SizedBox(width: 8),
                                                            Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                                                          ],
                                                        ),
                                                      ),

                                                      // Circular progress overlay (animated)
                                                      if (showProgress)
                                                        const SizedBox(
                                                          width: 18,
                                                          height: 18,
                                                          child: CircularProgressIndicator(
                                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                            strokeWidth: 2.5, // Thicker stroke
                                                          ),
                                                        ),

                                                      // checkmark on success (v >= 0.9)
                                                      if (showCheck)
                                                        const Icon(Icons.check, size: 24, color: Colors.white), // Larger checkmark
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Refined Clear/Reset Button
                                        SizedBox(
                                          width: 50, // Fixed width for square look
                                          height: 50, // Fixed height for square look
                                          child: OutlinedButton(
                                            onPressed: _isSubmitting
                                                ? null
                                                : () {
                                              emailController.clear();
                                              feedbackController.clear();
                                              _emailFocus.requestFocus();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Form cleared')),
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.zero, // Remove default padding
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              side: const BorderSide(color: deepPurple, width: 1.5), // Themed border
                                              backgroundColor: deepPurple.withOpacity(0.05), // Light background fill
                                              foregroundColor: deepPurple,
                                            ),
                                            child: const Icon(Icons.refresh, color: deepPurple, size: 24), // Use refresh icon
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // footer notes
                          const SizedBox(height: 20),
                          Text(
                            'We won’t share your email. All feedback is kept confidential and helps improve the app experience.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
