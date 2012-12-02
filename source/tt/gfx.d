module tt.gfx;

private
{
    import core.runtime;
    import std.conv;
    import std.path;
    import std.string;

    import derelict.sdl2.sdl;
    import derelict.sdl2.image;

    import tt.config;
}

private
{
    string _gfxPath;
    SDL_Window* _window;
    SDL_Renderer* _renderer;
    Texture _board;
    Texture[2] _xo;

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

void gfxInit()
{
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

    auto path = Runtime.args[0];
    _gfxPath = dirName(path) ~ "/gfx/";

    _board.load("board.png");
    _xo[XMark].load("x.png");
    _xo[OMark].load("o.png");
}

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
}

void renderBegin()
{
    SDL_RenderClear(_renderer);
}

void renderEnd()
{
    SDL_RenderPresent(_renderer);
}

void renderBoard(ubyte[] board)
{
    SDL_RenderCopy(_renderer, _board.tex, null, null);

    foreach(i, mark; board)
    {
        if(mark == XMark || mark == OMark)
        {
            int x = (i%3) * SquareWidth;
            int y = (i/3) * SquareHeight;
            SDL_Rect dst = SDL_Rect(x, y, SquareWidth, SquareHeight);
            SDL_RenderCopy(_renderer, _xo[mark].tex, null, &dst);
        }
    }
}

