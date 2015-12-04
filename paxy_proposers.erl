-module(paxy_proposers).
-export([start/2]).

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
start(Sleep, AcceptorsControl) ->
    ProposersNames = [{"Proposer kurtz", ?RED}, {"Proposer kilgore", ?GREEN}, 
                     {"Proposer willard", ?BLUE}],
    %ProposersNames = [{"Proposer kurtz", ?RED}, {"Proposer kilgore", ?GREEN}, 
    %                 {"Proposer willard", ?BLUE}, {"Proposer alice", ?ORANGE}, 
    %                 {"Proposer bob", ?YELLOW}, {"Proposer charlie", ?PURPLE}],
    %ProposersNames = [{"Proposer kurtz", ?RED}, {"Proposer kilgore", ?GREEN}, 
    %                 {"Proposer willard", ?BLUE}, {"Proposer alice", ?ORANGE}, 
    %                 {"Proposer bob", ?YELLOW}, {"Proposer charlie", ?PURPLE},
    %                 {"Proposer david", ?COLOR1}, {"Proposer ed", ?COLOR2}, 
    %                 {"Proposer faust", ?COLOR3}],
    ProposersInfo = [{kurtz, ?RED}, {kilgore, ?GREEN}, {willard, ?BLUE}],
    %ProposersInfo = [{kurtz, ?RED}, {kilgore, ?GREEN}, {willard, ?BLUE},
    %            {alice, ?ORANGE}, {bob, ?YELLOW}],
    %ProposersInfo = [{kurtz, ?RED}, {kilgore, ?GREEN}, {willard, ?BLUE},
    %            {alice, ?ORANGE}, {bob, ?YELLOW}, {charlie, ?PURPLE},
    %            {david, ?COLOR1}, {ed, ?COLOR2}, {faust, ?COLOR3}],
    register(proposersControl, self()),
    io:format("Sending message to ~p", [AcceptorsControl]), 
    AcceptorsControl ! {startupInfo, {proposersControl, node()}, ProposersInfo, ProposersNames}, 
    receive
        {startProposers, AccRegister, ProposersIds} ->
            start_proposers(ProposersIds, ProposersInfo, AccRegister, Sleep)
    end,
    unregister(proposersControl),
    true.
    

start_proposers(PropIds, ProposersInfo, Acceptors, Sleep) ->
    case PropIds of
        [] ->
            ok;
        [PropId|Rest] ->
            [{RegName, Colour}|RestInfo] = ProposersInfo,
            [FirstSleep|RestSleep] = Sleep,
            proposer:start(RegName, Colour, Acceptors, FirstSleep, PropId),	
            start_proposers(Rest, RestInfo, Acceptors, RestSleep)
        end.
