module tt.audio;

private
{
    import core.runtime;
    import std.path;
    import std.string;

    import derelict.sdl2.sdl;
    import derelict.sdl2.mixer;
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

    _active = true;

    _audioPath = dirName(Runtime.args[0]) ~ "/audio/";

    auto filePath = _audioPath ~ "buzzer.wav";
    _sounds[Sound.Buzzer] = Mix_LoadWAV(filePath.toStringz());

    filePath = _audioPath ~ "click.wav";
    _sounds[Sound.Click] = Mix_LoadWAV(filePath.toStringz());
}

void audioTerm()
{
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
    if(_active && _sounds[sound])
        Mix_PlayChannel(-1, _sounds[sound], 0);
}
