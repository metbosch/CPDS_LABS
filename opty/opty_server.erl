-module(opty_server).
-export([start/0]).

%% Entries: Number of entries in the store
%% EntriesClient: Number of entries per client

start() ->
    register(start, self()),
    io:format("~p", [{start, node()}]),
    receive
        {startup, Pid, Entries, EntriesClient} ->  true
    end,
    register(s, server:start(Entries, EntriesClient)),
    Pid ! {server, {s, node()}}.
