defmodule Twitter.Api.Public do

  require Logger

  def hash_it(msg) do
    :crypto.hash(:sha, msg)
    |> Base.encode16()
    |> String.slice(0, 8)
  end

  def fetch_users(of) do
    GenServer.call(of, :fetch_users)
  end

  def fetch_followed(cli_pid) do
    Twitter.Client.Public.fetch_followed(cli_pid)
  end

  def fetch_followers(cli_pid) do
    Twitter.Client.Public.fetch_followers(cli_pid)
  end

  def signup(of, client) do
    GenServer.call(of, {:signup, client})
  end

  def delete_user(of, client_pid) do
    GenServer.call(of, {:del_usr, client_pid})
  end

  def login(of, u_hash) do
    {:ok, client_pid}=Twitter.Client.start_link
    GenServer.call(of, {:login, client_pid, u_hash})
    client_pid
  end

  def logout(cli_pid) do
    Twitter.Client.Public.logout(cli_pid)
  end

  #works for both user and tag
  def follow(client_pid, to_hash) do
    Twitter.Client.Public.follow(client_pid, to_hash)
  end

  def tweet(client_pid, msg) do
    Twitter.Client.Public.tweet(client_pid, msg)
  end

  def retweet(client_pid, from_hash, msg) do
    Twitter.Client.Public.retweet(client_pid, from_hash, msg)
  end

  #serves both for users and hastags
  def get_followed_tweets(cli_pid, followed_hash) do
    Twitter.Client.Public.get_tweets(cli_pid, followed_hash)
  end

  def get_self_tweets(cli_pid) do
    Twitter.Client.Public.get_tweets(cli_pid)
  end

  def get_my_mentions(cli_pid) do
    Twitter.Client.Public.get_my_mentions(cli_pid)
  end

  #works only for users, obvio
  def populate_timeline(cli_pid) do
    followed=fetch_followed(cli_pid)
    Logger.debug("Followed are: #{inspect followed}")
    for f<-followed, do: get_followed_tweets(cli_pid, f)
  end

  #testing related
  def user?(of, u_hash) do
    GenServer.call(of, {:user?, u_hash})
  end

  def logged_in?(cli_pid) do
    Twitter.Client.Public.logged_in?(cli_pid)
  end

  def following?(cli_pid, to_hash) do
    followed=fetch_followed(cli_pid)
    if to_hash in followed do
      true
    else
      false
    end
  end

  def follower?(cli_pid, from_hash) do
    followers=fetch_followers(cli_pid)
    if from_hash in followers do
      true
    else
      false
    end
  end

end
