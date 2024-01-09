-module(crossring).
-export([start/3, central_start/3, ring_start/3]).

start(NrNodes, NrMessages, Message)->
    spawn(crossring,central_start,[NrNodes, NrMessages, Message]).

central_start(NrNodes, NrMessages, Message)->
    NrRight = NrNodes div 2,
    RightPid = spawn_link(crossring, ring_start, [2, NrRight+1, self()]),
    LeftPid = spawn_link(crossring, ring_start, [NrRight+2, NrNodes, self()]),
    RightPid ! {message, Message},
    central_loop(LeftPid,RightPid, NrMessages*2-1).


ring_start(EndId, EndId, First) ->
    ring_loop(EndId, First);
ring_start(StartId, EndId, First) ->
    NextPid = spawn_link(crossring, ring_start, [StartId+1,EndId, First]),
    ring_loop(StartId, NextPid).

ring_loop(Id, NextPid)->
    receive
        {message, Msg} ->
            io:format("Process: ~p received: ~p~n", [Id, Msg]),
            NextPid ! {message, Msg},
            ring_loop(Id, NextPid);
        terminate ->
            io:format("Process: ~p terminating~n", [Id]),
            NextPid ! terminate
    end.

central_loop(FirstPid,SecondPid,0)->
    receive
        {message, _} ->
            io:format("Process: 1 terminating~n", []),
            FirstPid ! terminate,
            SecondPid ! terminate
    end;
central_loop(FirstPid, SecondPid, NrMessages)->
    receive
        {message, Msg} ->
            Printout = 
                if
                    NrMessages rem 2 == 1 ->
                        "halfway through";
                    true ->
                        " "
                end,
            io:format("Process: 1 received: ~p ~p, ~n", [Msg, Printout]),
            FirstPid ! {message, Msg},
            central_loop(SecondPid, FirstPid, NrMessages-1)
    end.

