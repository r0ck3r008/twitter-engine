defmodule Twitter.User.Helper do

  def fwd_tweets(from_hash, msg, cli_agnt_pid) do
    clients=Agent.get(cli_agnt_pid, fn(state)->state end)
    for client<-clients do
      send(client, {:new_tweet, from_hash, msg})
    end
  end
  def fwd_tweets(msg, cli_agnt_pid) do
    clients=Agent.get(cli_agnt_pid, fn(state)->state end)
    for client<-clients do
      send(client, {:new_retweet, msg})
    end
  end

end
