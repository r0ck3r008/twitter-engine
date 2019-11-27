defmodule Twitter.Test do

  use ExUnit.Case

  test "Register/Delete a new user" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    {:ok, cli_pid}=Twitter.Client.start_link
    u_hash=Twitter.Api.Public.signup(api_pid, cli_pid)
    assert Twitter.Api.Public.user?(api_pid, u_hash)==true
    Twitter.Api.Public.delete_user(api_pid, cli_pid)
    refute Twitter.Api.Public.user?(api_pid, u_hash)==true
    #TODO add a way to end the netowrk gracefully
  end

  test "Login/Logout to existing user" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_user=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    cli_pid=Twitter.Api.Public.login(api_pid, rand_user)
    assert Twitter.Api.Public.logged_in?(cli_pid)==true
    Twitter.Api.Public.logout(cli_pid)
    refute Twitter.Api.Public.logged_in?(cli_pid)==true
  end

  test "Make a followed and a follower" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_followed=Enum.random(unames)
    rand_follower=Enum.random(unames)
    cli_pid=Twitter.Api.Public.login(api_pid, rand_follower)
    Twitter.Api.Public.follow(cli_pid, rand_followed)
    #since follow is a cast request, time delay is introduced for it to reflect
    :timer.sleep(100)
    assert Twitter.Api.Public.following?(cli_pid, rand_followed)==true
  end

  test "Test removed following after user deletion" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_followed=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    rand_follower=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    cli_pid=Twitter.Api.Public.login(api_pid, rand_follower)
    followed_pid=Twitter.Api.Public.login(api_pid, rand_followed)
    Twitter.Api.Public.follow(cli_pid, rand_followed)
    #since follow is a cast request, time delay is introduced for it to reflect
    :timer.sleep(100)
    assert Twitter.Api.Public.following?(cli_pid, rand_followed)==true
    Twitter.Api.Public.delete_user(api_pid, cli_pid)
    :timer.sleep(100)
    refute Twitter.Api.Public.follower?(followed_pid, rand_follower)==true
  end

  test "Tweet parse test" do
    assert Twitter.Relay.Helper.parse_tweet("Hello first tweet")==[[], []]
    assert Twitter.Relay.Helper.parse_tweet("#Hello first tweet, @me")==[["Hello"], ["me"]]
  end

  test "Tweet test" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    cli_pid=Twitter.Api.Public.login(api_pid, Enum.random(unames))
    msg="Hello first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
  end

  test "Tweet test with hash" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    cli_pid=Twitter.Api.Public.login(api_pid, Enum.random(unames))
    msg="#Hello first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "Hello")==[msg]
  end

  test "Tweet test with multiple hash tags" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    cli_pid=Twitter.Api.Public.login(api_pid, Enum.random(unames))
    msg="#Hello #first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "Hello")==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "first")==[msg]
  end


  test "Tweet test with mentions" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    cli_pid=Twitter.Api.Public.login(api_pid, Enum.random(unames))
    rand_mention=Enum.random(unames)
    mention_pid=Twitter.Api.Public.login(api_pid, rand_mention)
    msg="#Hello @#{rand_mention} first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_followed_tweets(cli_pid, "Hello")==[msg]
    assert Twitter.Api.Public.get_my_mentions(mention_pid)==[msg]
  end

  test "Tweet test with consecutive mentions" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    cli_pid=Twitter.Api.Public.login(api_pid, Enum.random(unames))
    rand_mention=Enum.random(unames)
    mention_pid=Twitter.Api.Public.login(api_pid, rand_mention)
    rand_mention2=Enum.random(unames)
    mention_pid2=Twitter.Api.Public.login(api_pid, rand_mention2)
    msg="#Hello @#{rand_mention} @#{rand_mention2} first tweet"
    Twitter.Api.Public.tweet(cli_pid, msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert Twitter.Api.Public.get_self_tweets(cli_pid)==[msg]
    assert Twitter.Api.Public.get_my_mentions(mention_pid)==[msg]
    assert Twitter.Api.Public.get_my_mentions(mention_pid2)==[msg]
  end

  test "Retweet test" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_tweeter=Enum.random(unames)
    rand_follower=Enum.random(unames)
    rand_follower2=Enum.random(unames)
    tweeter_pid=Twitter.Api.Public.login(api_pid, rand_tweeter)
    follower_pid=Twitter.Api.Public.login(api_pid, rand_follower)
    follower2_pid=Twitter.Api.Public.login(api_pid, rand_follower2)
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
