/**
Provides the main entry point, intialization and shutdown, and control of the game flow.

This module provides the basic lifecycle of the game. On startup, required libraries are loaded and
then modules which require initialization are intiialized. Then the game loop is entered. All input
is processed in this module. When the game loop exits, each module's termination function is called
and the app exits.

*/
module app;

private
{
    // tt.main initializes both DerelictSDL2 and DerelictSDL2Image (see the init)
    // method for the reasons why). SDL events are also handled here.
    import derelict.sdl2.sdl;
    import derelict.sdl2.image;

    // The APIs in tt.audio and tt.gfx are used in tt.game, not here. However,
    // initialization and termination is handled here, so both modules need to
    // be imported.
    import tt.audio;
    import tt.gfx;

    // Only a couple of values from tt.config are used here, but tt.game is used extensively.
    import tt.config;
    import tt.game;
}

void main(string[] args)
{
    // Anything in a scope(exit) block will be called when the current scope exits, regardless
    // if the scope exited normally or via an exception being thrown. So, in this case, the
    // term() function will always be called when the app exits.
    scope(exit) term();

    // Initialize the other modules.
    init();

    // Enter the game loop.
    run();
}

private
{
    // bools in D have a default value of 'false', which is what I want for this flag.
    bool _running;

    // Class references in D are default-initialized to null, so these references will need to be assigned
    // something via 'new' before they can be used.
    Game _game;
    HumanPlayer _mousePlayer;
    HumanPlayer _keyboardPlayer;

    // The Player class is implemented in tt.game. The HumanPlayer serves one purpose: providing a
    // convenient means of passing Mouse or Keyboard input to the game object. This could easily be
    // done without a Player class, but the system as implemented makes it easier to swap out Player
    // instances with something other than a local human, such as an AIPlayer or NetworkPlayer.
    final class HumanPlayer : Player
    {
        public override
        {
            // Called once per frame by the Game class. This is HumanPlayer's chance to update
            // the game board based on the most recent player input.
            void update()
            {
                // If input has recently been received and not yet sent to the game, then _nextIndex
                // will have been set during event processing and will be of a value other than 255.
                if(_nextIndex != 255)
                {
                    _game.setActiveMark(_nextIndex);
                    _nextIndex = 255;
                }
            }
        }

        private
        {
            // This constructor is private because instances of HumanPlayer are only constructed
            // in this module. They cannot be constructed anywhere else.
            this(string name)
            {
                super(name);
                _nextIndex = 255;
            }

            // This is a property setter, callable like "player.nextIndex = i".
            void nextIndex(uint idx) @property
            {
                // Only accept the value if there is a game in progress *and* this player is active.
                if(!_game.over && isActive) _nextIndex = idx;
            }
        }

        private
        {
            // If true, then this player accepts Mouse input. Otherwise, input comes from the
            // keyboard.
            bool _useMouse;

            // When update is next called, this value will be passed to _game.setActiveMark to
            // update the value in the game board array at _nextIndex.
            uint _nextIndex;
        }
    }

    void init()
    {
        // This could be moved into gfxInit, of course. But it's habit for me to initialize all
        // *required* shared libraries in the main module's init method. If these shared libs
        // fail to load, there's  no reason to continue. Note that the DerelictSDL2Mixer is not
        // called here. That's because the app can still run without it, so it is loaded in
        // the audioInit function.
        DerelictSDL2.load();
        DerelictSDL2Image.load();

        // Create the window and the SDL renderer, load textures.
        gfxInit();

        // Initialize SDL2_mixer and load the sound effects.
        audioInit();
    }

    void term()
    {
        // Terminate in the reverse order of initialization. Always recommended no matter
        // which language you are using.
        audioTerm();
        gfxTerm();
    }

    void run()
    {
        _running = true;
        uint lastTick = SDL_GetTicks();
        uint currentTick, delta;

        _mousePlayer = new HumanPlayer("Player1");
        _keyboardPlayer = new HumanPlayer("Player2");
        _game = new Game(_mousePlayer, _keyboardPlayer);

        while(_running)
        {
            currentTick = SDL_GetTicks();
            delta = currentTick - lastTick;
            lastTick = currentTick;

            handleEvents();
            _game.update(delta);
            render();
            SDL_Delay(1);
        }
    }

    void render()
    {
        // Clears the screen. This isn't strictly necessary, but it costs very litte
        // so I do it anyway. Since the board is rendered with alpha (SDL's color key)
        // enabled, it's possible to change the clear color for a different background,
        // or render an image or special effects behind the board.
        renderBegin();

        // This causes the game board with all the Xs and Os to be rendered to the back buffer.
        _game.render();

        // This pushes everything to the screen.
        renderEnd();
    }

    void handleEvents()
    {
        SDL_Event event;
        while(SDL_PollEvent(&event))
        {
            switch(event.type)
            {
                case SDL_MOUSEBUTTONUP:
                    if(event.button.button == SDL_BUTTON_LEFT)
                    {
                        // Determine where on the screen the click took place and translate that to
                        // an index in the board array, which must be within the range of 0 - 8, inclusive.
                        // This is simple math that can be found in any tile game tutorial. As implemented,
                        // the board is always drawn in the entire window, with its top-left corner at
                        // (0, 0) and bottom-left at (windowWidth, windowHeight). If that is changed, then
                        // steps will need to be taken here to compensate, such as adding an offset into
                        // the calculations if the top-left is no longer at (0,0). Whatever the result, always
                        // send it to _mousePlayer and let it decide to accept or reject it.
                        int x = event.button.x / SquareWidth;
                        int y = event.button.y / SquareHeight;
                        _mousePlayer.nextIndex = (x + (y * 3));
                    }
                    break;

                case SDL_KEYUP:
                    switch(event.key.keysym.sym)
                    {
                        // Keypad keys 1 - 9 are used to _keyboardPlayer to represent the 9 squares
                        // on the board. Keys 7-9 are the top row (array indices 0-2), keys 4-5 are the
                        // middle row (indices 3-5), and keys 1-3 are the bottom row (indices 6-8).
                        // Always send the index to _keyboardPlayer and let it decide to accept or
                        // reject it.
                        case SDLK_KP_1: _keyboardPlayer.nextIndex = 6; break;
                        case SDLK_KP_2: _keyboardPlayer.nextIndex = 7; break;
                        case SDLK_KP_3: _keyboardPlayer.nextIndex = 8; break;
                        case SDLK_KP_4: _keyboardPlayer.nextIndex = 3; break;
                        case SDLK_KP_5: _keyboardPlayer.nextIndex = 4; break;
                        case SDLK_KP_6: _keyboardPlayer.nextIndex = 5; break;
                        case SDLK_KP_7: _keyboardPlayer.nextIndex = 0; break;
                        case SDLK_KP_8: _keyboardPlayer.nextIndex = 1; break;
                        case SDLK_KP_9: _keyboardPlayer.nextIndex = 2; break;

                        // Also bind qwe/asd/zxc for _keyboardPlayer for keyboards without a keypad.
                        case SDLK_q: _keyboardPlayer.nextIndex = 0; break;
                        case SDLK_w: _keyboardPlayer.nextIndex = 1; break;
                        case SDLK_e: _keyboardPlayer.nextIndex = 2; break;
                        case SDLK_a: _keyboardPlayer.nextIndex = 3; break;
                        case SDLK_s: _keyboardPlayer.nextIndex = 4; break;
                        case SDLK_d: _keyboardPlayer.nextIndex = 5; break;
                        case SDLK_z: _keyboardPlayer.nextIndex = 6; break;
                        case SDLK_x: _keyboardPlayer.nextIndex = 7; break;
                        case SDLK_c: _keyboardPlayer.nextIndex = 8; break;

                        // This key is used to reset the game board to its original state. Always make
                        // the call when the key is pressed and let the game decide whether or not it
                        // is possible to clear.
                        case SDLK_SPACE:
                            _game.reset();
                            break;

                        // Currently, this completely exits the app. If a menu screen is implemented, this should
                        // only exit the app when the menu is active. If the game is active, this should return
                        // to the menu screen.
                        case SDLK_ESCAPE:
                            _running = false;
                            return;

                        default:
                            break;
                    }
                    break;

                // This should always exit the app, no matter what sort of screen is active. However, it would
                // be a good idea to prompt the user when in the middle of a game in case it was hit accidentally.
                case SDL_QUIT:
                    _running = false;
                    return;

                default:
                    break;
            }
        }
    }
}
