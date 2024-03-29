-module(entry).
-export([new/1]).

new(Value) ->
    spawn_link(fun() -> init(Value) end).

init(Value) ->
    entry(Value, make_ref()).

entry(Value, Time) ->
    receive
        {read, Ref, From} ->
            %% TODO: ADD SOME CODE
            From ! {Ref, self(), Value, Time}, 
            entry(Value, Time);
        {write, New} ->
            entry(New , make_ref());  %% TODO: COMPLETE
        {check, Ref, Readtime, From} ->
            if 
                 Time == Readtime ->  %% TODO: COMPLETE
                    From ! {Ref, ok}; %% TODO: ADD SOME CODE
                true ->
                    From ! {Ref, abort}
            end,
            entry(Value, Time);
        stop ->
            ok
    end.
