defmodule Twitter.Test do

  use ExUnit.Case

  #Register a new user
  test "Register a new user" do
    {_e_pid, api_pid}=Twitter.Init.main(1000)
    {:ok, cli_pid}=Twitter.Client.start_link
    u_hash=Twitter.Api.Public.signup(api_pid, cli_pid)
    assert Twitter.Api.Public.user?(api_pid, u_hash)==true
    #TODO add a way to end the netowrk gracefully
  end

  #login to an existing user
  test "Login to existing user" do

  end

  """
  #logout of an existing user
  test "Logout of an existing user" do

  end

  #delete a user
  test "Delete a user" do

  end

  #pick a user and make it celeb by making all others follow it
  test "Make a celeb" do

  end

  #pick a user and tweet with mention to another user and tags
  test "Tweet test with mentions and tags" do

  end
"""
end
