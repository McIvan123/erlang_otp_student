-module(mutex).
-export([start/0, wait/0, free/0, signal/0]).

start()->
    Pid = spawn(mutex, free, []),
    register (mutexServer, Pid),
    ok.


wait()->
    mutexServer ! {wait, self()},
    receive
        ok ->
            ok
    end.

signal()->
    mutexServer ! {signal, self()},
    receive
        ok ->
            ok
    end.

free()->
    receive
        {wait, Pid} ->
            Pid ! ok,
            busy(Pid)
    end.

busy(Pid)->
    receive
        {signal, Pid} ->
            Pid ! ok
    end,
    free().