-module(estatsd_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_link/1, start_link/3]).
-export([appvar/2]).

%% Supervisor callbacks
-export([init/1]).

-define(FLUSH_INTERVAL, appvar(flush_interval, 10000)).
-define(GRAPHITE_HOST,  appvar(graphite_host,  "127.0.0.1")).
-define(GRAPHITE_PORT,  appvar(graphite_port,  2003)).
-define(ENABLED,        appvar(enabled,        true)).

%% ===================================================================
%% API functions
%% ===================================================================


start_link() ->
    start_link( ?FLUSH_INTERVAL, ?GRAPHITE_HOST, ?GRAPHITE_PORT).

start_link(FlushIntervalMs) ->
    start_link( FlushIntervalMs, ?GRAPHITE_HOST, ?GRAPHITE_PORT).

start_link(FlushIntervalMs, GraphiteHost, GraphitePort) ->
    supervisor:start_link( {local, ?MODULE}
                         , ?MODULE
                         , [FlushIntervalMs, GraphiteHost, GraphitePort]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([FlushIntervalMs, GraphiteHost, GraphitePort]) ->
    Children =
        case ?ENABLED of
            true  ->
                [{ estatsd_server
                 , { estatsd_server, start_link
                   , [FlushIntervalMs, GraphiteHost, GraphitePort]}
                 , permanent, 5000, worker, [estatsd_server] }];
            false ->
                lager:info("estatsd disabled"),
                []
        end,
    {ok, { {one_for_one, 10000, 10}, Children} }.

appvar(K, Def) ->
    case application:get_env(estatsd, K) of
        {ok, Val} -> Val;
        undefined -> Def
    end.
