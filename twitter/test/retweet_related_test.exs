defmodule Twitter.Test.Retweet_rel do

  use ExUnit.Case

  def equivalance(l1, l2) do
    op=for l<-l1 do
      if l not in l2 do
        false
      else
        true
      end
    end
    Enum.uniq(op)
  end

  setup do
    {_e_pid, api_pid}=Twitter.Init.main(1000, 1)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    rand_tweeter=Enum.random(unames)
    rand_follower=Enum.random(unames)
    rand_follower2=Enum.random(unames)
    tweeter_pid=Twitter.Api.Public.login(api_pid, rand_tweeter)
    follower_pid=Twitter.Api.Public.login(api_pid, rand_follower)
    follower2_pid=Twitter.Api.Public.login(api_pid, rand_follower2)
    Twitter.Api.Public.follow(follower_pid, rand_tweeter)
    Twitter.Api.Public.follow(follower2_pid, rand_follower)
    {:ok, [rand_tweeter: rand_tweeter, rand_follower: rand_follower, rand_follower2: rand_follower2,
                                              tweeter_pid: tweeter_pid, follower_pid: follower_pid, follower2_pid: follower2_pid]}
  end

  test("Retweet test", state) do
    msg="Hello first tweet"
    Twitter.Api.Public.tweet(state[:tweeter_pid], msg)
    Twitter.Api.Public.retweet(state[:follower_pid], state[:rand_tweeter], msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert equivalance(Twitter.Api.Public.get_followed_tweets(
                                state[:follower2_pid], state[:rand_follower]), ["Retweet: "<>msg])==[true]
  end

  test("Retweet test with multiple hash tags", state) do
    msg="#Hello #first tweet"
    Twitter.Api.Public.tweet(state[:tweeter_pid], msg)
    Twitter.Api.Public.retweet(state[:follower_pid], state[:rand_tweeter], msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert equivalance(Twitter.Api.Public.get_self_tweets(
                                    state[:tweeter_pid]), [msg])==[true]
    assert equivalance(Twitter.Api.Public.get_followed_tweets(
                                    state[:tweeter_pid], "Hello"), ["Retweet: "<>msg, msg])==[true]
    assert equivalance(Twitter.Api.Public.get_followed_tweets(
                                    state[:tweeter_pid], "first"), ["Retweet: "<>msg, msg])==[true]
    assert equivalance(Twitter.Api.Public.get_followed_tweets(
                                    state[:follower2_pid], state[:rand_follower]), ["Retweet: "<>msg])==[true]
  end

  test("Retweet test with mentions", state) do
    msg="#Hello @#{state[:rand_follower2]} first tweet"
    Twitter.Api.Public.tweet(state[:tweeter_pid], msg)
    Twitter.Api.Public.retweet(state[:follower_pid], state[:rand_tweeter], msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert equivalance(Twitter.Api.Public.get_self_tweets(
                                            state[:tweeter_pid]), [msg])==[true]
    assert equivalance(Twitter.Api.Public.get_followed_tweets(
                                            state[:tweeter_pid], "Hello"), ["Retweet: "<>msg, msg])==[true]
    assert equivalance(Twitter.Api.Public.get_my_mentions(
                                            state[:follower2_pid]), [msg, "Retweet: "<>msg])==[true]
    assert equivalance(Twitter.Api.Public.get_followed_tweets(state[:follower2_pid],
                                            state[:rand_follower]), ["Retweet: "<>msg])==[true]
  end

  test("Retweet test with consecutive mentions", state) do
    msg="#Hello @#{state[:rand_follower]} @#{state[:rand_follower2]} first tweet"
    Twitter.Api.Public.tweet(state[:tweeter_pid], msg)
    Twitter.Api.Public.retweet(state[:follower_pid], state[:rand_tweeter], msg)
    #since tweet is a cast request, they need time to be reflected on updation
    :timer.sleep(100)
    assert equivalance(Twitter.Api.Public.get_self_tweets(
                                            state[:tweeter_pid]), [msg])==[true]
    assert equivalance(Twitter.Api.Public.get_my_mentions(
                                            state[:follower_pid]), [msg, "Retweet: "<>msg])==[true]
    assert equivalance(Twitter.Api.Public.get_my_mentions(
                                            state[:follower2_pid]), [msg, "Retweet: "<>msg])==[true]
    assert equivalance(Twitter.Api.Public.get_followed_tweets(
                                            state[:follower2_pid], state[:rand_follower]), ["Retweet: "<>msg])==[true]
  end

end
