defmodule MAX.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MAX.Server
    ]

    opts = [strategy: :one_for_one, name: Max.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule MAX.Server do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_) do
    MAX.Nif.start()
    {:ok, %{}}
  end

  @impl true
  def handle_info(message, state) do
    Logger.debug(inspect(message))
    {:noreply, state}
  end
end

defmodule MAX.Nif do
  @moduledoc false
  @on_load {:__init__, 0}

  def __init__ do
    :erlang.load_nif(Application.app_dir(:max, "priv/max_nif"), 0)
  end

  def start do
    :erlang.nif_error("NIF library not loaded")
  end
end
