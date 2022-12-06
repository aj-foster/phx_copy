defmodule Phoenix.Copy.Watcher do
  @moduledoc false
  require Logger

  @type option :: {:debounce, non_neg_integer}
  @type definition :: {source :: String.t(), destination :: String.t(), [option]}
  @type definitions :: [definition]

  @type state :: %{
          definitions: definitions,
          timers: %{optional(path :: String.t()) => reference},
          watcher_pid: pid
        }

  # Start a filesystem watcher, and for each `{source, destination}` pair, copy files from the
  # `source` directory to `destination`.
  #
  # Note that this function blocks execution until an exit signal is given.
  #
  @spec watch(definitions) :: term
  def watch(definitions) do
    Logger.info("Starting Phoenix.Copy file watcher...")
    sources = Enum.map(definitions, fn {source, _destination, _options} -> source end)
    {:ok, watcher_pid} = FileSystem.start_link(dirs: sources)
    FileSystem.subscribe(watcher_pid)

    handle_messages(%{definitions: definitions, timers: %{}, watcher_pid: watcher_pid})
  end

  @spec handle_messages(state) :: term
  defp handle_messages(state) do
    receive do
      {:file_event, _watcher_pid, {path, events}} ->
        unless File.dir?(path) or :removed in events do
          {source, destination, options} =
            Enum.min_by(state.definitions, fn {source, _destination, _options} ->
              Path.relative_to(path, source)
              |> Path.split()
              |> length()
            end)

          if previous_timer_or_nil = state.timers[path] do
            Process.cancel_timer(previous_timer_or_nil)
          end

          relative_path = Path.relative_to(path, source)
          new_path = Path.join(destination, relative_path) |> Path.expand()
          debounce = Keyword.fetch!(options, :debounce)
          timer = Process.send_after(self(), {:copy, path, relative_path, new_path}, debounce)

          state = %{state | timers: Map.put(state.timers, path, timer)}
          handle_messages(state)
        else
          handle_messages(state)
        end

      {:file_event, _watcher_pid, :stop} ->
        nil

      {:copy, path, relative_path, new_path} ->
        Path.dirname(new_path)
        |> File.mkdir_p!()

        Logger.info("Copy #{relative_path}")
        File.cp!(path, new_path)

        handle_messages(state)
    end
  end
end
