module build;

import core.stdc.stdlib : system;
import std.stdio : writefln, writeln;
import std.process : shell, ErrnoException;
import std.file : dirEntries, SpanMode;
import std.array : endsWith;
import std.string : format, toStringz;

// Source directories
string srcDirs[] =
[
    "import/",
    "source/"
];

// Output configuration
enum binName = "T3";
enum outdir = "bin";

bool isDebug = true;

version(Windows)
{
    enum extension = ".exe";
}
else version(Posix)
{
    enum extension = "";
}
else
{
    static assert(false, "Unknown operating system.");
}

// Compiler configuration
version(DigitalMars)
{
    pragma(msg, "Using the Digital Mars DMD compiler.");
    enum releaseOptions = "-O -release -inline -property -w -wi";
    enum debugOptions = "-g -debug -property -w -wi";

    string buildCompileString(string name, string files)
    {
        string options = releaseOptions;
        if(isDebug) options = debugOptions;
        version(Posix) options ~= " -L-ldl";
        return format("dmd %s -Iimport%s -of%s\\%s", options, files, outdir, name);
    }
}
else
{
    static assert(false, "Unknown compiler.");
}

int main(string[] args)
{
    if(args.length > 1 && args[1] == "release")
        isDebug = false;

    build();

    return 0;
}

string appendFiles(string appendTo, string path)
{
    foreach(string s; dirEntries(path, SpanMode.breadth))
    {
        if(s.endsWith(".d"))
        {
            writeln(s);
            appendTo ~= " " ~ s;
        }
    }

    return appendTo;
}

void build()
{
    // Build up a string of all .d files to be compiled into the application.
    string joined;
    foreach(s; srcDirs)
        joined = appendFiles(joined, s);


    string name = binName;
    if(isDebug) name ~= "_dbg";
    name ~= extension;

    writeln();
    writefln("Building %s", name);
    writeln();

    string arg = buildCompileString(name, joined);
    writeln(arg);

    if(system(toStringz(arg)) == 0)
        writeln("Build succeeded.");
    else
        writeln("Build failed.");
}
