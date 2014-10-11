t3
==

A simple TicTacToe game written with the D programming language.

This game serves as a simple example of two things, programming with the D Programming Language and how to use the [Derelict bindings][1]. None of the more advanced features of D, such as templates or ranges, are used. Instead, basic features such as foreach loops and module-level 'friends' are demonstrated. Those new to the D Programming Language may want to play around with this to become familiar with the language. For example, one could add AI, networking, or other features to enhance the basic game.

I created the graphics myself and you may use them as you see fit. The audio files were downloaded from Freesound.org, specifically from these links:

* "buzzer.wav" - http://www.freesound.org/people/guitarguy1985/sounds/54047/
* "mouse click.wav" http://www.freesound.org/people/THE_bizniss/sounds/39562/

To compile the game, you will need to download and install [DUB][2]. With both DUB and a D compiler on your path, you can execute the following commands to compile the executable.

```
cd t3
dub build
```

This will create an executable called 't3' in the t3\bin subdirectory. By default, DUB will use DMD, but you can specify other compilers on the command line. Also, DUB will build a debug mode executable by default. You can specify other modes on the command line. Execute 'dub --help' for details.

DUB can also launch the executable after compiling it. To do so, drop the 'build' argument from the command above, like so:

```
cd t3
dub
```

To run the game you will need the shared libraries SDL2 and SDL2_image on your system path (or in the t3/bin subdirectory). SDL2_mixer is optional, but without it there will be no sound effects. You can download binaries and source from the following links.

* [SDL2][3]
* [SDL2_image][4]
* [SDL2_mixer][5]

Pull requests with new game features will likely not be accepted. I would like to keep this simple and useful as a toy for new D users. However, I'll happily accept pull requests for bug fixes.

If you have general questions about the D Programming Language, you can take them to the D Newsgroups either through a newsreader or via the [web interface][6]. Many D users also hang out in the #D IRC channel on freenode.net, a good place for new users to get help in starting with D.

I hope someone finds this little game helpful.

[1]: https://github.com/DerelictOrg/
[2]: http://code.dlang.org/download
[3]: http://www.libsdl.org/download-2.0.php
[4]: http://www.libsdl.org/projects/SDL_image/
[5]: http://www.libsdl.org/projects/SDL_mixer/
[6]: http://forum.dlang.org/