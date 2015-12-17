-module(server).
-export([start/2]).

start(N, NC) ->
    spawn(fun() -> init(N, NC) end).

init(N, NC) ->
    Store = store:new(N),
    Validator = validator:start(),
    server(Validator, Store, NC).
    
server(Validator, Store, NC) ->
    receive 
        {open, Client, ClientId} ->
            Client ! {transaction, Validator, store:getSubset(Store, ClientId, NC)}, %% TODO: ADD SOME CODE
            server(Validator, Store, NC);
        stop ->
            Validator ! stop,
            store:stop(Store)
    end.
