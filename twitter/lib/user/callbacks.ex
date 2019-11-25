defmodule Twitter.User do

  use GenServer
  require Logger

  def start_link(e_pid) do
    {:ok, cli_agnt_pid}=Agent.start_link(fn-> [] end)
    {:ok, tweet_agnt_pid}=Agent.start_link(fn-> %{} end)
    GenServer.start_link(__MODULE__, {e_pid, cli_agnt_pid, tweet_agnt_pid})
  end
  #as hash
  def start_link(e_pid, u_hash) do
    {:ok, tweet_agnt_pid}=Agent.start_link(fn-> %{} end)
    GenServer.start_link(__MODULE__, {e_pid, nil, tweet_agnt_pid, u_hash})
  end

  #as user init
  @impl true
  def init({e_pid, cli_agnt_pid, tweet_agnt_pid}) do
    {:ok, {e_pid, cli_agnt_pid, tweet_agnt_pid}}
  end
  @impl true
  def init({e_pid, nil, tweet_agnt_pid, u_hash}) do
    {:ok, {e_pid, nil, tweet_agnt_pid, u_hash}}
  end

  #########signup related
  @impl true
  def handle_call({:signup, client_pid}, _from, {e_pid, cli_agnt_pid, tweet_agnt_pid}) do
    u_hash=Twitter.Relay.Public.signup(e_pid, self())
    Agent.update(cli_agnt_pid, &(&1++[client_pid]))
    {:reply, u_hash, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end

  @impl true
  def handle_cast(:del_usr, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    Twitter.Relay.Public.delete_user(e_pid, u_hash)
    {:noreply, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end

  @impl true
  def handle_call({:login, cli_pid}, _from, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    Agent.update(cli_agnt_pid, &(&1++[cli_pid]))
    Logger.debug("Login Success from client #{inspect cli_pid} to #{u_hash}")
    {:reply, self(), {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end

  @impl true
  def handle_call({:logout, cli_pid}, _from, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    Agent.update(cli_agnt_pid, &(&1--[cli_pid]))
    Logger.debug("Logout Success of #{inspect cli_pid} from #{u_hash}")
    {:reply, :ok, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end
  ##########signup related

  ##########follow related
  @impl true
  def handle_cast({:follow, cli_pid, to_hash}, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    state=Agent.get(cli_agnt_pid, fn(state)-> state end)
    if cli_pid in state do
      Twitter.Relay.Public.follow(e_pid, u_hash, to_hash)
    else
      Logger.warn("Follow request denied, client not logged in!")
    end
    {:noreply, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end
  ###########follow related

  ###########tweet related
  @impl true
  def handle_call({:tweet, cli_pid, msg}, _from, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    state=Agent.get(cli_agnt_pid, fn(state)-> state end)
    if cli_pid in state do
      Twitter.Relay.Public.tweet(e_pid, u_hash, msg)
      {:reply, :ok, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
    else
      {:reply, :failed, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
    end
  end

  @impl true
  def handle_cast({:retweet_notif, from_hash, msg}, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    Twitter.Relay.Public.retweet(e_pid, u_hash, from_hash, msg)
    {:noreply, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end

  @impl true
  def handle_info({:retweet_new, from_hash, msg}, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    Twitter.User.Helper.fwd_tweets("#{from_hash} Retweeted: " <> msg, cli_agnt_pid)
    {:noreply, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end

  @impl true
  def handle_info({:new_tweet, from_hash, msg}, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    Twitter.User.Helper.fwd_tweets(from_hash, msg, cli_agnt_pid)
    state=Agent.get(tweet_agnt_pid, &Map.get(&1, from_hash))
    case state do
      nil->
        Agent.update(tweet_agnt_pid, &Map.put(&1, from_hash, [msg]))
      _->
        Agent.update(tweet_agnt_pid, &Map.put(&1, from_hash, state++[msg]))
    end
    {:noreply, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end

  @impl true
  def handle_info({:new_tweet_tag, msg}, {e_pid, nil, tweet_agnt_pid, u_hash}) do
    #send to subscribers
    Twitter.Relay.Public.tweet(e_pid, u_hash, msg, :tag)
    #append to store
    state=Agent.get(tweet_agnt_pid, &Map.get(&1, u_hash))
    case state do
      nil->
        Agent.update(tweet_agnt_pid, &Map.put(&1, u_hash, [msg]))
      _->
        Agent.update(tweet_agnt_pid, &Map.put(&1, u_hash, state++[msg]))
    end
    {:noreply, {e_pid, nil, tweet_agnt_pid, u_hash}}
  end
  ###########tweet related

  ###########query related
  @impl true
  def handle_call(:get_tweets, _from, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    tweets=Agent.get(tweet_agnt_pid, &Map.get(&1, u_hash))
    {:reply, tweets, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end

  @impl true
  def handle_call(:get_mentions, _from, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    state=Agent.get(tweet_agnt_pid, fn(state)-> state end)
    tweets=Twitter.User.Helper.parse_tweets(state, u_hash)
    {:reply, tweets, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
  end
  ###########query related

  ###########testing related
  @impl true
  def handle_call({:logged_in?, cli_pid}, _from, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}) do
    state=Agent.get(cli_agnt_pid, fn(state)->state end)
    if cli_pid in state do
      {:reply, true, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
    else
      {:reply, false, {e_pid, cli_agnt_pid, tweet_agnt_pid, u_hash}}
    end
  end

  @impl true
  def terminate(_, _) do
    Logger.debug("Terminating the user...")
  end

end
