t3
==

A simple TicTacToe game written with the D programming language.

This game serves as a simple of example of two things, programming with the D Programming Language and how to use the Derelict 3 bindings. None of the more advanced features of D, such as templates or ranges, are used. Instead, basic features such as foreach loops and module-level 'friends' are demonstrated.

Those new to the D Programming Language may want to play around this as a start and add AI, networking, or other features to enhance the basic game. The code is currently uncommented, as I am notoriously bad at not commenting my code. I intend to correct that in the future, with comments highlighting some of the D features that I wanted to demonstrate. Until then, please make do.

I created the graphics myself and you may use them as you see fit. The audio files were downloaded from Freesound.org, specifically from these links:

"buzzer.wav" - http://www.freesound.org/people/guitarguy1985/sounds/54047/
"mouse click.wav" http://www.freesound.org/people/THE_bizniss/sounds/39562/

To compile the game, first compile the build script with your D compiler (currently, only DMD is supported), then
execute the resulting executable.

```
cd t3
dmd build
./build
```

To run the game you will need the shared libraries SDL2, SDL2_image, and SDL2_mixer on your system path. Linux and Mac users will need to compile the libraries. Because they are still pre-release, it is quite possible that the Derelict binding here in the import directory will fall behind (particularly with SDL2). If the shared library you build doesn't work with the current binding, or the binding has missing functionality, please report it and I'll get things up to date. Windows users can download all three precompiled DLLs from the Derelict 3 download page.

https://github.com/aldacron/Derelict3/downloads

Pull requests with new game features will likely not be accepted. I would like to keep this simple and useful as a toy for new D users. I might very well create a branch with multiplayer and AI for myself to play around with, but I really want to keep the master as-is. However, I'll happily accept pull requests for bug fixes and improvements to the build script (gdc & ldc support, for example).

I've created a forum at my personal website where you can come and discuss this project, if you'd like. You can find it at http://dblog.aldacron.net/forum/index.php?board=4.0. I expect that anyone new to D may have questions or encounter difficulties, so if you fall into that category and have problems doing something with this specific codebase, feel free to drop on in and ask a question. I don't promise a prompt reply, so you'd be better off taking general D questions to the D newsgroups via either a newsreader or the web interface at http://forum.dlang.org/.

I hope someone finds this helpful.
