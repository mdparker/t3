/**
This module handles updating of the game board, management of player turns and determination
of a game's outcome.
*/
module tt.game;

// It's worth noting that module imports are private by default, but I always
// wrap them in a block like this. Personal taste.
private
{
    // I use std.stdio.writeln/writefln to output text to the console. It would be a good exercise
    // to remove the system console and draw text output in the window, perhaps using SDL_ttf, or
    // maybe AngelCode fonts.
    import std.stdio;

    // This module also manages sound effects, hence tt.audio here.
    import tt.audio;
    import tt.config;
    import tt.gfx;
}

private
{
    // Represents the 9 squares of a TicTacToe game board.
    struct Board
    {
        // The three possible values of the current state of a game. This might be better
        // outside of the Board struct. Then in the game class, the following form could
        // be used to test the state: if(board.state == State.Win). As is, it would have
        // to be used like so: if(board.state == Board.State.Win). Instead, I've opted to
        // keep it here inside board and added three convenient property functions below
        // just for kicks. Some may argue that this shouldn't be part of the board anyway,
        // that the board should just be data and the game class should manage the state.
        // That's understandable, conceptually. But practically, it looks cleaner to me
        // to keep it out of the game class.
        enum State
        {
            Open,   // The game is still being played.
            Win,    // One of the players has won the game.
            Draw    // The game ended in a draw (tie).
        }

        // The 9 squares of the board, default initialized to 0. Board.clear must
        // be called before it can be used.
        ubyte[9] squares;

        // The current state of the game board.
        State state;

        // The three array holds the indices of a winning three in a row. This is used so that
        // those indices can be turned on and off to flash the Xs or Os in those slots as feedback
        // for the win. flashTime controls the duration of the blinking on and off, and flashOn
        // indicates, when true, that the effect is active.
        size_t[3] three;
        uint flashTime;
        bool flashOn;

        // Convenience properties to determine the current state of the board. This allows the
        // following usage in the game class: if(board.isOpen) as opposed to if(board.state == Board.State.Open).
        // A simple exercise could be to remove these three properties and modify the code such
        // that the tests in game become: if(board.state == State.Open).
        bool isOpen() @property
        {
            return state == State.Open;
        }

        bool isWin() @property
        {
            return state == State.Win;
        }

        bool isDraw() @property
        {
            return state == State.Draw;
        }

        // Called by the Game class to set the value of the given index in the board array to
        // an X or O mark.
        bool set(int index, ubyte mark)
        {
            if(squares[index] != NoMark)
                return false;
            else
            {
                squares[index] = mark;
                updateState(mark);
                return true;
            }
        }

        // Called by set to determine if the last move ended the game.
        void updateState(ubyte mark)
        {
            // As an exercise, eliminate the checkDraw method entirely and only
            // call checkWin when the minimum number of moves required
            // (that would be 5) have been made. Doing both would only need a single
            // variable to be updated on every move and reset to 0 on every new game.
            checkWin(mark);
            if(state == State.Open)
                checkDraw();
        }

        // Called by updateState to determine if the last move won the game.
        void checkWin(ubyte mark)
        {
            // First, check each row, left->right.
            for(size_t i=0; i<9; i+=3)
            {
                if(squares[i+0] == mark && squares[i+1] == mark && squares[i+2] == mark)
                {
                    three[0] = i+0;
                    three[1] = i+1;
                    three[2] = i+2;
                    state = State.Win;
                }
            }

            // Next, check each column.
            for(size_t i=0; i<3; i++)
            {
                if(squares[i+0] == mark && squares[i+3] == mark && squares[i+6] == mark)
                {
                    three[0] = i+0;
                    three[1] = i+3;
                    three[2] = i+6;
                    state = State.Win;
                }
            }

            // Finally, check the diagonals
            if(squares[4] == mark)
            {
                if(squares[2] == mark && squares[6] == mark)
                {
                    three[0] = 2;
                    three[1] = 4;
                    three[2] = 6;
                    state = State.Win;
                }
                else if(squares[0] == mark && squares[8] == mark)
                {
                    three[0] = 0;
                    three[1] = 4;
                    three[2] = 8;
                    state = State.Win;
                }
            }
        }

        // Called by update state to determine if the last move caused the game to end in a tie.
        void checkDraw()
        {
            int count;
            foreach(mark; squares)
            {
                if(mark != NoMark)
                    ++count;
            }
            if(count == 9)
                state = State.Draw;
        }

        // Called by the Game class to turn the winning squares on and off so that the Xs or Os they
        // contain flash on screen.
        void flash(uint delta, ubyte mark)
        {
            flashTime += delta;
            if(flashTime > 400)
            {
                flashTime = 0;
                if(!flashOn)
                {
                    squares[three[0]] = NoMark;
                    squares[three[1]] = NoMark;
                    squares[three[2]] = NoMark;
                    flashOn = true;
                }
                else
                {
                    squares[three[0]] = mark;
                    squares[three[1]] = mark;
                    squares[three[2]] = mark;
                    flashOn = false;
                }
            }
        }

        // Sets the board members into a state suitable for a new game.
        void clear()
        {
            squares[] = NoMark;
            state = State.Open;
            flashTime = 0;
            flashOn = false;
        }
    }
}

