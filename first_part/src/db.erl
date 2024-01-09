-module(db).
-export([new/0, destroy/1, write/3, delete/2, read/2, match/2]).

new() -> [].

destroy(_) -> ok.

write(Key,Element,DbRef) ->
    DbRef ++ [{Key,Element}].

delete(Key,DbRef) ->
    delete(Key,DbRef,[]).

delete(_,[],Result)->
    Result;
delete(Key,[{Key,_}|T],Result)->
    delete(Key,[],Result ++ T);
delete(Key,[H|T],Result)->
    delete(Key,T,Result ++ [H]).

read(_,[])->
    {error, instance};
read(Key, [{Key,Element}|_]) ->
    {ok, Element};
read(Key, [_|T]) ->
    read(Key,T).

match(Element,DbRef)->
    match(Element,DbRef,[]).

match(_,[],Result)->
    Result;
match(Element,[{Key,Element}|T],Result)->
    match(Element,T,Result++[Key]);
match(Element,[_|T],Result)->
    match(Element,T,Result).




