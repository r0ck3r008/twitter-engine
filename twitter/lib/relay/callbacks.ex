defmodule Twitter.Relay do

  use GenServer
  require Logger

  def start_link do
    Logger.info("Starting the engine...")
    {:ok, u_agnt_pid}=Agent.start_link(fn-> %{} end)
    {:ok, fol_agnt_pid}=Agent.start_link(fn-> %{} end)
    GenServer.start_link(__MODULE__, {u_agnt_pid, fol_agnt_pid})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  ##########signup related
  @impl true
  def handle_call({:signup, u_pid}, _from, {u_agnt_pid, fol_agnt_pid}) do
    u_hash=Twitter.Api.Public.hash_it(inspect u_pid)
    Agent.update(u_agnt_pid, &Map.put(&1, u_hash, u_pid))
    {:reply, u_hash, {u_agnt_pid, fol_agnt_pid}}
  end

  @impl true
  def handle_call({:login, u_hash, cli_pid}, _from, {u_agnt_pid, fol_agnt_pid}) do
    u_pid=Agent.get(u_agnt_pid, &Map.get(&1, u_hash))
    Twitter.User.Public.login(u_pid, cli_pid)
    {:reply, u_pid, {u_agnt_pid, fol_agnt_pid}}
  end
  ##########signup related

  ##########follow related
  @impl true
  def handle_cast({:follow, u_hash, to_hash}, {u_agnt_pid, fol_agnt_pid}) do
    state=Agent.get(fol_agnt_pid, &Map.get(&1, to_hash))
    case state do
      nil->
        Agent.update(fol_agnt_pid, &Map.put(&1, to_hash, [u_hash]))
      _->
        Agent.update(fol_agnt_pid, &Map.put(&1, to_hash, state++[u_hash]))
    end
    Logger.debug("Follow success from #{u_hash} to #{to_hash}")
    {:noreply, {u_agnt_pid, fol_agnt_pid}}
  end
  ###########follow related

  ###########tweet related
  @impl true
  def handle_cast({:tweet, tweet_info, msg}, state) do
    Twitter.Relay.Helper.tweet_helper(tweet_info, msg, state)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:tweet_tag, tag, msg}, {u_agnt_pid, fol_agnt_pid}) do
    followers=Agent.get(fol_agnt_pid, &Map.get(&1, tag))
    for follower<-followers do
      u_pid=Agent.get(u_agnt_pid, &Map.get(&1, follower))
      send(u_pid, {:new_tweet, tag, msg})
    end
    {:noreply, {u_agnt_pid, fol_agnt_pid}}
  end
  ###########tweet related

  ###########query related
  @impl true
  def handle_call({:get_tweets, fol_hash}, _from, {u_agnt_pid, fol_agnt_pid}) do
    u_pid=Agent.get(u_agnt_pid, &Map.get(&1, fol_hash))
    tweets=Twitter.User.Public.get_tweets(u_pid)
    {:reply, tweets, {u_agnt_pid, fol_agnt_pid}}
  end
  ###########query related

  @impl true
  def terminate(_, _) do
    Logger.warn("Stopping the relay...")
  end

end
