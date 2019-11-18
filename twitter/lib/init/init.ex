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
    msg="#hello everyone espicially @#{Enum.at(unames, Salty.Random.uniform(length(unames)-1))}, #YOLO!"
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

    #wait for tasks to finish
    for task<-tasks, do: Task.await(task, :infinity)
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
