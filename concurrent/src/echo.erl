-module(echo).
-export([start/0, echoServerLoop/0, print/1, stop/0]).

-define(NAME, echoServer).

start()->
    Pid = spawn(echo, echoServerLoop, []),
    true = register(?NAME, Pid),
    ok.

stop()->
    ?NAME ! stop,
    ok.

print(Term)->
    ?NAME ! {print, Term}.

echoServerLoop()->
    receive
        {print, Term} ->
            io:format("~p~n", [Term]),
            echoServerLoop();
        stop ->
            io:format("Ubili su me, ciglama: crvenim ciglama~n")
    end.
