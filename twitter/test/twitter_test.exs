defmodule Twitter.Test do

  use ExUnit.Case

  setup do
    {e_pid, api_pid}=Twitter.Init.main(100000, 1)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    {:ok, [e_pid: e_pid, api_pid: api_pid, unames: unames]}
  end

  test("Register/Delete a new user", state) do
    {:ok, cli_pid}=Twitter.Client.start_link
    u_hash=Twitter.Api.Public.signup(state[:api_pid], cli_pid)
    assert Twitter.Api.Public.user?(state[:api_pid], u_hash)==true
    Twitter.Api.Public.delete_user(state[:api_pid], cli_pid)
    refute Twitter.Api.Public.user?(state[:api_pid], u_hash)==true
    #TODO add a way to end the netowrk gracefully
  end

  test("Login/Logout to existing user", state) do
    rand_user=Enum.random(state[:unames])
    cli_pid=Twitter.Api.Public.login(state[:api_pid], rand_user)
    assert Twitter.Api.Public.logged_in?(cli_pid)==true
    Twitter.Api.Public.logout(cli_pid)
    refute Twitter.Api.Public.logged_in?(cli_pid)==true
  end

  test("Make a followed and a follower", state) do
    rand_followed=Enum.random(state[:unames])
    rand_follower=Enum.random(state[:unames])
    cli_pid=Twitter.Api.Public.login(state[:api_pid], rand_follower)
    Twitter.Api.Public.follow(cli_pid, rand_followed)
    #since follow is a cast request, time delay is introduced for it to reflect
    :timer.sleep(100)
    assert Twitter.Api.Public.following?(cli_pid, rand_followed)==true
  end

  test("Test removed following after user deletion", state) do
    rand_followed=Enum.random(state[:unames])
    rand_follower=Enum.random(state[:unames])
    cli_pid=Twitter.Api.Public.login(state[:api_pid], rand_follower)
    followed_pid=Twitter.Api.Public.login(state[:api_pid], rand_followed)
    Twitter.Api.Public.follow(cli_pid, rand_followed)
    #since follow is a cast request, time delay is introduced for it to reflect
    :timer.sleep(100)
    assert Twitter.Api.Public.following?(cli_pid, rand_followed)==true
    Twitter.Api.Public.delete_user(state[:api_pid], cli_pid)
    :timer.sleep(100)
    refute Twitter.Api.Public.follower?(followed_pid, rand_follower)==true
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

  test("Retweet test", state) do
    rand_tweeter=Enum.random(state[:unames])
    rand_follower=Enum.random(state[:unames])
    rand_follower2=Enum.random(state[:unames])
    tweeter_pid=Twitter.Api.Public.login(state[:api_pid], rand_tweeter)
    follower_pid=Twitter.Api.Public.login(state[:api_pid], rand_follower)
    follower2_pid=Twitter.Api.Public.login(state[:api_pid], rand_follower2)
    Twitter.Api.Public.follow(follower_pid, rand_tweeter)
    Twitter.Api.Public.follow(follower2_pid, rand_follower)
    msg="Hello first tweet"
    Twitter.Api.Public.tweet(tweeter_pid, msg)
    Twitter.Api.Public.retweet(follower_pid, rand_tweeter, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_followed_tweets(follower2_pid, rand_follower)==["Retweet: "<>msg]
  end
  #TODO
  #Live delivery of tweets, assert recv
end
