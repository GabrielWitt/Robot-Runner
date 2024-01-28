import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:ranger_gabo/app_lifecycle/app_lifecycle.dart';

import 'package:ranger_gabo/audio/songs.dart';
import 'package:ranger_gabo/audio/sounds.dart';
import 'package:ranger_gabo/settings/settings.dart';

class AudioController {
  static final _log = Logger('AudioController');

  final AudioPlayer _musicPlayer;

  final List<AudioPlayer> _sfxPlayers;

  int _currentSfxPlayer = 0;

  final Queue<Song> _playlist;

  final Random _random = Random();

  SettingsController? _settings;

  ValueNotifier<AppLifecycleState>? _lifecycleNotifier;

  AudioController({int polyphony = 2})
      : assert(polyphony >= 1),
        _musicPlayer = AudioPlayer(playerId: 'musicPlayer'),
        _sfxPlayers = Iterable.generate(
                polyphony, (i) => AudioPlayer(playerId: 'sfxPlayer#$i'))
            .toList(growable: false),
        _playlist = Queue.of(List<Song>.of(songs)..shuffle()) {
    _musicPlayer.onPlayerComplete.listen(_handleSongFinished);
    unawaited(_preloadSfx());
  }

  void attachDependencies(AppLifecycleStateNotifier lifecycleStateNotifier,
    SettingsController settingsController) {
      _attachLifecycleNotifier(lifecycleStateNotifier);
      _attachSettings(settingsController);
  }

  void dispose() {
    _lifecycleNotifier?.removeListener(_handleAppLifecycle);
    _stopAllSound();
    _musicPlayer.dispose();
    for (final player in _sfxPlayers) {
      player.dispose();
    }
  }

  void playSfx(SfxType type) {
    final audioOn = _settings?.audioOn.value ?? false;
    if (!audioOn) {
      _log.fine(() => 'Ignoring playing sound ($type) because audio is muted.');
      return;
    }
    final soundsOn = _settings?.soundsOn.value ?? false;
    if (!soundsOn) {
      _log.fine(() =>
          'Ignoring playing sound ($type) because sounds are turned off.');
      return;
    }

    _log.fine(() => 'Playing sound: $type');
    final options = soundTypeToFilename(type);
    final filename = options[_random.nextInt(options.length)];
    _log.fine(() => '- Chosen filename: $filename');

    final currentPlayer = _sfxPlayers[_currentSfxPlayer];
    currentPlayer.play(AssetSource('./sfx/$filename'),
      volume: soundTypeToVolume(type));
    _currentSfxPlayer = (_currentSfxPlayer + 1) % _sfxPlayers.length;
  }

  void _attachLifecycleNotifier(AppLifecycleStateNotifier lifecycleStateNotifier) {
    _lifecycleNotifier?.removeListener(_handleAppLifecycle);
    lifecycleStateNotifier.addListener(_handleAppLifecycle);
    _lifecycleNotifier = lifecycleStateNotifier;
  }

  void _attachSettings(SettingsController settingsController) {
    if (_settings == settingsController) {
      return;
    }

    final oldSettings = _settings;
    if (oldSettings != null) {
      oldSettings.audioOn.removeListener(_audioOnHandler);
      oldSettings.musicOn.removeListener(_musicOnHandler);
      oldSettings.soundsOn.removeListener(_soundsOnHandler);
    }

    _settings = settingsController;

    settingsController.audioOn.addListener(_audioOnHandler);
    settingsController.musicOn.addListener(_musicOnHandler);
    settingsController.soundsOn.addListener(_soundsOnHandler);

    if (settingsController.audioOn.value && settingsController.musicOn.value) {
      if (kIsWeb) {
        _log.info('On the web, music can only start after user interaction.');
      } else {
        _playCurrentSongInPlayList();
      }
    }
  }

  void _audioOnHandler() {
    _log.fine('audioOn change to ${_settings!.audioOn.value}');
    if (_settings!.audioOn.value) {
      if (_settings!.musicOn.value) {
        _startOrResumeMusic();
      }
    } else {
      _stopAllSound();
    }
  }

  void _handleAppLifecycle() {
    switch (_lifecycleNotifier!.value) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _stopAllSound();
      case AppLifecycleState.resumed:
        if (_settings!.audioOn.value && _settings!.musicOn.value){
          _startOrResumeMusic();
        }
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _handleSongFinished(void _) {
    _log.info('Last song finished playing');
    _playlist.addLast(_playlist.removeFirst());
    _playCurrentSongInPlayList();
  }

  void _musicOnHandler() {
    if(_settings!.musicOn.value) {
      if (_settings!.audioOn.value){
        _startOrResumeMusic();
      }
    } else {
    _musicPlayer.pause();
    }
  }

  Future<void> _playCurrentSongInPlayList() async {
    _log.info(() => 'Playing ${_playlist.first} now.');
    try {
      await _musicPlayer.play(AssetSource('./music/${_playlist.first.filename}'));
    } catch (e) {
      _log.severe('Could not play song ${_playlist.first}', e);
    }

    if (!_settings!.audioOn.value || !_settings!.musicOn.value) {
      try {
        _log.fine('Settings changed while preparing to play song. '
            'Pausing music.');
        await _musicPlayer.pause();
      } catch (e) {
        _log.severe('Could not pause music player', e);
      }
    }
  }

  Future<void> _preloadSfx() async {
    _log.info('Preloading sound effects');

    await AudioCache.instance.loadAll(SfxType.values
      .expand(soundTypeToFilename)
      .map((path) => 'sfx/$path')
      .toList());
  }

  void _soundsOnHandler() {
    for (final player in _sfxPlayers) {
      if (player.state == PlayerState.playing) {
        player.stop();
      }
    }
  }

  void _startOrResumeMusic() async {
    if(_musicPlayer.source == null) {
      _log.info('No music source set. '
          'Start playing the current song in playlist.');
      await _playCurrentSongInPlayList();
      return;
    }

    _log.info('Resuming paused music');
    try {
      _musicPlayer.resume();
    } catch (e) {
      _log.severe('Error resuming music', e);
      _playCurrentSongInPlayList();
    }
  }

  void _stopAllSound() {
    _log.info('stopping all sound');
    _musicPlayer.pause();
    for (final player in _sfxPlayers) {
      player.stop();
    }
  }


  
}