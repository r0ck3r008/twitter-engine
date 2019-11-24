defmodule Twitter.Stat.Public do

  def tweet_up(of) do
    GenServer.cast(of, :tweet_up)
  end

  def get_tweet_count(of) do
    GenServer.call(of, :get_tweets)
  end

end
