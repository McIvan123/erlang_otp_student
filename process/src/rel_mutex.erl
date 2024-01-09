-module(rel_mutex).
-export([start/0, wait/0, init/0, signal/0]).

start()->
    Pid = spawn(rel_mutex, init, []),
    register (mutexServer, Pid),
    ok.


wait()->
    link(whereis(mutexServer)),
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
init()->
    process_flag(trap_exit, true),
    free().

free()->
    receive
        {wait, Pid} ->
            Pid ! ok,
            busy(Pid)
    end.

busy(Pid)->
    receive
        {signal, Pid} ->
            Pid ! ok;
        {'EXIT', _Pid, Reason} ->
            ok
    end,
    free().