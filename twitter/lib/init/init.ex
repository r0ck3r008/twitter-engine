defmodule Twitter.Init do

  def main(num, testing) do
    #start the relay
    {:ok, e_pid}=Twitter.Relay.start_link

    #start api genserver
    {:ok, api_pid}=Twitter.Api.start_link(e_pid)

    #start testing
    if testing==1 do
      start_network(num, api_pid)
      {e_pid, api_pid}
    else
      api_tester(num, api_pid)
    end
  end

  def start_network(num, api_pid) do
    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link

    #start client signup process
    for {_, client}<-clients, do: Twitter.Api.Public.signup(api_pid, client)
  end

  def api_tester(num, api_pid) do
    {:ok, stat_pid}=Twitter.Stat.start_link(num)
    clients=for _x<-0..num-1, do: Twitter.Client.start_link(stat_pid)
    tasks=for {_, client}<-clients, do: Task.async(fn-> task_fn(client, api_pid, 0) end)
    #fetch usernames
    :timer.sleep(1)
    unames=Twitter.Api.Public.fetch_users(api_pid)
    loggedin_clients=for uname<-unames, do: {uname, Twitter.Api.Public.login(api_pid, uname)}
    {celeb_uname, celeb_pid}=Enum.random(loggedin_clients)

    for {uname, pid}<-loggedin_clients do
        Twitter.Api.Public.follow(pid, celeb_uname)
    end

    :timer.sleep(1000)

    tweet_tester(loggedin_clients, {celeb_uname, celeb_pid}, stat_pid)

    for task<-tasks, do: Task.await(task, :infinity)
  end

  def tweet_tester(clients, {celeb_uname, celeb_pid}, stat_pid) do
    msg="Hello @#{elem(Enum.random(clients), 0)}"
    Twitter.Stat.Public.start_timer(stat_pid)
    Twitter.Api.Public.tweet(celeb_pid, msg)
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
