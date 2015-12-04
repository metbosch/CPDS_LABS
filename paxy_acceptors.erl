-module(paxy_acceptors).
-export([start/0, stop/0, stop/1]).

-define(RED, {255,0,0}).
-define(BLUE, {0,0,255}).
-define(GREEN, {0,255,0}).
%-define(ORANGE, {255, 255, 0}).
%-define(YELLOW, {0, 255, 255}).
%-define(PURPLE, {255, 0, 255}).
%-define(COLOR1, {255, 20, 100}).
%-define(COLOR2, {100, 100, 255}).
%-define(COLOR3, {200, 35, 125}).

% Sleep is a list with the initial sleep time for each proposer
start() ->
    register(acceptorsController, self()),
    AcceptorNames = ["Acceptor a", "Acceptor b", "Acceptor c", 
    "Acceptor d", "Acceptor e"],
    %AcceptorNames = ["Acceptor a", "Acceptor b", "Acceptor c", 
    %"Acceptor d", "Acceptor e", "Acceptor f", "Acceptor g", 
    %"Acceptor h", "Acceptor i", "Acceptor j"],
    %AcceptorNames = ["Acceptor a", "Acceptor b", "Acceptor c", 
    %"Acceptor d", "Acceptor e", "Acceptor f", "Acceptor g", 
    %"Acceptor h", "Acceptor i", "Acceptor j", "Acceptor k", 
    %"Acceptor l", "Acceptor m", "Acceptor n", "Acceptor o"],
    AccRegister = [a, b, c, d, e],
    %AccRegister = [a, b, c, d, e, f, g, h, i, j],
    %AccRegister = [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o],
    io:format("~p", [{acceptorsController, node()}]),
    receive
    %% Proposer information is received from the proposer node.
        {startupInfo, ProposersController, ProposersInfo, ProposersNames} -> true 
    end,
    io:format("startupInfo received"), 
    register(gui, spawn(fun() -> gui:start(AcceptorNames, ProposersNames) end)),
    gui ! {reqState, self()},
    receive
        {reqState, State} ->
            {AccIds, PropIds} = State,
            start_acceptors(AccIds, AccRegister)
    end,
    lists:map(fun(Prop) -> {{Info, _}, Id} = Prop, register(Info, Id) end, lists:zip(ProposersInfo, PropIds)),
    ProposersController ! {startProposers,
                          lists:map(fun(Acc) -> {Acc, node()} end, AccRegister),
                          lists:map(fun(Prop) -> {Info, _} = Prop, {Info, node()} end, ProposersInfo)  },
    true.
    
start_acceptors(AccIds, AccReg) ->
    case AccIds of
        [] ->
            ok;
        [AccId|Rest] ->
            [RegName|RegNameRest] = AccReg,
            register(RegName, acceptor:start(RegName, AccId)),
            start_acceptors(Rest, RegNameRest)
    end.

stop() ->
    stop(a),
    stop(b),
    stop(c),
    stop(d),
    stop(e),
    %stop(f),
    %stop(g),
    %stop(h),
    %stop(i),
    %stop(j),
    %stop(k),
    %stop(l),
    %stop(m),
    %stop(n),
    %stop(o),
    stop(gui).

stop(Name) ->
    case whereis(Name) of
        undefined ->
            ok;
        Pid ->
            Pid ! stop
    end.

 
