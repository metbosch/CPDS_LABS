-module(opty_clients).
-export([start/7, stop/2]).

%% Clients: Number of concurrent clients in the system
%% Entries: Number of entries in the store
%% EntriesClient: Number of entries per client
%% Reads: Number of read operations per transaction
%% Writes: Number of write operations per transaction
%% Time: Duration of the experiment (in secs)
%% StartServer: Erlang identifier of process in charge to start the server. 
%% In fact, this parameter is the first message printed by opty_server:start().

start(Clients, Entries, EntriesClient, Reads, Writes, Time, StartServer) ->
    StartServer ! {startup, self(), Entries, EntriesClient},
    receive 
        {server, Server} -> Server
    end,
    io:format("Starting: ~w CLIENTS, ~w ENTRIES, ~w RDxTR, ~w WRxTR, DURATION ~w s~n", 
         [Clients, Entries, Reads, Writes, Time]),
    L = startClients(Clients, [], EntriesClient, Reads, Writes, Server),
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
