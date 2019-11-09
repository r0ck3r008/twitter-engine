defmodule Twitter.Init do

  def main(num) do
    #start the engine
    {:ok, e_pid}=Twitter.Engine.start_link

    #start simulator
    {:ok, sim_pid}=Twitter.Simulator.start_link(e_pid)

    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link

    #start client signup process
    tasks=for {_, client}<-clients, do: Task.async(fn-> task_fn(client, sim_pid, 0) end)

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
