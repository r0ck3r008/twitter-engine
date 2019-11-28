defmodule Twitter.Test.User_rel do

  use ExUnit.Case

  setup do
    {e_pid, api_pid}=Twitter.Init.main(1000, 1)
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
  #TODO
  #Live delivery of tweets, assert recv
end
