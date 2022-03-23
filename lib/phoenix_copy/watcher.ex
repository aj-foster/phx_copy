defmodule Phoenix.Copy.Watcher do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init([source, destination]) do
    Logger.info("Starting Phoenix.Copy file watcher...")
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [source])
    FileSystem.subscribe(watcher_pid)

    {:ok, %{watcher_pid: watcher_pid, source: source, destination: destination}}
  end

  def handle_info(
        {:file_event, _watcher_pid, {path, _events}},
        %{source: source, destination: destination} = state
      ) do
    unless File.dir?(path) do
      relative_path = Path.relative_to(path, source)
      new_path = Path.join(destination, relative_path)

      Path.dirname(new_path)
      |> File.mkdir_p!()

      Logger.info("Copy #{relative_path}")
      File.cp!(path, new_path)
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state) do
    {:stop, :normal, state}
  end
end
