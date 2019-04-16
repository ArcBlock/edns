defmodule Edns.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [Edns.Server.Sup]
    opts = [strategy: :one_for_one, name: Edns.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
