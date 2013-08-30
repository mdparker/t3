t3
==

A simple TicTacToe game written with the D programming language.

This game serves as a simple example of two things, programming with the D Programming Language and how to use the Derelict 3 bindings. None of the more advanced features of D, such as templates or ranges, are used. Instead, basic features such as foreach loops and module-level 'friends' are demonstrated. Those new to the D Programming Language may want to play around with this to become familiar with the language. For example, one could add AI, networking, or other features to enhance the basic game.

I created the graphics myself and you may use them as you see fit. The audio files were downloaded from Freesound.org, specifically from these links:

"buzzer.wav" - http://www.freesound.org/people/guitarguy1985/sounds/54047/
"mouse click.wav" http://www.freesound.org/people/THE_bizniss/sounds/39562/

To compile the game, you will need to download and install [dub](https://github.com/rejectedsoftware/dub). With both dub and a D compiler on your path, you can execute the following command to compile.

```
cd t3
dub build
```

This will create an executable called 't3' in the t3\bin subdirectory. By default, dub will use DMD, but you can specify other compilers on the command line. Also, dub will build a debug mode executable by default. You can specify other modes on the command line. Execute 'dub --help' for details.

To run the game you will need the shared libraries SDL2 and SDL2_image on your system path (or in the t3/bin subdirectory). SDL2_mixer is optional, but without it there will be no sound effects. You can download binaries and source from the following links.

[SDL2](http://www.libsdl.org/download-2.0.php)
[SDL2_image](http://www.libsdl.org/projects/SDL_image/)
[SDL2_mixer](http://www.libsdl.org/projects/SDL_mixer/)

Pull requests with new game features will likely not be accepted. I would like to keep this simple and useful as a toy for new D users. However, I'll happily accept pull requests for bug fixes.

I've created a forum at my personal website where you can come and discuss this project, if you'd like. You can find it at http://dblog.aldacron.net/forum/index.php?board=4.0 (if you have problems getting through the security questions to create a forum membership, you contact me directly for help). I expect that anyone new to D may have questions or encounter difficulties, so if you fall into that category and have problems doing something with this specific codebase, feel free to drop on in and ask a question. I don't promise a prompt reply, so you'd be better off taking general D questions to the D newsgroups via either a newsreader or the web interface at http://forum.dlang.org/.

I hope someone finds this helpful.
