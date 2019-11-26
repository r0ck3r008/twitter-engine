defmodule Twitter.User.Public do

  def signup(of, client_pid) do
    GenServer.call(of, {:signup, client_pid})
  end

  def delete_user(of) do
    GenServer.cast(of, :del_usr)
  end

  def login(of, cli_pid) do
    GenServer.call(of, {:login, cli_pid})
  end

  def logout(of, cli_pid) do
    GenServer.call(of, {:logout, cli_pid})
  end

  def follow(of, cli_pid, to_hash) do
    GenServer.cast(of, {:follow, cli_pid, to_hash})
  end

  def tweet(of, cli_pid, msg) do
    GenServer.call(of, {:tweet, cli_pid, msg})
  end

  def retweet(of, from_hash, msg) do
    GenServer.cast(of, {:retweet_notif, from_hash, msg})
  end

  def get_tweets(of) do
    GenServer.call(of, :get_tweets)
  end

  def get_my_mentions(of) do
    GenServer.call(of, :get_mentions)
  end

  #############testing related
  def logged_in?(of, cli_pid) do
    GenServer.call(of, {:logged_in?, cli_pid})
  end

end
