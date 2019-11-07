defmodule Twitter.Init do

  def main(num) do
    #start the engine
    {:ok, e_pid}=Twitter.Engine.start_link

    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link(e_pid)

    #start client signup process
    tasks=for {_, client}<-clients, do: Task.async(fn-> task_fn(client, 0) end)

    #wait for tasks to finish
    for task<-tasks, do: Task.await(task)
  end

  def task_fn(client, 0) do
    Twitter.Client.signup(client)
    task_fn(client, 1)
  end
  def task_fn(client, count) do
    :timer.sleep(1000)
    task_fn(client, count)
  end

end
