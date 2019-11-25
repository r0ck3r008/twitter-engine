defmodule Twitter.Test do

  use ExUnit.Case

  #Register a new user
  test "Register a new user" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    {:ok, cli_pid}=Twitter.Client.start_link
    u_hash=Twitter.Api.Public.signup(api_pid, cli_pid)
    assert Twitter.Api.Public.user?(api_pid, u_hash)
    #TODO add a way to end the netowrk gracefully
  end

  #login to an existing user
  test "Login/Logout to existing user" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_user=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    cli_pid=Twitter.Api.Public.login(api_pid, rand_user)
    assert Twitter.Api.Public.logged_in?(cli_pid)
    Twitter.Api.Public.logout(cli_pid)
    refute Process.alive?(cli_pid)
  end

  #delete a user
  test "Delete a user" do
  end

  """
  #pick a user and make it celeb by making all others follow it
  test "Make a celeb" do

  end

  #pick a user and tweet with mention to another user and tags
  test "Tweet test with mentions and tags" do

  end
"""
end
