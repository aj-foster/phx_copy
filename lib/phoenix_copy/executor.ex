defmodule Phoenix.Copy.Executor do
  @moduledoc false
  require Logger

  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def push(pid, path) do
    GenServer.cast(pid, {:push, path})
  end

  @impl true
  def init(opts) do
    opts = Enum.into(opts, %{})
    paths = MapSet.new()
    {:ok, {paths, opts}}
  end

  @impl true
  def handle_cast({:push, path}, {paths, opts}) do
    paths =
      if MapSet.member?(paths, path) do
        paths
      else
        Process.send_after(self(), {:pop, path}, opts.debounce)
        MapSet.put(paths, path)
      end

    {:noreply, {paths, opts}}
  end

  @impl true
  def handle_info({:pop, path}, {paths, opts}) do
    {source, destination} =
      Enum.min_by(opts.sources_and_destinations, fn {source, _destination} ->
        Path.relative_to(path, source)
        |> Path.split()
        |> length()
      end)

    relative_path = Path.relative_to(path, source)
    new_path = Path.join(destination, relative_path) |> Path.expand()

    Path.dirname(new_path)
    |> File.mkdir_p!()

    Logger.info("Copy #{relative_path}")
    File.cp!(path, new_path)

    paths = MapSet.delete(paths, path)
    {:noreply, {paths, opts}}
  end
end
