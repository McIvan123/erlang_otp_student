-module(my_db).
-import(db, [new/0, destroy/1, write/3, delete/2, read/2, match/2]).
-export([start/0, loop/1, stop/0, write/2, read/1, delete/1, match/1, init/0]).

start()->
    Pid = spawn(my_db,init,[]),
    register(dbServer, Pid).

stop()->
    dbServer ! stop,
    ok.

write(Key,Element)->
    dbServer ! {write, Key, Element},
    ok.

read(Key)->
    dbServer ! {read, Key, self()},
    receive
        Reply ->
            Reply
    end.

delete(Key)->
    dbServer ! {delete, Key},
    ok.

match(Element)->
    dbServer ! {match, Element, self()},
    receive
        {reply, Match} ->
            Match
    end.

init()->
    loop(db:new()).


loop(DbRef)->
    receive
        {write, Key, Element} ->
            loop(db:write(Key,Element,DbRef));
        {read, Key, Pid} ->
            Pid ! db:read(Key,DbRef),
            loop(DbRef);
        {delete, Key}->
            loop(db:delete(Key,DbRef));
        {match, Element, Pid} ->
            Pid ! {reply, db:match(Element,DbRef)},
            loop(DbRef);
        stop ->
            db:destroy(DbRef),
            ok
    end.