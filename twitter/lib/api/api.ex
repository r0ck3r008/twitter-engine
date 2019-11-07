defmodule Twitter.Api do

  def signup(client, e_pid) do
    Twitter.Client.Public.signup(client, e_pid)
  end

end
