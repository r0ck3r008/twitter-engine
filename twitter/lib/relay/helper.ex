defmodule Twitter.Relay.Helper do

  require Logger

  def parse_regex(nil, _, list), do: list
  def parse_regex(msg, regex, list) do
    match=Regex.run(regex, msg)
    case match do
      nil->
        parse_regex(nil, regex, list)
      _->
        match=Enum.at(match, 1)
        msg=String.replace(msg, match, "")
        parse_regex(msg, regex, list++[match])
    end
  end

  def parse_tweet(msg) do
    #look for hashtags and mentions
    [parse_regex(msg, ~r/#(\w+)/, [])]++[parse_regex(msg, ~r/@(\w+)/, [])]
  end

  #called from inside genserver
  def tweet_helper(tweet_info, msg, {u_agnt_pid, fol_agnt_pid}) do
    from_hash=Enum.at(tweet_info, 0)
    followers=Agent.get(fol_agnt_pid, &Map.get(&1, from_hash))
    tags=Enum.at(tweet_info, 1)
    mentions=Enum.at(tweet_info, 2)
    fwd_tweets(from_hash, Enum.uniq(followers++mentions), msg, u_agnt_pid, :users)
    fwd_tweet(from_hash, tags, msg, u_agnt_pid, :tags)
  end

  #fwd to users(followers/mentions)
  def fwd_tweets(from_hash, u_hash_l, msg, u_agnt_pid, :users) do
    for u_hash<-u_hash_l do
      u_pid=Agent.get(u_agnt_pid, &Map.get(&1, u_hash))
      send(u_pid, {:new_tweet, from_hash, msg})
    end
  end
  #fwd to hashtags
  def fwd_tweet(from_hash, tags, msg, u_agnt_pid, :tags) do
    for tag<-tags do
      tag_pid=Agent.get(u_agnt_pid, &Map.get(&1, tag))
      case tag_pid do
        nil->
          #make new tag
          make_new_tag(tag, from_hash, u_agnt_pid)
        _->
          #          Logger.debug("tag pid is #{inspect tag_pid}")
          send(tag_pid, {:new_tweet_tag, from_hash, msg})
      end
    end
  end

  def make_new_tag(tag, from_hash, u_agnt_pid) do
    #form the user
    Logger.debug("Created new hash, #{tag}")
    {:ok, tag_pid}=Twitter.User.start_link(self(), tag)
    Agent.update(u_agnt_pid, &Map.put(&1, tag, tag_pid))
    Twitter.Relay.Public.follow(self(), from_hash, tag)
  end

end
