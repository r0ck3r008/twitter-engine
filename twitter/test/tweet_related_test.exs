defmodule Twitter.Test.Tweet_rel do

  use ExUnit.Case

  setup do
    {e_pid, api_pid}=Twitter.Init.main(1000, 1)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    {:ok, [e_pid: e_pid, api_pid: api_pid, unames: unames]}
  end

  test "Tweet parse test" do
    assert Twitter.Relay.Helper.parse_tweet("Hello first tweet")==[[], []]
    assert Twitter.Relay.Helper.parse_tweet("#Hello first tweet, @me")==[["Hello"], ["me"]]
  end

  test("Tweet test", state) do
    cli_pid=Twitter.Api.Public.login(state[:api_pid], Enum.random(state[:unames]))
    msg="Hello first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
  end

  test("Tweet test with hash", state) do
    cli_pid=Twitter.Api.Public.login(state[:api_pid], Enum.random(state[:unames]))
    msg="#Hello first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "Hello")==[msg]
  end

  test("Tweet test with multiple hash tags", state) do
    cli_pid=Twitter.Api.Public.login(state[:api_pid], Enum.random(state[:unames]))
    msg="#Hello #first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "Hello")==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "first")==[msg]
  end


  test("Tweet test with mentions", state) do
    cli_pid=Twitter.Api.Public.login(state[:api_pid], Enum.random(state[:unames]))
    rand_mention=Enum.random(state[:unames])
    mention_pid=Twitter.Api.Public.login(state[:api_pid], rand_mention)
    msg="#Hello @#{rand_mention} first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "Hello")==[msg]
    assert Twitter.Api.Public.get_my_mentions(mention_pid)==[msg]
  end

  test("Tweet test with consecutive mentions", state) do
    cli_pid=Twitter.Api.Public.login(state[:api_pid], Enum.random(state[:unames]))
    rand_mention=Enum.random(state[:unames])
    mention_pid=Twitter.Api.Public.login(state[:api_pid], rand_mention)
    rand_mention2=Enum.random(state[:unames])
    mention_pid2=Twitter.Api.Public.login(state[:api_pid], rand_mention2)
    msg="#Hello @#{rand_mention} @#{rand_mention2} first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_my_mentions(mention_pid)==[msg]
    assert Twitter.Api.Public.get_my_mentions(mention_pid2)==[msg]
  end

end
