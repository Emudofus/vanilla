defmodule Vanilla.Frontend.Parser do
  require Logger
  alias Vanilla.Frontend.Ranch.Conn
  alias Vanilla.Model.User

  defp export_secret_question(s) do
    String.replace s, " ", "+"
  end

  def parse(_conn, {:invalid, part}) do
    Logger.debug "invalid message #{inspect part}"
  end

  def parse(_conn, {:version, "1.29.1"}) do

  end

  def parse(conn, {:version, version}) do
    Logger.debug "invalid version #{version}"
    conn |> Conn.close
  end
    
  def parse(conn, {:auth, username, password}) do
    case User.authenticate(username, password, conn.ticket) do
      {:ok, user} ->
        %Conn{conn | user: user}
          |> Conn.send ~w(
              Ad#{user.nickname}
              Ac#{user.community}
              AH1;1;75;1
              AlK#{if user.rank > 0, do: 1, else: 0}
              AQ#{export_secret_question(user.secret_question)}
              )

      {:error, _} ->
        conn
          |> Conn.send("AlEf") # todo
          |> Conn.close
    end
  end

  def parse(conn, :get_queue) do
    conn |> Conn.send("Af0")
  end

  def parse(conn, :get_characters) do
    conn |> Conn.send("AxK0|1,3")
  end
  
  def parse(_conn, msg) do
    Logger.debug "invalid message #{inspect msg}"
  end
  
end