/**
This abstract class is used by the game to execute moves each turn.

Player is intended to be subclassed to provide for different types of game play, such as 1-on-1 on the
same computer (HumanPlayer vs HumanPlayer), 1-on-1 over a network (NetworkPlayer vs NetworkPlayer), or
single player vs. AI (HumanPlayer vs AIPlayer), with multiple possibilities for AI (smart, dumb, easy, hard).
Currently, only the HumanPlayer is implemented. Other player types could be implemented as an exercise.
*/
abstract class Player
{
    public
    {
        // Called once per frame by the game class on the currently active player until a move
        // is made. Implementations should call game.setActiveMark to update the board with
        // this player's mark.
        abstract void update();

        // Returns true if this player is the currently active player.
        final bool isActive() @property
        {
            return _active;
        }
    }

    protected
    {
        this(string name)
        {
            _name = name;
        }
    }

    private
    {
        ubyte _mark;        // X or O
        string _name;       // The name displayed in text output ("Player1", "Computer", etc...)
        bool _active;
    }
}

/**
Manages all aspects of the game itself.

Manages the game board, plays sounds when the board is updated, keeps track of the active player.
All updates to the game board *must* go through this class (the setActiveMark method).
*/
class Game
{
    public
    {
        /**
        Sets up a new game between the two given players.
        */
        this(Player p1, Player p2)
        {
            _p1 = p1;
            _p2 = p2;
            reset();
        }

        /**
        Calls the update method of the active player and, if there is a winner, updates the blinking
        board animation with the given time delta.
        */
        void update(uint delta)
        {
            activePlayer.update();
            if(_board.isWin)
                _board.flash(delta, activePlayer._mark);
        }

        /**
        Draws the game board and all the Xs and Os.
        */
        void render()
        {
            renderBoard(_board.squares);
        }

        /**
        Updates the given index of the board with the active player's mark.
        */
        void setActiveMark(uint index)
        {
            if(_board.set(index, activePlayer._mark))
            {
                // A successful update results in a click sound.
                play(Sound.Click);

                // This is a good place to demonstrate a final switch. When switching on
                // enum members, adding 'final' to the switch statement indicates that you
                // are casing every member of the enum. If you forget one, you'll get an
                // error. Very handy in case you add new members to an enum over time and
                // forget to update a switch statement somewhere.
                final switch(_board.state)
                {
                    case Board.State.Open:
                        activePlayer =(activePlayer == _p1) ? _p2 : _p1;
                        break;

                    case Board.State.Win:
                        writefln("%s wins!", activePlayer._name);
                        _board.flash(300, activePlayer._mark);
                        break;

                    case Board.State.Draw:
                        writeln("It's a draw!");
                        break;
                }
            }
            else
                // Trying to update a square that already contains a mark earns a buzzer.
                play(Sound.Buzzer);
        }

        /**
        Sets up the next round of the game based on the outcome of the previous round (if any).
        */
        void reset()
        {
            // If the active player won the last round, that player continues to be active. If the
            // O player was the winner, swap marks. X always goes first each round.
            if(_board.isWin)
            {
                if(activePlayer._mark == OMark)
                {
                    activePlayer._mark = XMark;
                    if(activePlayer == _p1)
                        _p2._mark = OMark;
                    else
                        _p1._mark = OMark;
                }
            }

            // In case of a draw, swap the active player.
            else if(_board.isDraw)
            {
                if(_p1._mark == XMark)
                {
                    _p1._mark = OMark;
                    _p2._mark = XMark;
                    activePlayer = _p2;
                }
                else
                {
                    _p1._mark = XMark;
                    _p2._mark = OMark;
                    activePlayer = _p1;
                }
            }

            // In the default case (no previous round) the player designated by the constructor
            // as Player1 goes first.
            else
            {
                activePlayer = _p1;
                _p1._mark = XMark;
                _p2._mark = OMark;
            }

            _board.clear();
        }

        /**
        Returns true if the current round has ended in win or a tie.
        */
        bool over() @property
        {
            return !_board.isOpen;
        }
    }

    private
    {
        void activePlayer(Player player) @property
        {
            if(_activePlayer !is null)
                _activePlayer._active = false;
            _activePlayer = player;
            player._active = true;
        }

        Player activePlayer() @property
        {
            return _activePlayer;
        }
    }

    private
    {
        Player _p1;
        Player _p2;
        Player _activePlayer;
        Board _board;
    }
}
