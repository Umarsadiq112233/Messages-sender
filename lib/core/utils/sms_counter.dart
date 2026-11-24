/// SMS length rules.
///
/// GSM-7 (English): 160 characters = 1 SMS, 153 per part when longer.
/// Unicode (Urdu / emoji): 70 characters = 1 SMS, 67 per part when longer.
/// GSM extension characters (^ { } [ ] ~ | € \) count as two.
class SmsCount {
  const SmsCount({
    required this.characters,
    required this.unicode,
    required this.segments,
    required this.perSegment,
    required this.remaining,
  });

  final int characters;
  final bool unicode;
  final int segments;
  final int perSegment;
  final int remaining;

  int get singleLimit => unicode ? 70 : 160;

  static const _gsmBasic =
      '@£\$¥èéùìòÇ\nØø\rÅåΔ_ΦΓΛΩΠΨΣΘΞÆæßÉ !"#¤%&\'()*+,-./0123456789:;<=>?'
      '¡ABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÑÜ§¿abcdefghijklmnopqrstuvwxyzäöñüà';
  static const _gsmExt = '^{}\\[~]|€\f';

  static final Set<int> _basic = _gsmBasic.runes.toSet();
  static final Set<int> _ext = _gsmExt.runes.toSet();

  static SmsCount of(String text) {
    var unicode = false;
    var gsmLen = 0;
    for (final r in text.runes) {
      if (_basic.contains(r)) {
        gsmLen += 1;
      } else if (_ext.contains(r)) {
        gsmLen += 2;
      } else {
        unicode = true;
        break;
      }
    }
    final chars = unicode ? text.length : gsmLen; // UCS-2 counts UTF-16 units
    final single = unicode ? 70 : 160;
    final multi = unicode ? 67 : 153;
    if (chars == 0) {
      return SmsCount(characters: 0, unicode: unicode, segments: 0, perSegment: single, remaining: single);
    }
    if (chars <= single) {
      return SmsCount(characters: chars, unicode: unicode, segments: 1, perSegment: single, remaining: single - chars);
    }
    final segments = (chars / multi).ceil();
    return SmsCount(
      characters: chars,
      unicode: unicode,
      segments: segments,
      perSegment: multi,
      remaining: segments * multi - chars,
    );
  }
}
