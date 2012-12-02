module tt.game;

import std.stdio;

import tt.audio;
import tt.config;
import tt.gfx;

private
{
    struct Board
    {
        enum State
        {
            Open,
            Win,
            Draw
        }

        ubyte[9] squares;
        size_t[3] three;
        State state;
        uint flashTime;
        bool flashOn;

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

        void updateState(ubyte mark)
        {
            checkWin(mark);
            if(state == State.Open)
                checkDraw();
        }

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

        void clear()
        {
            squares[] = NoMark;
            state = State.Open;
            flashTime = 0;
            flashOn = false;
        }
    }
}

abstract class Player
{
    public
    {
        abstract void update();

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
        ubyte _mark;
        string _name;
        bool _active;
    }
}

class Game
{
    public
    {
        this(Player p1, Player p2)
        {
            _p1 = p1;
            _p2 = p2;
            reset();
        }

        void update(uint delta)
        {
            activePlayer.update();
            if(_board.isWin)
                _board.flash(delta, activePlayer._mark);
        }

        void render()
        {
            renderBoard(_board.squares);
        }

        void setActiveMark(uint index)
        {
            if(_board.set(index, activePlayer._mark))
            {
                play(Sound.Click);

                // This is a good place to demonstrate a final switch. When switching on
                // enum members, adding 'final' to the switch statement indicates that you
                // are casing every member of the enum. If you forget one, you'll get an
                // error. Very handy in case you add bew members to an enum over time and
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
                play(Sound.Buzzer);
        }

        void reset()
        {
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
            else
            {
                activePlayer = _p1;
                _p1._mark = XMark;
                _p2._mark = OMark;
            }

            _board.clear();
        }

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
