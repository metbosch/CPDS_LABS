-module(paxy).
-export([start/1, stop/0, stop/1]).

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
start(Sleep) ->
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
    ProposerNames = [{"Proposer kurtz", ?RED}, {"Proposer kilgore", ?GREEN}, 
                     {"Proposer willard", ?BLUE}],
    %ProposerNames = [{"Proposer kurtz", ?RED}, {"Proposer kilgore", ?GREEN}, 
    %                 {"Proposer willard", ?BLUE}, {"Proposer alice", ?ORANGE}, 
    %                 {"Proposer bob", ?YELLOW}, {"Proposer charlie", ?PURPLE}],
    %ProposerNames = [{"Proposer kurtz", ?RED}, {"Proposer kilgore", ?GREEN}, 
    %                 {"Proposer willard", ?BLUE}, {"Proposer alice", ?ORANGE}, 
    %                 {"Proposer bob", ?YELLOW}, {"Proposer charlie", ?PURPLE},
    %                 {"Proposer david", ?COLOR1}, {"Proposer ed", ?COLOR2}, 
    %                 {"Proposer faust", ?COLOR3}],
    PropInfo = [{kurtz, ?RED}, {kilgore, ?GREEN}, {willard, ?BLUE}],
    %PropInfo = [{kurtz, ?RED}, {kilgore, ?GREEN}, {willard, ?BLUE},
    %            {alice, ?ORANGE}, {bob, ?YELLOW}],
    %PropInfo = [{kurtz, ?RED}, {kilgore, ?GREEN}, {willard, ?BLUE},
    %            {alice, ?ORANGE}, {bob, ?YELLOW}, {charlie, ?PURPLE},
    %            {david, ?COLOR1}, {ed, ?COLOR2}, {faust, ?COLOR3}],
    register(gui, spawn(fun() -> gui:start(AcceptorNames, ProposerNames) end)),
    gui ! {reqState, self()},
    receive
        {reqState, State} ->
            {AccIds, PropIds} = State,
            start_acceptors(AccIds, AccRegister),
            start_proposers(PropIds, PropInfo, AccRegister, Sleep)
    end,
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

start_proposers(PropIds, PropInfo, Acceptors, Sleep) ->
    case PropIds of
        [] ->
            ok;
        [PropId|Rest] ->
            [{RegName, Colour}|RestInfo] = PropInfo,
            [FirstSleep|RestSleep] = Sleep,
            proposer:start(RegName, Colour, Acceptors, FirstSleep, PropId),	
            start_proposers(Rest, RestInfo, Acceptors, RestSleep)
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

 
