import 'package:flutter/material.dart';

// =====================================================
//  THEME 1: 大地手帳  Organic Journal
// =====================================================
const _oBg = Color(0xFFE8EDE5);
const _oSurface = Color(0xFFE8DCC7);
const _oPrimary = Color(0xFFC66B3D);
const _oAccent = Color(0xFFC08E3A);
const _oText = Color(0xFF2D3319);
const _oMuted = Color(0xFF606C38);

// =====================================================
//  THEME 2: 極簡白  Minimal White
// =====================================================
const _wBg = Color(0xFFF8F8F8);
const _wSurface = Colors.white;
const _wPrimary = Color(0xFF333333);
const _wAccent = Color(0xFF888888);
const _wText = Color(0xFF1A1A1A);
const _wMuted = Color(0xFF999999);

// =====================================================
//  THEME 3: 櫻花粉  Sakura Pink
// =====================================================
const _pBg = Color(0xFFFFF5F5);
const _pSurface = Color(0xFFFFF0F0);
const _pPrimary = Color(0xFFE8738A);
const _pAccent = Color(0xFFF4A3B3);
const _pText = Color(0xFF4A3040);
const _pMuted = Color(0xFFA88890);

// =====================================================
//  THEME 4: 深夜藍  Midnight Blue
// =====================================================
const _dBg = Color(0xFF1A1D2E);
const _dSurface = Color(0xFF252840);
const _dPrimary = Color(0xFF7B8CDE);
const _dAccent = Color(0xFF5B9BD5);
const _dText = Color(0xFFE0E0F0);
const _dMuted = Color(0xFF8888AA);

// =====================================================
//  THEME 5: 赛博朋克  Cyberpunk
// =====================================================
const _cyBg = Color(0xFF0D0D0D);
const _cySurface = Color(0xFF1A1A1A);
const _cyPrimary = Color(0xFFFFE900);
const _cyAccent = Color(0xFFFF006E);
const _cyText = Color(0xFFE0E0E0);
const _cyMuted = Color(0xFF666666);

// =====================================================
//  THEME 6: 深海  Deep Sea
// =====================================================
const _dsBg = Color(0xFF0A1628);
const _dsSurface = Color(0xFF112240);
const _dsPrimary = Color(0xFF64FFDA);
const _dsAccent = Color(0xFF48B5C4);
const _dsText = Color(0xFFCCD6F6);
const _dsMuted = Color(0xFF8892B0);

// =====================================================
//  THEME 7: 極光炸裂  Aurora Burst
// =====================================================
const _auBg = Color(0xFF0B0015);
const _auSurface = Color(0xFF150028);
const _auPrimary = Color(0xFF00FF88);
const _auAccent = Color(0xFFBF5FFF);
const _auText = Color(0xFFE8E8FF);
const _auMuted = Color(0xFF9966CC);

// =====================================================
//  THEME 8: 暖紙  Warm Paper
// =====================================================
const _wpBg = Color(0xFFE8DCB8);
const _wpSurface = Color(0xFFF0E8D0);
const _wpPrimary = Color(0xFF8B4513);
const _wpAccent = Color(0xFFCD853F);
const _wpText = Color(0xFF3D2B1F);
const _wpMuted = Color(0xFF8B7355);

// =====================================================
//  THEME 9: 青夜  Cyan Night
// =====================================================
const _cnBg = Color(0xFF0D1B2A);
const _cnSurface = Color(0xFF14273A);
const _cnPrimary = Color(0xFF00D4FF);
const _cnAccent = Color(0xFF0099CC);
const _cnText = Color(0xFFD0E8F0);
const _cnMuted = Color(0xFF6699AA);

// =====================================================
//  THEME 10: 素白  Plain White
// =====================================================
const _pwBg = Color(0xFFFFFFFF);
const _pwSurface = Color(0xFFF5F5F5);
const _pwPrimary = Color(0xFF444444);
const _pwAccent = Color(0xFFAAAAAA);
const _pwText = Color(0xFF111111);
const _pwMuted = Color(0xFFAAAAAA);

// =====================================================
//  THEME 11: 草香  Grass Scent
// =====================================================
const _gsBg = Color(0xFFEEF5E8);
const _gsSurface = Color(0xFFF5FAF0);
const _gsPrimary = Color(0xFF4A7C3F);
const _gsAccent = Color(0xFF7CB342);
const _gsText = Color(0xFF2D3319);
const _gsMuted = Color(0xFF7A8B6E);

