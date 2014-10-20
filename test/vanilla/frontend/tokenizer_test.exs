defmodule Vanilla.Frontend.RanchTest do
  use ExUnit.Case

  import Vanilla.Frontend.Tokenizer

  test "parse_all" do
    assert tokenize_all(0, "1.29.1\n\0ab\n#1cd\n\0Af\n\0") == {2, [{:version, "1.29.1"}, {:auth, "ab", "cd"}, :get_queue]}
  end
end