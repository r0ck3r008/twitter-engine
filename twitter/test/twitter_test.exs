defmodule Twitter.Test do

  use ExUnit.Case

  test "Register/Delete a new user" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    {:ok, cli_pid}=Twitter.Client.start_link
    u_hash=Twitter.Api.Public.signup(api_pid, cli_pid)
    assert Twitter.Api.Public.user?(api_pid, u_hash)
    Twitter.Api.Public.delete_user(api_pid, cli_pid)
    refute Twitter.Api.Public.user?(api_pid, u_hash)
    #TODO add a way to end the netowrk gracefully
  end

  test "Login/Logout to existing user" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_user=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    cli_pid=Twitter.Api.Public.login(api_pid, rand_user)
    assert Twitter.Api.Public.logged_in?(cli_pid)
    Twitter.Api.Public.logout(cli_pid)
    refute Twitter.Api.Public.logged_in?(cli_pid)
  end

  test "Make a followed and a follower" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_followed=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    rand_follower=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    cli_pid=Twitter.Api.Public.login(api_pid, rand_follower)
    Twitter.Api.Public.follow(cli_pid, rand_followed)
    assert Twitter.Api.Public.following?(api_pid, cli_pid, rand_followed)
  end

  """
  #pick a user and tweet with mention to another user and tags
  test "Tweet test with mentions and tags" do

  end
"""
end
