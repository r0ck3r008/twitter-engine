defmodule Twitter.Init do

  def main(num) do
    #start the engine
    {:ok, e_pid}=Twitter.Engine.start_link

    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link

    #start client signup process
    tasks=for {_, client}<-clients, do: Task.async(fn-> task_fn(client, e_pid, 0) end)

    #wait for tasks to finish
    for task<-tasks, do: Task.await(task, :infinity)
  end

  def task_fn(client, e_pid, 0) do
    Twitter.Api.signup(client, e_pid)
    task_fn(client, e_pid, 1)
  end
  def task_fn(client, e_pid, count) do
    :timer.sleep(1000)
    task_fn(client, e_pid, count)
  end

end
