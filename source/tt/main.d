module tt.main;

private
{
	import core.runtime;
	import std.conv;
	import std.path;

	import derelict.sdl2.sdl;
	import derelict.sdl2.image;

	import tt.audio;
	import tt.config;
	import tt.gfx;
	import tt.game;
}

void main(string[] args)
{
	scope(exit) term();
	init();
	run();
}

private
{
	bool _running;
	Game _game;
	HumanPlayer _mousePlayer;
	HumanPlayer _keyboardPlayer;

	final class HumanPlayer : Player
	{
		public override
		{
			void update()
			{
				if(_nextIndex != 255)
				{
					_game.setActiveMark(_nextIndex);
					_nextIndex = 255;
				}
			}
		}

		private
		{
			this(string name)
			{
				super(name);
				_nextIndex = 255;
			}

			void nextIndex(uint idx) @property
			{
				if(!_game.over && isActive) _nextIndex = idx;
			}
		}

		private
		{
			bool _useMouse;
			uint _nextIndex;
		}
	}

	void init()
	{
		DerelictSDL2.load();
		DerelictSDL2Image.load();

		gfxInit();
		audioInit();
	}

	void term()
	{
		if(!DerelictSDL2.isLoaded) return;

		audioTerm();
		gfxTerm();

		SDL_Quit();
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
		renderBegin();
		_game.render();
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
						int x = event.button.x / SquareWidth;
						int y = event.button.y / SquareHeight;
						_mousePlayer.nextIndex = (x + (y * 3));
					}
					break;


				case SDL_KEYUP:
					switch(event.key.keysym.sym)
					{
						case SDLK_KP_1: _keyboardPlayer.nextIndex = 6; break;
						case SDLK_KP_2: _keyboardPlayer.nextIndex = 7; break;
						case SDLK_KP_3: _keyboardPlayer.nextIndex = 8; break;
						case SDLK_KP_4: _keyboardPlayer.nextIndex = 3; break;
						case SDLK_KP_5: _keyboardPlayer.nextIndex = 4; break;
						case SDLK_KP_6: _keyboardPlayer.nextIndex = 5; break;
						case SDLK_KP_7: _keyboardPlayer.nextIndex = 0; break;
						case SDLK_KP_8: _keyboardPlayer.nextIndex = 1; break;
						case SDLK_KP_9: _keyboardPlayer.nextIndex = 2; break;

						case SDLK_SPACE:
							_game.reset();
							break;

						case SDLK_ESCAPE:
							_running = false;
							return;

						default:
							break;
					}
					break;

				case SDL_QUIT:
					_running = false;
					return;

				default:
					break;
			}
		}
	}
}
