defmodule Vanilla.Frontend.Parser do
  require Logger
  alias Vanilla.Frontend.Ranch.Conn

  def parse(_conn, {:invalid, part}) do
    Logger.debug "invalid message #{inspect part}"
  end

  def parse(_conn, {:version, "1.29.1"}) do

  end

  def parse(conn, {:version, version}) do
    Logger.debug "invalid version #{version}"
    conn |> Conn.close
  end
  
  def parse(conn, {:auth, username, _password}) do
    if username == "test" do
      Conn.send conn, [
        "Adtest",     # nickname
        "Ac0",        # community
        "AH1;1;75;1", # servers
        "AlK0",       # auth success
        "AQtest?",    # secret question
      ]
    else
      conn
        |> Conn.send("AlEf")
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