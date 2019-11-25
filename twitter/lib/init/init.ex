defmodule Twitter.Init do

  def main(num) do
    #start the relay
    {:ok, e_pid}=Twitter.Relay.start_link

    #start api genserver
    {:ok, api_pid}=Twitter.Api.start_link(e_pid)

    #start testing
    start_network(num, api_pid)
    {e_pid, api_pid}
  end

  def start_network(num, api_pid) do
    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link

    #start client signup process
    for {_, client}<-clients, do: Twitter.Api.Public.signup(api_pid, client)
  end

  def api_tester(num, api_pid) do
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
    mentioned_hash=Enum.at(unames, Salty.Random.uniform(length(unames)-1))
    msg="#hello everyone espicially @#{mentioned_hash}, #YOLO!"
    Twitter.Api.Public.tweet(celeb_cli, msg)
    #:timer.sleep(3000)

    #logout using newly created clients
    for cli<-login_cli, do: Twitter.Api.Public.logout(cli)

    :timer.sleep(3000)
    #make any celeb follower get tweets of him
    #->login any client
    cli_hash=Enum.at(unames, Salty.Random.uniform(length(unames))-1)
    cli_pid=Twitter.Api.Public.login(api_pid, cli_hash)
    #-> login celeb
    celeb_pid=Twitter.Api.Public.login(api_pid, celeb_hash)

    #Populate celeb's timeline
    IO.puts("#{celeb_hash}'s timeline: #{inspect Twitter.Api.Public.populate_timeline(celeb_pid)}")

    #retweet from a random user
    Twitter.Api.Public.retweet(cli_pid, celeb_hash, msg)

    #delete a random user
    Twitter.Api.Public.delete_user(api_pid, cli_pid)

    #fetch my mentions
    mentioned_pid=Twitter.Api.Public.login(api_pid, mentioned_hash)
    mentioned_tweets=Twitter.Api.Public.get_my_mentions(mentioned_pid)
    IO.puts("Tweets #{mentioned_hash} is mentioned in are: #{inspect mentioned_tweets}")
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
