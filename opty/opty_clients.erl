-module(opty_clients).
-export([start/6, stop/2]).

%% Clients: Number of concurrent clients in the system
%% Entries: Number of entries in the store
%% Reads: Number of read operations per transaction
%% Writes: Number of write operations per transaction
%% Time: Duration of the experiment (in secs)

start(Clients, Entries, Reads, Writes, Time, StartServer) ->
    StartServer ! {startup, self(), Entries},
    receive 
        {server, Server} -> Server
    end,
    io:format("Starting: ~w CLIENTS, ~w ENTRIES, ~w RDxTR, ~w WRxTR, DURATION ~w s~n", 
         [Clients, Entries, Reads, Writes, Time]),
    L = startClients(Clients, [], Entries, Reads, Writes, Server),
    timer:sleep(Time*1000),
    stop(L, Server).

stop(L, Server) ->
    io:format("Stopping...~n"),
    stopClients(L),
    waitClients(L),
    Server ! stop,
    io:format("Stopped~n").

startClients(0, L, _, _, _, _) -> L;
startClients(Clients, L, Entries, Reads, Writes, Server) ->
    Pid = client:start(Clients, Entries, Reads, Writes, Server),
    startClients(Clients-1, [Pid|L], Entries, Reads, Writes, Server).

stopClients([]) ->
    ok;
stopClients([Pid|L]) ->
    Pid ! {stop, self()},	
    stopClients(L).

waitClients([]) ->
    ok;
waitClients(L) ->
    receive
        {done, Pid} ->
            waitClients(lists:delete(Pid, L))
    end.
