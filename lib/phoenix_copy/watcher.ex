defmodule Phoenix.Copy.Watcher do
  @moduledoc false
  require Logger

  # Start a filesystem watcher, and for each `{source, destination}` pair, copy files from the
  # `source` directory to `destination`.
  #
  # Note that this function blocks execution until an exit signal is given.
  #
  @spec watch([{String.t(), String.t()}]) :: term
  def watch(sources_and_destinations) do
    Logger.info("Starting Phoenix.Copy file watcher...")
    sources = Enum.map(sources_and_destinations, fn {source, _destination} -> source end)
    {:ok, watcher_pid} = FileSystem.start_link(dirs: sources)
    FileSystem.subscribe(watcher_pid)

    handle_messages(sources_and_destinations, watcher_pid)
  end

  defp handle_messages(sources_and_destinations, watcher_pid) do
    receive do
      {:file_event, _watcher_pid, {path, events}} ->
        unless File.dir?(path) or :removed in events do
          {source, destination} =
            Enum.min_by(sources_and_destinations, fn {source, _destination} ->
              Path.relative_to(path, source)
              |> Path.split()
              |> length()
            end)

          relative_path = Path.relative_to(path, source)
          new_path = Path.join(destination, relative_path)

          Path.dirname(new_path)
          |> File.mkdir_p!()

          Logger.info("Copy #{relative_path}")
          File.cp!(path, new_path)
        end

        handle_messages(sources_and_destinations, watcher_pid)

      {:file_event, _watcher_pid, :stop} ->
        nil
    end
  end
end
