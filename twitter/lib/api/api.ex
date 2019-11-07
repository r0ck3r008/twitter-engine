defmodule Twitter.Api do

  def signup(client, e_pid) do
    Twitter.Client.Public.signup(client, e_pid)
  end

  def login(u_hash, e_pid) do
    {:ok, client_pid}=Twitter.Client.start_link
    Twitter.Client.Public.login(client_pid, u_hash, e_pid)
  end

end
