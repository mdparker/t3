module tt.gfx;

private
{
    // In every D program, the path to the executable is passed to the main function in
    // args[0]. But a D program's main funciton is called not from the OS, but by the
    // D runtime, where the real entry point (an extern(C) main) is to be found. As it
    // happens, the runtime stores the args before passing them off to the D main. They
    // can be retrieved via Runtime.args found in core.runtime. This module uses Runtime.args[0]
    // to determine the app path so that the graphics can be found.
    import core.runtime;

    // Any string passed from a C library into D is easier to work with if it is first converted
    // from a C char* to a D string. std.conv.to, a templated funciton, does the job.
    import std.conv;

    // This module uses std.path.dirname to construct a path to the graphics. It would be better
    // to write the import like this: import std.path : dirname; However, there is currently a
    // bug in DMD which makes such imports public. Until that's fixed, I don't use that syntax.
    import std.path;

    // Strings passed from D to C must be converted from a D string to a C char*. This is easily
    // done with the std.string.toStringz function, which makes sure the string is zero-terminated.
    import std.string;

    import derelict.sdl2.sdl;
    import derelict.sdl2.image;

    import tt.config;
}

private
{
    // No need to initialize anything here. The default values are what I want.
    string _gfxPath;
    SDL_Window* _window;
    SDL_Renderer* _renderer;
    Texture _board;
    Texture[2] _xo;

    // This is a simple wrapper for loading and unload SDL textures. This isn't a necessity, but makes
    // for cleaner code below.
    struct Texture
    {
        SDL_Texture* tex;

        void load(string imgName)
        {
            auto imagePath = _gfxPath ~ imgName;
            auto surface = IMG_Load(imagePath.toStringz());
            if(!surface)
                throw new Error(format("Failed to load image file %s: %s", imagePath, to!string(SDL_GetError())));

            auto color = SDL_MapRGB(surface.format, 0, 0, 0);
            if(SDL_SetColorKey(surface, SDL_TRUE, color) < 0)
                throw new Error(format("Failed to set color key on image %s: %s", imagePath, to!string(SDL_GetError())));

            tex = SDL_CreateTextureFromSurface(_renderer, surface);
            if(!tex)
            {
                throw new Error(format("Failed to create texture from image %s: %s", imagePath, to!string(SDL_GetError())));
            }

            SDL_FreeSurface(surface);
        }

        void unload()
        {
            if(tex)
            {
                SDL_DestroyTexture(tex);
                tex = null;
            }
        }
    }
}

/**
    Initializes SDL and SDL_image, creates the window & renderer and loads all textures.
*/
void gfxInit()
{
    // Notice than for all of these function calls I'm throwing Errors on failure rather than
    // Exceptions. This is because I have no intention of catching them. Much like Java's
    // RuntimeException, D's Error class indicates a fatal, unrecoverable error and that
    // is not intended to be handled. It can be caught, but it is expected that the app will
    // still exit after manipulating the Error instance. Since this is a game and not a library,
    // and I know for sure that I am not recovering from any failures here, I've used Error to
    // signify that intent in code.
    if(SDL_Init(SDL_INIT_VIDEO) < 0)
        throw new Error("Failed to initialze SDL: " ~ to!string(SDL_GetError()));

    if(IMG_Init(IMG_INIT_PNG) != IMG_INIT_PNG)
        throw new Error("Failed to initialize SDL_image: " ~ to!string(IMG_GetError()));

    _window = SDL_CreateWindow("T3", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 600, 600, SDL_WINDOW_SHOWN);
    if(!_window)
        throw new Error("Failed to create window: " ~ to!string(SDL_GetError()));

    _renderer = SDL_CreateRenderer(_window, -1, 0);
    if(!_renderer)
        throw new Error("Failed to create renderer: " ~ to!string(SDL_GetError()));

    // Runtime.args[0] has the app path. dirName strips the name of the application from the
    // path such that /foo/bar/app.exe becomes /foo/bar. Then I append "/gfx/" to that, allowing
    // me to load textures relative to the app directory rather than the working directory, which
    // may be different.
    auto path = Runtime.args[0];
    _gfxPath = dirName(path) ~ "/gfx/";

    _board.load("board.png");
    _xo[XMark].load("x.png");
    _xo[OMark].load("o.png");
}

/**
 Releases all resources allocated in gfxInit.
*/
void gfxTerm()
{
    if(_renderer)
    {
        _xo[OMark].unload();
        _xo[XMark].unload();
        _board.unload();

        SDL_DestroyRenderer(_renderer);
        _renderer = null;
    }

    if(_window)
    {
        SDL_DestroyWindow(_window);
        _window = null;
    }

    // The checks above for _renderer and _window being non-null are for obvious reaons, but the call
    // here to DerelictSDL2.isLoaded might not be. When DerelictSDL2.load() is called, it loads the
    // SDL2 shared library manually via the OS API. This means that all of the functions you call are
    // actually function pointers. If DerelictSDL2 failed to load, then one or more of the pointers to
    // SDL functions will be null. For the rest of the program, this is not an issue as that code will
    // never be run if the library fails to load. Derelict throws an Exception in that case, and in
    // tt.main.init I let that go without catching it, so the app will exit. However, the scope(exit) in
    // tt.main.init ensures that tt.main.term is always called, and tt.main.term always calls gfxTerm.
    // So it is possible that SDL_Quit will be null when this part is reaches. The call to
    // DerelictSDL2.isLoaded ensures that SDL_Quit will not be called if the library was never loaded.
    // This is an important consideration when you do this sort of lifecycle management with a Derelict
    // program. There are other ways to handle this (such as not calling term when a lib fails to load),
    // but this is the way I always do it.
    if(DerelictSDL2.isLoaded)
        SDL_Quit();
}

/**
 The current implementation only clears the screen. If you need to do any prerender setup, this is
 the place to add it.
*/
void renderBegin()
{
    SDL_RenderClear(_renderer);
}

/**
 The current implementation displays the back buffer. This is where you would add postrender
 effects or cleanup.
*/
void renderEnd()
{
    SDL_RenderPresent(_renderer);
}

/**
    Renders the board, including the X and O marks.
*/
void renderBoard(const ubyte[] board)
{
    // Draw the board itself (the lines).
    SDL_RenderCopy(_renderer, _board.tex, null, null);

    // Check each item in the array and determine if it is an X or O mark. If so, render it.
    // Note that this foreach loop has two intial parameters, i and mark. mark is automatically
    // inferred to be a ubyte, since board is a ubyte array. If only one initial parameter were
    // given, this would be it. When two are given, the first, in this case i, is inferred to
    // be the array index of the second value. It's equivalent to the following for loop:
    // for(int i=0; i<board.length; ++i) { ubyte mark = board[i]; }
    foreach(i, mark; board)
    {
        if(mark == XMark || mark == OMark)
        {
            // More basic tile map math, this time to convert an array index into (x,y) screen coordinates.
            int x = (i%3) * SquareWidth;
            int y = (i/3) * SquareHeight;
            SDL_Rect dst = SDL_Rect(x, y, SquareWidth, SquareHeight);
            SDL_RenderCopy(_renderer, _xo[mark].tex, null, &dst);
        }
    }
}

