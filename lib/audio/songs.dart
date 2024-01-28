const List<Song> songs = [
  Song('boss-battle-theme.mp3', 'Battle RPG Theme', artist: 'CleytonKauffman'),
  Song('technogeek.mp3', 'tEcHNo gEeK', artist: 'mrpoly'),
  Song('PowerRangers8Bit.mp3', 'Go Go PowerRangers 8 Bit', artist: '8 bit Universe'),
];

class Song {
  final String filename;

  final String name;

  final String? artist;
  
  const Song(this.filename, this.name, {this.artist});

  @override
  String toString() => 'Song<$filename>';
}