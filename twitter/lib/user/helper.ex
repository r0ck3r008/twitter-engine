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

  def parse_tweets(state, u_hash) do
    mentioned_in=for {_, tweets}<-state do
      for tweet<-tweets do
        mention=Regex.match?(~r/@#{u_hash}/, tweet)
        case mention do
          false->
            nil
          true->
            tweet
        end
      end
    end
    Enum.uniq(List.flatten(mentioned_in))--[nil]
  end

end
