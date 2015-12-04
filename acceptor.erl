-module(acceptor).
-export([start/2]).

-define(delay, 2000).
-define(drop, 10000000000).
%-define(drop, 3).

start(Name, PanelId) ->
    spawn(fun() -> init(Name, PanelId) end).
        
init(Name, PanelId) ->
    {A1,A2,A3} = now(),
    random:seed(A1, A2, A3),
    Promised = order:null(), 
    Voted = order:null(),
    Value = na,
    acceptor(Name, Promised, Voted, Value, PanelId).

acceptor(Name, Promised, Voted, Value, PanelId) ->
  receive
    {prepare, Proposer, Round} ->
        R = random:uniform(?delay),
        timer:sleep(R),
        case order:gr(Round, Promised) of
            true ->
                case random:uniform(?drop) of 
                    ?drop ->
                        io:format("Message dropped~n");
                    _ -> %send message
                        Proposer ! {promise, Round, Voted, Value}%,               
                end,
                % Update gui
                if
                    Value == na ->
                        Colour = {0,0,0};
                    true ->
                        Colour = Value
                end,                
    io:format("[Acceptor ~w] Phase 1: promised ~w voted ~w colour ~w~n",
                [Name, Promised, Voted, Value]),
                PanelId ! {updateAcc, "Voted: " 
                        ++ io_lib:format("~p", [Voted]), "Promised: " 
                        ++ io_lib:format("~p", [Value]), Colour},
                acceptor(Name, Round, Voted, Value, PanelId);
            false ->
                Proposer ! {sorry, {prepare, Round}},
                acceptor(Name, Promised, Voted, Value, PanelId)
        end;
    {accept, Proposer, Round, Proposal} ->
        R = random:uniform(?delay),
        timer:sleep(R),
        case order:goe(Round, Promised) of
            true ->
                case random:uniform(?drop) of 
                    ?drop ->
                        io:format("Message dropped~n");
                    _ -> %send message
                        Proposer ! {vote, Round}%,
                end,
                case order:goe(Round, Voted) of
                    true ->
                        % Update gui
    io:format("[Acceptor ~w] Phase 2: promised ~w voted ~w colour ~w~n",
                        [Name, Promised, Round, Proposal]),
                        PanelId ! {updateAcc, "Voted: " 
                                ++ io_lib:format("~p", [Round]), "Promised: " 
                                ++ io_lib:format("~p", [Promised]), Proposal},
                        acceptor(Name, Promised, Round, Proposal, PanelId);
                    false ->
                        % Update gui
    io:format("[Acceptor ~w] Phase 2: promised ~w voted ~w colour ~w~n",
                        [Name, Promised, Voted, Value]),
                        PanelId ! {updateAcc, "Voted: " 
                                ++ io_lib:format("~p", [Voted]), "Promised: " 
                                ++ io_lib:format("~p", [Promised]), Value},
                        acceptor(Name, Promised, Voted, Value, PanelId)
                end;                            
            false ->
                Proposer ! {sorry, {accept, Round}}, %NOT SURE
                acceptor(Name, Promised, Voted, Value, PanelId)
        end;
    stop ->
        PanelId ! stop,
        ok
  end.
