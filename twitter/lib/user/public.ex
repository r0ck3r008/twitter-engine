defmodule Twitter.User.Public do

  def signup(of, client_pid) do
    GenServer.call(of, {:signup, client_pid})
  end

  def login(of, cli_pid) do
    GenServer.cast(of, {:login, cli_pid})
  end

  def logout(of, cli_pid) do
    GenServer.call(of, {:logout, cli_pid})
  end

  def follow(of, cli_pid, to_hash) do
    GenServer.cast(of, {:follow, cli_pid, to_hash})
  end

  def tweet(of, cli_pid, msg) do
    GenServer.call(of, {:tweet, cli_pid, msg})
  end

end