// =====================================================
//  THEME 12: 沉思  Meditation
// =====================================================
const _meBg = Color(0xFF1A1530);
const _meSurface = Color(0xFF252040);
const _mePrimary = Color(0xFFD4A843);
const _meAccent = Color(0xFFC0855A);
const _meText = Color(0xFFE8E0D0);
const _meMuted = Color(0xFF887766);

// =====================================================
//  Theme config struct
// =====================================================

class _TC {
  final Color bg, surface, primary, accent, text, muted;
  final Brightness brightness;
  final String fontFamily;
  final double cardRadius;
  final double btnRadius;
  final Color shadowColor;
  final bool useShadows;
  final bool useBorders;
  final String titleStyle; // underline | dash | heart | accentBar | slash | wave | neon | stamp | dotBar | plain | leaf | center

  const _TC({
    required this.bg, required this.surface, required this.primary,
    required this.accent, required this.text, required this.muted,
    required this.brightness, required this.fontFamily,
    required this.cardRadius, required this.btnRadius,
    required this.shadowColor, required this.useShadows,
    required this.useBorders, required this.titleStyle,
  });
}

// =====================================================
//  Theme configs
// =====================================================

const _configs = {
  'organic': _TC(bg: _oBg, surface: _oSurface, primary: _oPrimary, accent: _oAccent, text: _oText, muted: _oMuted,
      brightness: Brightness.light, fontFamily: 'serif', cardRadius: 24, btnRadius: 18,
      shadowColor: Color(0x0F2D3319), useShadows: true, useBorders: true, titleStyle: 'underline'),
  'white': _TC(bg: _wBg, surface: _wSurface, primary: _wPrimary, accent: _wAccent, text: _wText, muted: _wMuted,
      brightness: Brightness.light, fontFamily: 'sans-serif', cardRadius: 8, btnRadius: 6,
      shadowColor: Color(0x0A000000), useShadows: false, useBorders: true, titleStyle: 'dash'),
  'pink': _TC(bg: _pBg, surface: _pSurface, primary: _pPrimary, accent: _pAccent, text: _pText, muted: _pMuted,
      brightness: Brightness.light, fontFamily: 'serif', cardRadius: 28, btnRadius: 22,
      shadowColor: Color(0x15E8738A), useShadows: true, useBorders: false, titleStyle: 'heart'),
  'dark': _TC(bg: _dBg, surface: _dSurface, primary: _dPrimary, accent: _dAccent, text: _dText, muted: _dMuted,
      brightness: Brightness.dark, fontFamily: 'sans-serif', cardRadius: 12, btnRadius: 8,
      shadowColor: Color(0x1F000000), useShadows: true, useBorders: true, titleStyle: 'accentBar'),
  'cyberpunk': _TC(bg: _cyBg, surface: _cySurface, primary: _cyPrimary, accent: _cyAccent, text: _cyText, muted: _cyMuted,
      brightness: Brightness.dark, fontFamily: 'sans-serif', cardRadius: 2, btnRadius: 2,
      shadowColor: Color(0x30FFE900), useShadows: true, useBorders: true, titleStyle: 'slash'),
  'deepsea': _TC(bg: _dsBg, surface: _dsSurface, primary: _dsPrimary, accent: _dsAccent, text: _dsText, muted: _dsMuted,
      brightness: Brightness.dark, fontFamily: 'serif', cardRadius: 16, btnRadius: 14,
      shadowColor: Color(0x2064FFDA), useShadows: true, useBorders: true, titleStyle: 'wave'),
  'aurora': _TC(bg: _auBg, surface: _auSurface, primary: _auPrimary, accent: _auAccent, text: _auText, muted: _auMuted,
      brightness: Brightness.dark, fontFamily: 'sans-serif', cardRadius: 0, btnRadius: 0,
      shadowColor: Color(0x4000FF88), useShadows: true, useBorders: true, titleStyle: 'neon'),
  'warmpaper': _TC(bg: _wpBg, surface: _wpSurface, primary: _wpPrimary, accent: _wpAccent, text: _wpText, muted: _wpMuted,
      brightness: Brightness.light, fontFamily: 'serif', cardRadius: 4, btnRadius: 2,
      shadowColor: Color(0x0A000000), useShadows: false, useBorders: true, titleStyle: 'stamp'),
  'cyannight': _TC(bg: _cnBg, surface: _cnSurface, primary: _cnPrimary, accent: _cnAccent, text: _cnText, muted: _cnMuted,
      brightness: Brightness.dark, fontFamily: 'sans-serif', cardRadius: 14, btnRadius: 12,
      shadowColor: Color(0x2500D4FF), useShadows: true, useBorders: true, titleStyle: 'dotBar'),
  'plainwhite': _TC(bg: _pwBg, surface: _pwSurface, primary: _pwPrimary, accent: _pwAccent, text: _pwText, muted: _pwMuted,
      brightness: Brightness.light, fontFamily: 'sans-serif', cardRadius: 0, btnRadius: 0,
      shadowColor: Color(0x00000000), useShadows: false, useBorders: true, titleStyle: 'plain'),
  'grass': _TC(bg: _gsBg, surface: _gsSurface, primary: _gsPrimary, accent: _gsAccent, text: _gsText, muted: _gsMuted,
      brightness: Brightness.light, fontFamily: 'serif', cardRadius: 20, btnRadius: 16,
      shadowColor: Color(0x104A7C3F), useShadows: true, useBorders: true, titleStyle: 'leaf'),
  'meditation': _TC(bg: _meBg, surface: _meSurface, primary: _mePrimary, accent: _meAccent, text: _meText, muted: _meMuted,
      brightness: Brightness.dark, fontFamily: 'serif', cardRadius: 18, btnRadius: 14,
      shadowColor: Color(0x15D4A843), useShadows: true, useBorders: true, titleStyle: 'center'),
};

