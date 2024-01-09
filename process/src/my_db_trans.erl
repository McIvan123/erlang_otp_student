-module(my_db_trans).
-import(db, [new/0, destroy/1, write/3, delete/2, read/2, match/2]).
-export([start/0, loop/1, stop/0, write/2, read/1, delete/1, match/1, lock/0, unlock/0]).

start()->
    Pid = spawn(my_db_trans,loop,[db:new()]),
    register(dbServer, Pid).

stop()->
    dbServer ! stop,
    ok.

write(Key,Element)->
    dbServer ! {write, self(), Key, Element},
    ok.

read(Key)->
    dbServer ! {read, self(), Key},
    receive
        Reply ->
            Reply
    end.

delete(Key)->
    dbServer ! {delete, self(), Key},
    ok.

match(Element)->
    dbServer ! {match, self(), Element},
    receive
        {reply, Match} ->
            Match
    end.

lock()->
    dbServer ! {lock, self()},
    ok.

unlock()->
    dbServer ! {unlock, self()},
    ok.

loop(DbRef)->
    receive
        {lock, Pid} ->
            locked_loop(DbRef, Pid);
        {write, _Pid, Key, Element} ->
            loop(db:write(Key,Element,DbRef));
        {read, Pid, Key} ->
            Pid ! db:read(Key,DbRef),
            loop(DbRef);
        {delete, _Pid, Key}->
            loop(db:delete(Key,DbRef));
        {match, Pid, Element} ->
            Pid ! {reply, db:match(Element,DbRef)},
            loop(DbRef);
        stop ->
            db:destroy(DbRef),
            ok
    end.

locked_loop(DbRef, Pid)->
    receive
        {unlock, Pid} ->
            loop(DbRef);
        {write, Pid, Key, Element} ->
            locked_loop(db:write(Key,Element,DbRef),Pid);
        {read, Pid, Key} ->
            Pid ! db:read(Key,DbRef),
            locked_loop(DbRef,Pid);
        {delete, Pid, Key}->
            locked_loop(db:delete(Key,DbRef),Pid);
        {match, Pid, Element} ->
            Pid ! {reply, db:match(Element,DbRef)},
            locked_loop(DbRef,Pid);
        stop ->
            db:destroy(DbRef),
            ok
    end.