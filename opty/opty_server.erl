-module(opty_server).
-export([start/0]).

%% Clients: Number of concurrent clients in the system
%% Entries: Number of entries in the store
%% Reads: Number of read operations per transaction
%% Writes: Number of write operations per transaction
%% Time: Duration of the experiment (in secs)

start() ->
    register(start, self()),
    io:format("~p", [{start, node()}]),
    receive
        {startup, Pid, Entries} ->  true
    end,
    register(s, server:start(Entries)),
    Pid ! {server, {s, node()}}.
