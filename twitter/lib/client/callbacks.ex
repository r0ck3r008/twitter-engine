defmodule Twitter.Client do

  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end
  def start_link(stat_pid) do
    GenServer.start_link(__MODULE__, stat_pid)
  end

  @impl true
  def init(stat_pid) do
    {:ok, {stat_pid}}
  end

  ##########signup related
  @impl true
  def handle_call({:signup, e_pid}, _from, {stat_pid}) do
    {:ok, u_pid}=Twitter.User.start_link(e_pid)
    u_hash=Twitter.User.Public.signup(u_pid, self())
    Logger.debug("Signup success #{u_hash}")
    {:reply, u_hash, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_call(:del_usr, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    Twitter.User.Public.delete_user(u_pid)
    GenServer.stop(u_pid, :normal)
    {:reply, u_hash, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_call({:login, u_hash, e_pid}, _from, {stat_pid}) do
    u_pid=Twitter.Relay.Public.login(e_pid, u_hash, self())
    {:reply, :ok, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_call(:logout, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    Twitter.User.Public.logout(u_pid, self())
    {:reply, :ok, {u_hash, u_pid, e_pid, stat_pid}}
  end
  ###########signup related

  ###########follow related
  @impl true
  def handle_cast({:follow, to_hash}, {u_hash, u_pid, e_pid, stat_pid}) do
    Twitter.User.Public.follow(u_pid, self(), to_hash)
    {:noreply, {u_hash, u_pid, e_pid, stat_pid}}
  end
  ###########follow related

  ###########tweet related
  @impl true
  def handle_cast({:tweet, msg}, {u_hash, u_pid, e_pid, stat_pid}) do
    case Twitter.User.Public.tweet(u_pid, self(), msg) do
      :ok->
        Logger.info("Tweet #{msg} sent as user #{u_hash}")
      _->
        Logger.error("Tweet #{msg} failed to send as user #{u_hash}")
    end
    {:noreply, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_info({:new_tweet, from_hash, msg}, {u_hash, u_pid, e_pid, stat_pid}) do
    if stat_pid != nil do
      Twitter.Stat.Public.count_up(stat_pid)
    end
    Logger.debug("[#{u_hash}] Received new tweet from #{from_hash}: #{msg}")
    {:noreply, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_cast({:retweet_notif, from_hash, msg}, {u_hash, u_pid, e_pid, stat_pid}) do
    Twitter.User.Public.retweet(u_pid, from_hash, msg)
    {:noreply, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_info({:new_retweet, msg}, {u_hash, u_pid, e_pid, stat_pid}) do
    Logger.debug("#{msg}")
    {:noreply, {u_hash, u_pid, e_pid, stat_pid}}
  end
  ###########tweet related

  ###########query related
  @impl true
  def handle_call({:get_fol_tweets, fol_hash}, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    tweets=Twitter.Relay.Public.get_tweets(e_pid, fol_hash)
    {:reply, tweets, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_call(:get_tweets, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    tweets=Twitter.User.Public.get_tweets(u_pid)
    {:reply, tweets, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_call(:fetch_followed, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    followed=Twitter.Relay.Public.fetch_followed(e_pid, u_hash)
    {:reply, followed, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_call(:fetch_followers, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    followers=Twitter.Relay.Public.fetch_followers(e_pid, u_hash)
    {:reply, followers, {u_hash, u_pid, e_pid, stat_pid}}
  end

  @impl true
  def handle_call(:get_mentions, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    tweets=Twitter.User.Public.get_my_mentions(u_pid)
    {:reply, tweets, {u_hash, u_pid, e_pid, stat_pid}}
  end
  ###########query related

  ###########testing related
  @impl true
  def handle_call(:logged_in?, _from, {u_hash, u_pid, e_pid, stat_pid}) do
    {:reply,
      Twitter.User.Public.logged_in?(u_pid, self()),
      {u_hash, u_pid, e_pid, stat_pid}
    }
  end

  @impl true
  def terminate(_, _) do
    Logger.debug("Terminating the client...")
  end

end
