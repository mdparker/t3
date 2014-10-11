/**
This module provides a means to load and play sound effects through SDL2_mixer.
*/
module tt.audio;

private
{
    // See tt.gfx for explanations of the imports.
    import core.runtime;
    import std.path;
    import std.string;

    import derelict.sdl2.sdl;
    import derelict.sdl2.mixer;

    // This is imported because I want to catch any DerelictExceptions thrown by
    // DerelictSDL2Mixer.load. When working with DerelictExceptions, this is what
    // you need.
    import derelict.util.exception;
}

enum Sound
{
    Buzzer,
    Click
}

private
{
    string _audioPath;
    Mix_Chunk*[Sound.max + 1] _sounds;
    bool _active;
}

void audioInit()
{
    // Here, unlike in tt.gfx.gfxInit, I'm catching any DerelictExceptions thrown on load.
    // SDL2_mixer is not essential to the running of the program. If it fails to load, the
    // program will still go on, just without audio. So, I'm catching the exception and
    // swallowing it. It's perfectly feasible to just catch Exception rather than
    // DerelictException, then I wouldn't need the util import above. If I weren't eating
    // this one, that's exactly what I would do. But, on the off chance that another
    // type of Exception propagates up from Derelict.load, I don't want to eat that one.
    try
    {
        DerelictSDL2Mixer.load();
    }
    catch(DerelictException de)
    {
        return;
    }

    if(SDL_InitSubSystem(SDL_INIT_AUDIO) < 0)
        return;

    if(Mix_OpenAudio(22050, MIX_DEFAULT_FORMAT, 2, 32) < 0)
        return;

    // The audio system is initialized, so the _active flag can safely be set. An exercise for
    // the reader could be to make it possible for the user to activate/deactivate audio
    // via the keyboard.
    _active = true;

    // This is the same ting I did in tt.gfx.gfxInit, where I explain what's going on.
    _audioPath = dirName(Runtime.args[0]) ~ "/audio/";

    auto filePath = _audioPath ~ "buzzer.wav";
    _sounds[Sound.Buzzer] = Mix_LoadWAV(filePath.toStringz());

    filePath = _audioPath ~ "click.wav";
    _sounds[Sound.Click] = Mix_LoadWAV(filePath.toStringz());
}

void audioTerm()
{
    // audioTerm is always called, even if the shared library was never loaded. This
    // check ensures that any Mix_* functions called here were actually loaded. Without
    // this, the calls below could potentially be using null funciton pointers, which
    // would cause a crash when the game exits.
    if(!DerelictSDL2Mixer.isLoaded) return;

    foreach(sound; _sounds)
    {
        if(sound)
            Mix_FreeChunk(sound);
    }
    _sounds[] = null;

    Mix_CloseAudio();
    _active = false;
}

void play(Sound sound)
{
    // Only attempt to play a sound if the audio system is active *and* the sound has been loaded.
    if(_active && _sounds[sound])
        Mix_PlayChannel(-1, _sounds[sound], 0);
}
