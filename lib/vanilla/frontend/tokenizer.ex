defmodule Vanilla.Frontend.Tokenizer do

  @delimiter "\n\0"
  
  @doc "Tokenize data into analyzable words"
  def tokenize_all(state, data) do
    parts = String.split(data, @delimiter)
    tokenize_all(state, parts, [])
  end

  defp tokenize_all(state, [], acc) do
    acc = acc |> Enum.reverse
    {state, acc}
  end

  defp tokenize_all(state, [""|parts], acc) do
    tokenize_all(state, parts, acc)
  end

  defp tokenize_all(state, [part|parts], acc) do
    case tokenize(state, part) do
      {new_state, msg} -> tokenize_all(new_state, parts, [msg|acc])
      msg -> tokenize_all(state, parts, [msg|acc])
    end
  end

  defp tokenize(0, version) do
    {1, {:version, version}}
  end

  defp tokenize(1, data) do
    [username, password] = String.split(data, "\n#1")
    {2, {:auth, username, password}}
  end

  defp tokenize(2, "Af") do
    :get_queue
  end

  defp tokenize(2, "Ax") do
    :get_characters
  end

  defp tokenize(_, data) do
    {:invalid, data}
  end
end