// =====================================================
//  Theme builder
// =====================================================

ThemeData buildTheme(String id) {
  final c = _configs[id] ?? _configs['organic']!;
  return _build(c);
}

ThemeData _build(_TC c) {
  final onPrimary = c.brightness == Brightness.dark ? Colors.black : Colors.white;
  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.primary,
      brightness: c.brightness,
      primary: c.primary,
      secondary: c.accent,
      surface: c.surface,
      onPrimary: onPrimary,
      onSecondary: onPrimary,
      onSurface: c.text,
    ),
    fontFamily: c.fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: c.fontFamily, fontSize: 20,
        fontWeight: FontWeight.w600, color: c.text),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: c.useShadows ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(c.cardRadius),
        side: c.useBorders
            ? BorderSide(color: c.text.withAlpha(18), width: 0.5)
            : BorderSide.none,
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(c.btnRadius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(fontFamily: c.fontFamily, fontSize: 26, fontWeight: FontWeight.w700, color: c.text),
      headlineMedium: TextStyle(fontFamily: c.fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: c.text),
      bodyLarge: TextStyle(fontFamily: c.fontFamily, fontSize: 16, color: c.text),
      bodyMedium: TextStyle(fontFamily: c.fontFamily, fontSize: 14, color: c.muted),
    ),
  );
}

// =====================================================
//  Public theme info helpers
// =====================================================

String themeTitleStyle(String id) => _configs[id]?.titleStyle ?? 'underline';
double themeCardRadius(String id) => _configs[id]?.cardRadius ?? 24;
bool themeUseShadows(String id) => _configs[id]?.useShadows ?? true;

// =====================================================
//  Theme metadata for settings
// =====================================================

final allThemes = const [
  _TM('organic', '大地手帐', '温暖手帐', _oPrimary),
  _TM('pink', '樱花粉', '甜美柔和', _pPrimary),
  _TM('dark', '深夜蓝', '沉静深邃', _dPrimary),
  _TM('cyberpunk', '赛博朋克', '霓虹暗黑', _cyPrimary),
  _TM('deepsea', '深海', '静谧幽蓝', _dsPrimary),
  _TM('aurora', '极光炸裂', '炫光爆发', _auPrimary),
  _TM('warmpaper', '暖纸', '泛黄纸张', _wpPrimary),
  _TM('cyannight', '青夜', '青色夜幕', _cnPrimary),
  _TM('plainwhite', '素白', '极致留白', _pwPrimary),
  _TM('grass', '草香', '青草芬芳', _gsPrimary),
  _TM('meditation', '沉思', '冥想暗金', _mePrimary),
];

class _TM {
  final String id, name, desc;
  final Color color;
  const _TM(this.id, this.name, this.desc, this.color);
}
