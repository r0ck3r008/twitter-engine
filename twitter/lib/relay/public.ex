defmodule Twitter.Relay.Public do

  def signup(of, u_pid) do
    GenServer.call(of, {:signup, u_pid})
  end

  def login(of, u_hash, cli_pid) do
    GenServer.call(of, {:login, u_hash, cli_pid})
  end

  def follow(of, u_hash, to_hash) do
    GenServer.cast(of, {:follow, u_hash, to_hash})
  end

  #as user
  def tweet(of, u_hash, msg) do
    tweet_info=[u_hash]++Twitter.Relay.Helper.parse_tweet(msg)
    GenServer.cast(of, {:tweet, tweet_info, msg})
  end
  #as tag
  def tweet(of, u_hash, msg, :tag) do
    GenServer.cast(of, {:tweet_tag, u_hash, msg})
  end

end
