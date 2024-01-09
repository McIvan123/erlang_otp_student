-module(process_ring).
-export([ringer/2,first/2, others/2]).

ringer(NrOfProc, NrOfMsg)->
    Pid = spawn(process_ring, first, [NrOfProc-1, NrOfMsg]),
    io:format("Ja sam glavni konj sa Pidom~p~n", [Pid]).

first(NrOfProc, NrOfMsg)->
    NextPid = spawn(process_ring, others, [NrOfProc-1, self()]),
    io:format("Rodio se mali konj ~p sa Pidom~p~n", [NrOfProc-1, NextPid]),
    receive
        process_set_up ->
            send_messages(NrOfMsg, NextPid)
    after 1000 ->
        io:format("di su mi konji...bacaj cigle ~n"),
        NextPid ! quit,
        io:format("i ubi se ~n"),
        ok
    end.


others(0, FirstPid)->
    io:format("Konj 0 je najmladji konj i cinkati će vas mami~n"),
    FirstPid ! process_set_up,
    others_loop(0, FirstPid);
others(NrOfProc, FirstPid)->
    NextPid = spawn(process_ring, others, [NrOfProc-1, FirstPid]),
    io:format("Rodio se mali konj ~p sa Pidom~p~n", [NrOfProc-1, NextPid]),
    others_loop(NrOfProc, NextPid).

others_loop(Number, SendToPid)->
    receive
        {forward, Time} ->
            io:format("Mali Konj~p forwarded msg number ~p~n", [Number,Time]),
            SendToPid ! {forward, Time},
            others_loop(Number, SendToPid);
        quit ->
            io:format("Mali Konj~p dobio ciglu u glavu~n", [Number]),
            SendToPid ! quit,
            error;
        jabuka ->
            io:format("Mali Konj~p je dobio jabuku, sad je mali veseli konj i sretno trči po livadama~n", [Number]),
            SendToPid ! jabuka,
            ok
    end.

send_messages(0, NextPid)->
    io:format("Svi konji su odgovorili SVE poruke, bravo, evo vam jabuka~n"),
    NextPid ! jabuka;
send_messages(NrOfMsg, NextPid)->
    io:format("Salji poruku~p malim konjima~n", [NrOfMsg]),
    NextPid ! {forward, NrOfMsg},
    receive
        {forward, NrOfMsg} ->
            io:format("Svi konji su odgovorili poruku ~p...vVESELJE~n", [NrOfMsg]),
            send_messages(NrOfMsg-1, NextPid)
    after
        1000 ->
            io:format("konji nisu odgovorili na poruku ~p...bacaj cigle ~n", [NrOfMsg]),
            NextPid ! quit
    end.




