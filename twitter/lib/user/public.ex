defmodule Twitter.User.Public do

  def signup(of, client_pid) do
    u_hash=GenServer.call(of, {:signup, client_pid})
    cli_hash=Twitter.Engine.Public.hash_it(inspect client_pid)
    {u_hash, cli_hash}
  end

end
