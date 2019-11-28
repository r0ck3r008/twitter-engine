defmodule Twitter.Init do

  def main(num, max_subscribers) do
    #start the relay
    {:ok, e_pid}=Twitter.Relay.start_link

    #start api genserver
    {:ok, api_pid}=Twitter.Api.start_link(e_pid)

    #start testing
    start_network(num, api_pid, max_subscribers, e_pid)
    {e_pid, api_pid}
  end

  def start_network(num, api_pid, max_subscribers, e_pid) do
    #start clients
    clients=for _x<-0..num-1, do: Twitter.Client.start_link

    #start client signup process
    for {_, client}<-clients, do: Twitter.Api.Public.signup(api_pid, client)

    #fetch usernames
    unames=Twitter.Api.Public.fetch_users(api_pid)

    #start logging in
    login_cli=for uname<-unames, do: Twitter.Api.Public.login(api_pid, uname)

    #Zipf distribution of followers
    Enum.reduce(unames, 1, fn x, acc ->
      for y<-0..div(max_subscribers-1, acc), do: Twitter.Api.Public.follow(Enum.at(login_cli, y), x)
      #for y<-0..div(max_subscribers-1, acc), do: Twitter.Api.Public.follow(Enum.random(login_cli), x)
      acc+1
      end
    )

    f_pid = Twitter.Relay.Public.fetch_fol_agnt_pid(e_pid)

    follower_count = Agent.get(f_pid, fn(state) ->
                      unames = Map.keys(state)
                      Enum.reduce(unames, [], fn x, acc -> [length(Map.get(state, x))|acc] end)
                      end)

    sorted_count = Enum.sort(follower_count)

    #rank_list = %{}
    #Enum.reduce(sorted_count, num, fn x, acc ->

      #Map.put(rank_list, acc, x)
      #acc-1
      #end
    #)

    generate_csv(sorted_count)


  end

  def api_tester(num, api_pid) do
    #fetch usernames
    unames=Twitter.Api.Public.fetch_users(api_pid)

    #start logging in
    login_cli=for uname<-unames, do: Twitter.Api.Public.login(api_pid, uname)
    # :timer.sleep(3000)

    #start random follow a celebrity
    celeb_indx=:rand.uniform(length(unames))
    celeb_hash=Enum.at(unames, celeb_indx)
    celeb_cli=Enum.at(login_cli, celeb_indx)
    n_followers=:rand.uniform(length(login_cli))
    for x<-0..n_followers-1, do: Twitter.Api.Public.follow(Enum.random(login_cli))

    #make the celeb tweet
    mentioned_hash=Enum.random(unames)
    msg="#hello everyone espicially @#{mentioned_hash}, #YOLO!"
    Twitter.Api.Public.tweet(celeb_cli, msg)
    #:timer.sleep(3000)

    #logout using newly created clients
    for cli<-login_cli, do: Twitter.Api.Public.logout(cli)

    :timer.sleep(3000)
    #make any celeb follower get tweets of him
    #->login any client
    cli_hash=Enum.random(unames)
    cli_pid=Twitter.Api.Public.login(api_pid, cli_hash)
    #-> login celeb
    celeb_pid=Twitter.Api.Public.login(api_pid, celeb_hash)

    #Populate celeb's timeline
    IO.puts("#{celeb_hash}'s timeline: #{inspect Twitter.Api.Public.populate_timeline(celeb_pid)}")

    #retweet from a random user
    Twitter.Api.Public.retweet(cli_pid, celeb_hash, msg)

    #delete a random user
    Twitter.Api.Public.delete_user(api_pid, cli_pid)

    #fetch my mentions
    mentioned_pid=Twitter.Api.Public.login(api_pid, mentioned_hash)
    mentioned_tweets=Twitter.Api.Public.get_my_mentions(mentioned_pid)
    IO.puts("Tweets #{mentioned_hash} is mentioned in are: #{inspect mentioned_tweets}")
  end

  def task_fn(client, api_pid, 0) do
    Twitter.Api.Public.signup(api_pid, client)
    task_fn(client, api_pid, 1)
  end
  def task_fn(client, api_pid, count) do
    :timer.sleep(1000)
    task_fn(client, api_pid, count)
  end

  def generate_csv(map) do
    {:ok, file} = File.open "zipf.csv", [:write]
    Enum.each(map, fn(x) -> IO.write(file, Integer.to_string(x)<>"\n") end)
    File.close file
  end

end
