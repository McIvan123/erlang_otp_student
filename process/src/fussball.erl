%%% File:		fussball.erl
%%% Author: 		<code@erlang-solutions.com>
%%% Description: 	A simple game of Fussball.

-module(fussball).

%% Interface
-export([start/2, init/2, init/3, stop/1, kickoff/1]).

start(MyCountry, OtherCountry) ->
    MyCountryPid = spawn(?MODULE, init, [MyCountry, OtherCountry]),
	spawn(?MODULE, init, [OtherCountry, MyCountry, MyCountryPid]),
    ok.

stop(Country) ->
    Country ! stop.

kickoff(Country) ->
    Country ! kick,
    ok.

init(MyCountry, OtherCountry) ->
	process_flag(trap_exit, true),
    register(MyCountry, self()),
    loop(MyCountry, OtherCountry).

init(MyCountry, OtherCountry, Pid) ->
	process_flag(trap_exit, true),
    register(MyCountry, self()),
	link(Pid),
    loop(MyCountry, OtherCountry).

loop(MyCountry, OtherCountry) ->
    receive
	stop ->
		io:format("~p stopped~n",[MyCountry]),
	    ok;
	save ->
	    io:format("~p just saved...~n", [OtherCountry]),
	    loop(MyCountry, OtherCountry);
	score ->
	    io:format("Oh no! ~p just scored!!~n", [OtherCountry]),
	    loop(MyCountry, OtherCountry);
	{'EXIT', _Pid, Reason} ->
		io:format("~p got exit signal: ~p~n", [MyCountry, Reason]);
	kick ->
	    timer:sleep(500),
	    case random:uniform(1000) of
		N when N > 950 ->
		    io:format("~p SAVES! And what a save!!~n", [MyCountry]),
		    OtherCountry ! save,
		    OtherCountry ! kick;
		N when N > 800 ->
		    io:format("~p SCORES!!~n", [MyCountry]),
		    OtherCountry ! score;
		_ ->
		    io:format("~p kicks the ball...~n", [MyCountry]),
		    OtherCountry ! kick
	    end,
	    loop(MyCountry, OtherCountry)
    end.

