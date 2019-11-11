defmodule Twitter.Init do

  def main(num) do
    #start the engine
    {:ok, e_pid}=Twitter.Engine.start_link

    #start simulator
    {:ok, sim_pid}=Twitter.Simulator.start_link(e_pid)

    #start testing
    api_tester(num, sim_pid)
  end

  def api_tester(num, sim_pid) do
    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link

    #start client signup process
    tasks=for {_, client}<-clients, do: Task.async(fn-> task_fn(client, sim_pid, 0) end)
    :timer.sleep(3000)

    #fetch usernames
    unames=Twitter.Simulator.Public.fetch_users(sim_pid)

    #start logging in
    login_cli=for uname<-unames, do: Twitter.Simulator.Public.login(sim_pid, uname)
    :timer.sleep(3000)

    #start random follow a celebrity
    celeb_indx=Salty.Random.uniform(length(unames)-1)
    celeb_hash=Enum.at(unames, celeb_indx)
    celeb_cli=Enum.at(login_cli, celeb_indx)
    n_followers=Salty.Random.uniform(length(login_cli))-1
    for x<-0..n_followers-1, do: Twitter.Simulator.Public.follow(sim_pid, Enum.at(login_cli, x), celeb_hash)

    #make the celeb tweet
    Twitter.Simulator.Public.tweet(sim_pid, celeb_cli,
                "#hello everyone espicially @#{Enum.at(unames, Salty.Random.uniform(length(unames)-1))}, #YOLO!")

    #wait for tasks to finish
    for task<-tasks, do: Task.await(task, :infinity)
  end

  def task_fn(client, sim_pid, 0) do
    Twitter.Simulator.Public.signup(sim_pid, client)
    task_fn(client, sim_pid, 1)
  end
  def task_fn(client, sim_pid, count) do
    :timer.sleep(1000)
    task_fn(client, sim_pid, count)
  end

end
