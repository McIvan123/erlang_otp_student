-module(first_part).
-compile(export_all).

%% 3 Sequential Programming
%% 3.1 Evaluating Expressions
sum(N) ->
    sum(N,0).

sum(0, Result) ->
    Result;
sum(N, Result)->
    sum(N-1, Result + N).

sum_interval(N,M) when N =< M ->
    sum_interval(N,M,0).

sum_interval(M,M,Result)->
    Result + M;
sum_interval(N,M,Result)->
    sum_interval(N+1,M,Result+N).

%% 3.2 Creating Lists
create(1)->
    [1];
create(N)->
    create(N-1) ++ [N] .

reverse_create(1)->
    [1];
reverse_create(N)->
    [N|create(N-1)] .

%% 3.3 Creating Lists
print(N)->
    print(1,N).

print(B,B)->
    io:format("~p~n", [B]);
print(A,B)->
    io:format("~p~n", [A]),
    print(A+1,B).

even_print(N)->
    even_print(1,N).

even_print(B,B) when B rem 2 == 0 ->
    io:format("~p~n", [B]);
even_print(B,B) when B rem 2 == 1 ->
    ok;
even_print(A,B) when A rem 2 == 0 ->
    io:format("~p~n", [A]),
    even_print(A+1,B);
even_print(A,B) ->
    even_print(A+1,B).
