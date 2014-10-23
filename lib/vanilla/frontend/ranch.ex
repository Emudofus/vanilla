defmodule Vanilla.Frontend.Ranch do
  require Logger

  alias Vanilla.Frontend.Tokenizer
  alias Vanilla.Frontend.Parser
  alias Vanilla.Model.User
  alias Vanilla.Crypto

  defmodule Conn do
    defstruct socket:    nil,
              transport: nil,
              state:     0,
              closed:    false,
              user:      nil,
              ticket:    ""

    def send(conn = %Conn{socket: socket, transport: transport}, parts) when is_list(parts) do
      unless conn.closed do
        Logger.debug "SND #{inspect parts}"

        data = for part <- parts, into: "" do
          part <> "\0"
        end
        
        :ok = transport.send(socket, data)
      end

      conn
    end

    def send(conn = %Conn{socket: socket, transport: transport}, data) do
      unless conn.closed do
        Logger.debug "SND #{data}"
        :ok = transport.send(socket, data <> "\0")
      end

      conn
    end

    def close(conn = %Conn{socket: socket, transport: transport}) do
      unless conn.closed do
        Logger.debug "CLS"
        :ok = transport.close(socket)
      end

      %Conn{conn | closed: true}
    end

    def recv(%Conn{socket: socket, transport: transport}) do
      transport.recv(socket, 0, :infinity)
    end
    
  end

  @doc "Start Ranch"
  def start_link do
    Logger.debug "listening on 5555..."
    :ranch.start_listener(Vanilla.Frontend, 1, :ranch_tcp, [port: 5555], __MODULE__, [])
  end

  @doc "Start Ranch protocol"
  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end
  
  @doc false
  def init(ref, socket, transport, _opts) do
    :ok = :ranch.accept_ack(ref)
    conn = %Conn{socket: socket, transport: transport, ticket: Crypto.rand_ticket}
    Logger.debug "OPN"
    conn |> Conn.send "HC#{conn.ticket}"
    loop(conn)
  end

  defp loop(conn) do
    case conn |> Conn.recv do
      {:ok, data} ->
        {new_state, msgs} = Tokenizer.tokenize_all(conn.state, data)

        conn = %Conn{conn | state: new_state}
        conn = parse(conn, msgs)
        loop(conn)
      _ ->
        conn |> Conn.close
    end
  end

  defp parse(conn, []) do
    conn
  end

  defp parse(conn, [msg|msgs]) do
    if conn.closed do
      conn
    else
      Logger.debug "RCV #{inspect msg}"

      case Parser.parse(conn, msg) do
        new_conn = %Conn{} ->
          parse(new_conn, msgs)
        _ ->
          parse(conn, msgs)
      end
    end
  end
  
end
