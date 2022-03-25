defmodule Phoenix.Copy.Watcher do
  @moduledoc false
  require Logger

  # Start a filesystem watcher on the given `source` directory and copy modified files to
  # `destination`.
  #
  # Note that this function blocks execution until an exit signal is given.
  #
  def watch(source, destination) do
    Logger.info("Starting Phoenix.Copy file watcher...")
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [source])
    FileSystem.subscribe(watcher_pid)

    handle_messages(source, destination, watcher_pid)
  end

  defp handle_messages(source, destination, watcher_pid) do
    receive do
      {:file_event, _watcher_pid, {path, events}} ->
        unless File.dir?(path) or :removed in events do
          relative_path = Path.relative_to(path, source)
          new_path = Path.join(destination, relative_path)

          Path.dirname(new_path)
          |> File.mkdir_p!()

          Logger.info("Copy #{relative_path}")
          File.cp!(path, new_path)
        end

        handle_messages(source, destination, watcher_pid)

      {:file_event, _watcher_pid, :stop} ->
        nil
    end
  end
end
