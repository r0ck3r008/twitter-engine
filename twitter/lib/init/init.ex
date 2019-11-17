defmodule Twitter.Init do

  def main(num) do
    #start the relay
    {:ok, e_pid}=Twitter.Relay.start_link

    #start api genserver
    {:ok, api_pid}=Twitter.Api.start_link(e_pid)

    #start testing
    api_tester(num, api_pid)
  end

  def api_tester(num, api_pid) do
    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link

    #start client signup process
    tasks=for {_, client}<-clients, do: Task.async(fn-> task_fn(client, api_pid, 0) end)
    #    :timer.sleep(3000)

    #fetch usernames
    unames=Twitter.Api.Public.fetch_users(api_pid)

    #start logging in
    login_cli=for uname<-unames, do: Twitter.Api.Public.login(api_pid, uname)
    # :timer.sleep(3000)

    #start random follow a celebrity
    celeb_indx=Salty.Random.uniform(length(unames)-1)
    celeb_hash=Enum.at(unames, celeb_indx)
    celeb_cli=Enum.at(login_cli, celeb_indx)
    n_followers=Salty.Random.uniform(length(login_cli))-1
    for x<-0..n_followers-1, do: Twitter.Api.Public.follow(Enum.at(login_cli, x), celeb_hash)

    #make the celeb tweet
    Twitter.Api.Public.tweet(celeb_cli,
      "#hello everyone espicially @#{Enum.at(unames, Salty.Random.uniform(length(unames)-1))}, #YOLO!")
    #:timer.sleep(3000)

    #logout using newly created clients
    for cli<-login_cli, do: Twitter.Api.Public.logout(cli)

    #make any celeb follower get tweets of him
    #->login any client
    cli_hash=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    cli_pid=Twitter.Api.Public.login(api_pid, cli_hash)
    #->get tweets of celeb
    fetch_tweets(cli_pid, celeb_hash)
    #make celeb get his own tweets
    #-> login celeb
    celeb_pid=Twitter.Api.Public.login(api_pid, celeb_hash)
    #->fetch tweets
    fetch_tweets(celeb_pid)

    #fetch users that follow celeb
    IO.puts("#{celeb_hash} follows: #{inspect Twitter.Api.Public.fetch_followed(celeb_pid)}")

    #wait for tasks to finish
    for task<-tasks, do: Task.await(task, :infinity)
  end

  def fetch_tweets(cli_pid, celeb_hash) do
    tweets=Twitter.Api.Public.get_followed_tweets(cli_pid, celeb_hash)
    case tweets do
      nil->
        :timer.sleep(100)
        fetch_tweets(cli_pid, celeb_hash)
      _->
        IO.puts("Tweetes of celeb are: #{inspect tweets}")
    end
  end

  def fetch_tweets(celeb_pid) do
    tweets=Twitter.Api.Public.get_self_tweets(celeb_pid)
    case tweets do
      nil->
        :timer.sleep(100)
        fetch_tweets(celeb_pid)
      _->
        IO.puts("Tweets of celeb(self) are: #{inspect tweets}")
    end
  end

  def task_fn(client, api_pid, 0) do
    Twitter.Api.Public.signup(api_pid, client)
    task_fn(client, api_pid, 1)
  end
  def task_fn(client, api_pid, count) do
    :timer.sleep(1000)
    task_fn(client, api_pid, count)
  end

end
