defmodule TwitterTest do
  use ExUnit.Case

  test "Hashing test" do
    assert Twitter.Engine.Public.hash_it("hello")
  end

end
