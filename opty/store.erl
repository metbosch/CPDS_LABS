-module(store).
-export([new/1, stop/1, lookup/2, getSubset/3]).

new(N) ->
    list_to_tuple(entries(N, [])).

stop(Store) ->
    lists:foreach(fun(E) -> 
                    E ! stop 
                  end, 
                  tuple_to_list(Store)).

lookup(I, Store) ->
    element(I, Store). % this is a builtin function

entries(0, ListSoFar) ->
    ListSoFar;
entries(N, ListSoFar) ->
    Entry = entry:new(0),
    entries(N-1, [Entry|ListSoFar]).

getSubset(Store, ClientId, N) ->
    random:seed(ClientId, ClientId, ClientId),
    List = tuple_to_list(Store),
    Sublist = genSubset(List, N),
    list_to_tuple(Sublist).

genSubset(_, 0) ->
    [];
genSubset(Store, N) ->
    Nselec = random:uniform(length(Store)),
    [lists:nth(Nselec, Store)|genSubset(Store, N-1)].

