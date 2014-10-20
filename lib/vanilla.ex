defmodule Vanilla do
  use Application

  def start(_type, _args) do
    Vanilla.Supervisor.start_link
  end
  
end
