defmodule EngineTest do
  use ExUnit.Case
  # Warning: a few dummy pid's have been created for the tests. This may collide
  # with actual running process pid (since the test makes use of self())

  # Test write functions
  test "registers users in users and userPid tables" do
    Engine.initTables()
    Engine.register(self(), "username")
    assert :ets.lookup(:users, self()) |> Enum.at(0) == {self(), "username", []}
    assert :ets.lookup(:userPid, "username") |> Enum.at(0) == {"username", self()}
    assert Engine.isLoggedIn(self()) == true
  end

  # Test write functions
  test "login and logout of users" do
    Engine.initTables()
    Engine.register(self(), "username")
    assert Engine.isLoggedIn(self()) == true
    Engine.logout(self())
    assert Engine.isLoggedIn(self()) == false
  end

  test "test1: writes a tweet and also creates entry in hashtag and mentions table" do
    Engine.initTables()
    Engine.register(self(), "username")

    #mention = self() |> :erlang.pid_to_list() |> List.to_string()
    tweetText1 = "This is a tweet #studentLife #elixir @username"
    tweetText2 = "Tweet2 #studentLife"
    sequenceNum = 1
    pid = self()
    Engine.writeTweet(pid, tweetText1, sequenceNum)
    Engine.writeTweet(pid, tweetText2, sequenceNum+1)
    [{_, tweet_list}] = :ets.lookup(:tweets, pid)
    assert tweet_list == [[2, tweetText2], [1, tweetText1]]

    [{_, tweet_list_ht}] = :ets.lookup(:hashtag, "studentLife")
    assert tweet_list_ht == [[2, tweetText2], [1, tweetText1]]

    [{_, tweet_list_mn}] = :ets.lookup(:userMentions, pid)
    assert tweet_list_mn == [[1, tweetText1]]
  end

  test "test subscription" do
    Engine.initTables()
    Engine.register(self(), "username")

    dummyPid = EngineUtils.mentionToPid("<0.99.0>")
    Engine.subscribe(self(), dummyPid)
    [{_, _, followers}] = :ets.lookup(:users, self())
    assert followers == [dummyPid]

    [{_, listOfPeopleIFollow}] = :ets.lookup(:following, dummyPid)
    assert listOfPeopleIFollow == [self()]
  end
  #-----------------------------------------------------------------------------
  # Test all the get functions
  test "get followers" do
    Engine.initTables()
    Engine.register(self(), "username")

    dummyPid = EngineUtils.mentionToPid("<0.99.0>")
    Engine.subscribe(self(), dummyPid)
    assert Engine.getFollowers(self()) == [dummyPid]
  end

  test "get following" do
    Engine.initTables()
    Engine.register(self(), "username")

    dummyPid = EngineUtils.mentionToPid("<0.99.0>")
    Engine.subscribe(self(), dummyPid)
    assert Engine.getFollowing(dummyPid) == [self()]
  end

  test "get pid" do
    Engine.initTables()
    Engine.register(self(), "username")
    assert Engine.getPid("username") == self()
  end

  test "get tweets" do
    Engine.initTables()
    Engine.register(self(), "username")

    #mention = self() |> :erlang.pid_to_list() |> List.to_string()
    tweetText1 = "This is a tweet #studentLife #elixir @username"
    tweetText2 = "Tweet2 #studentLife"
    sequenceNum = 1
    pid = self()
    Engine.writeTweet(pid, tweetText1, sequenceNum)
    Engine.writeTweet(pid, tweetText2, sequenceNum+1)

    assert Engine.getTweets(pid) == [[2, tweetText2], [1, tweetText1]]
  end
end
