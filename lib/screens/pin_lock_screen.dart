import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSetupMode;
  const PinLockScreen({Key? key, this.isSetupMode = false}) : super(key: key);

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = '';
  String _firstSetupPin = '';
  bool _isConfirming = false;
  bool _hasError = false;

  void _onKeyPress(String key) {
    if (_enteredPin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin += key;
        _hasError = false;
      });

      if (_enteredPin.length == 4) {
        _processPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
      });
    }
  }

  Future<void> _processPin() async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (widget.isSetupMode) {
      if (!_isConfirming) {
        setState(() {
          _firstSetupPin = _enteredPin;
          _enteredPin = '';
          _isConfirming = true;
        });
      } else {
        if (_enteredPin == _firstSetupPin) {
          await SettingsService.togglePinLock(true, pin: _enteredPin);
          if (mounted) Navigator.pop(context, true);
        } else {
          _showError();
        }
      }
    } else {
      // Unlock mode
      if (_enteredPin == SettingsService.savedPin) {
        HapticFeedback.heavyImpact();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      } else {
        _showError();
      }
    }
  }

  void _showError() {
    HapticFeedback.heavyImpact();
    setState(() {
      _hasError = true;
      _enteredPin = '';
    });
    if (widget.isSetupMode && _isConfirming) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _isConfirming = false;
            _hasError = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : AppTheme.slate900;

    String title = 'Masukkan PIN';
    if (widget.isSetupMode) {
      title = _isConfirming ? 'Konfirmasi PIN' : 'Buat PIN Baru';
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.midnightScaffold : AppTheme.pearlScaffold,
      appBar: widget.isSetupMode
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: color),
            )
          : null,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(Icons.lock_rounded, size: 60, color: AppTheme.emerald)
                .animate(target: _hasError ? 1 : 0)
                .shake(duration: 400.ms, hz: 4, offset: const Offset(10, 0)),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasError
                  ? 'PIN salah, coba lagi'
                  : 'Keamanan ekstra untuk data Anda',
              style: TextStyle(
                fontSize: 14,
                color: _hasError ? Colors.red : AppTheme.slate500,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length
                        ? AppTheme.emerald
                        : (isDark ? AppTheme.slate800 : Colors.black12),
                  ),
                );
              }),
            ).animate(target: _hasError ? 1 : 0).shakeX(),
            const Spacer(),
            _buildKeypad(color, isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad(Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('1', color, isDark),
              _buildKey('2', color, isDark),
              _buildKey('3', color, isDark),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('4', color, isDark),
              _buildKey('5', color, isDark),
              _buildKey('6', color, isDark),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey('7', color, isDark),
              _buildKey('8', color, isDark),
              _buildKey('9', color, isDark),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70), // empty space
              _buildKey('0', color, isDark),
              SizedBox(
                width: 70,
                child: IconButton(
                  onPressed: _onDelete,
                  icon: Icon(Icons.backspace_rounded, color: color),
                  iconSize: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number, Color textColor, bool isDark) {
    return GestureDetector(
      onTap: () => _onKeyPress(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? AppTheme.slate800.withValues(alpha: 0.5) : Colors.white,
          border: Border.all(color: (isDark ? Colors.white : AppTheme.slate900).withValues(alpha: 0.05)),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
