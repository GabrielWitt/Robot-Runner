import 'package:flame/palette.dart';

class Palette {
  PaletteEntry get seed => const PaletteEntry(Color.fromARGB(255, 238, 242, 150)); //(0xFF0050bc)
  PaletteEntry get text => const PaletteEntry(Color(0xee352b42));
  PaletteEntry get backgroundMain => const PaletteEntry(Color.fromARGB(255, 220, 242, 241));
  PaletteEntry get backgroundLevelSelection =>
      const PaletteEntry(Color.fromARGB(255, 54, 84, 134));
  PaletteEntry get backgroundPlaySession =>
      const PaletteEntry(Color.fromARGB(255, 127, 199, 217));
  PaletteEntry get backgroundSettings => const PaletteEntry(Color.fromARGB(255, 127, 199, 217));
}

//.fromARGB(255, 15, 16, 53)