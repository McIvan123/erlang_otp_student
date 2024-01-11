-module(sup).
-export([start/1, init/0, start_child/4, stop/1]).

start(Supname)->
    Pid = spawn(sup, init, []),
    true = register(Supname, Pid),
    {ok, Pid}.

init()->
    process_flag(trap_exit, true),
    loop([]).

start_child(Supervisor, Mod, Func, Args)->
    Supervisor ! {start_child, self(), Mod, Func, Args},
    receive
        {ok, Pid} ->
            {ok, Pid}
    end.

stop(Supervisor)->
    Supervisor ! stop.

loop(Children)->
    receive
        {start_child, Pid, Mod, Func, Args} ->
            ChildPid = spawn_link(Mod, Func, Args),
            Pid ! {ok, ChildPid},
            loop([{ChildPid, 1, Mod, Func, Args}|Children]);
        {'EXIT', Pid, normal} ->
            io:format("Child ~p died from natural cause~n", [Pid]),
            NewChildren = lists:keydelete(Pid,1,Children),
            loop(NewChildren);
        {'EXIT', Pid, _Reason} ->
            io:format("Child ~p killed~n", [Pid]),
            Child = lists:keyfind(Pid, 1, Children),
            {Pid, Count, Mod, Func, Args} = Child,
            NewChildren = lists:keydelete(Pid,1,Children),
            if
                Count >= 5 ->
                    io:format("Child ~p has gone baserk, do not revive~n", [Pid]),
                    loop(NewChildren);
                Count < 5 ->
                    NewPid = spawn_link(Mod, Func, Args),
                    io:format("Reviving child with newPid ~p~n", [NewPid]),
                    loop([{NewPid, Count+1, Mod, Func, Args}|NewChildren])
            end;
        stop ->
            kill_children(Children)
    end.

kill_children([{Pid, _,_,_,_}|T])->
    io:format("Killing ~p", [Pid]),
    exit(Pid, kill),
    kill_children(T);
kill_children([])->
    ok.

