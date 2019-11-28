defmodule TwitterTest do
  use ExUnit.Case

  test "Zipf distribution" do
    maxSubscribers = 150
    num = 200
    {e_pid, api_pid}=Twitter.Init.main(num, maxSubscribers)

    f_pid = Twitter.Relay.Public.fetch_fol_agnt_pid(e_pid)

    follower_count = Agent.get(f_pid, fn(state) ->
                      unames = Map.keys(state)
                      Enum.reduce(unames, [], fn x, acc -> [length(Map.get(state, x))|acc] end)
                      end)

    sorted_count = Enum.sort(follower_count)

    assert Enum.at(sorted_count, num-1) == maxSubscribers
    assert Enum.at(sorted_count, num-2) == round(maxSubscribers/2)
    assert Enum.at(sorted_count, num-3) == round(maxSubscribers/3)

  end


  test "test get_my_mentions with tweet having multiple mentions" do

  end

  test "test get_my_mentions with tweet having single mentions" do

  end

  test "test get_my_mentions with tweet having consecutive mentions" do

  end

  test "test single hashtag" do

  end

  test "test multiple hashtags" do

  end

  test "test register account" do

  end

  test "test failure for registration of existing user" do

  end


  test "test delete account" do

  end

  test "test deleted account removed from follower list" do

  end

  test "test send tweet" do

  end

  test "test subscription" do

  end

  test "test login before tweet and retweet" do

  end

  test "test live delivery of tweets for connected users" do

  end

  test "test fetch followed returns correct list of followed users after a followed user deletes account" do

  end

end
