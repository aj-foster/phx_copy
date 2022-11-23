defmodule Phoenix.Copy.Watcher do
  @moduledoc false
  require Logger

  alias Phoenix.Copy.Executor

  # Start a filesystem watcher, and for each `{source, destination}` pair, copy files from the
  # `source` directory to `destination`.
  #
  # Note that this function blocks execution until an exit signal is given.
  #
  @spec watch(sources_and_destinations :: [{String.t(), String.t()}], opts :: Keyword.t()) :: term
  def watch(sources_and_destinations, opts \\ []) do
    opts = Enum.into(opts, %{})
    Logger.info("Starting Phoenix.Copy file watcher...")
    sources = Enum.map(sources_and_destinations, fn {source, _destination} -> source end)
    {:ok, watcher_pid} = FileSystem.start_link(dirs: sources)

    {:ok, executor_pid} =
      Executor.start_link(
        debounce: Map.get(opts, :debounce, 0),
        sources_and_destinations: sources_and_destinations
      )

    FileSystem.subscribe(watcher_pid)

    handle_messages({watcher_pid, executor_pid})
  end

  defp handle_messages({watcher_pid, executor_pid}) do
    receive do
      {:file_event, _watcher_pid, {path, events}} ->
        unless File.dir?(path) or :removed in events do
          Executor.push(executor_pid, path)
        end

        handle_messages({watcher_pid, executor_pid})

      {:file_event, _watcher_pid, :stop} ->
        nil
    end
  end
end
