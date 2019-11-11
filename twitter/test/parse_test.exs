defmodule TwitterTest do
  use ExUnit.Case

  test "tweet parsing test" do
    assert Twitter.Engine.Helper.parse_tweet("#hello everyone espicially @naman")
    == [["hello"], ["naman"]]
  end

end
