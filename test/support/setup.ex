defmodule Phoenix.Copy.Setup do
  import ExUnit.CaptureLog
  import Phoenix.Copy.Assertions

  alias Phoenix.Copy.Watcher

  @doc """
  Create unique source and destination directories for the current test.
  """
  def create_directories(_context) do
    random = System.unique_integer([:positive])

    source = Path.expand("../../tmp/#{random}/source", __DIR__)
    destination = Path.expand("../../tmp/#{random}/destination", __DIR__)

    sub_source = Path.join(source, "b")
    sub_destination = Path.join(destination, "d")

    single_source = Path.join(source, "e/f.txt")
    single_destination = Path.join(destination, "g/h.txt")

    File.mkdir_p!(sub_source)
    File.mkdir_p!(destination)
    File.mkdir_p!(Path.dirname(single_source))
    File.write!(Path.join(source, "a.txt"), "Test contents.\n")
    File.write!(Path.join(source, "b/c.txt"), "More test contents.\n")
    File.write!(single_source, "Event more test contents.\n")

    Application.put_env(:phoenix_copy, :default, source: source, destination: destination)
    Application.put_env(:phoenix_copy, :sub, source: sub_source, destination: sub_destination)

    Application.put_env(:phoenix_copy, :single,
      source: single_source,
      destination: single_destination
    )

    assert_file_exists(Path.join(source, "a.txt"))
    assert_file_exists(Path.join(source, "b/c.txt"))

    %{
      source: source,
      destination: destination,
      sub_source: sub_source,
      sub_destination: sub_destination,
      single_source: single_source,
      single_destination: single_destination
    }
  end

  @doc """
  Start a watcher process with previously-configured directories.
  """
  def start_watcher(%{source: source, destination: destination} = context) do
    debounce = Map.get(context, :debounce, 0)

    watcher =
      Task.async(fn ->
        capture_log(fn ->
          Watcher.watch([{source, destination, [debounce: debounce]}])
        end)
      end)

    # Look... stuff is hard, okay? Don't judge me.
    # FileSystem races against the modification of files in the test, and macOS makes some
    # interesting choices regarding the reporting of events. I'm sure there is a way to get around
    # this, but it matters very little compared to other things.
    Process.sleep(1_000)

    %{watcher: watcher}
  end

  @doc """
  Start a watcher process with multiple, nested, previously-configured directories.
  """
  def start_multi_watcher(%{
        source: source,
        destination: destination,
        sub_source: sub_source,
        sub_destination: sub_destination,
        single_source: single_source,
        single_destination: single_destination
      }) do
    watcher =
      Task.async(fn ->
        capture_log(fn ->
          Watcher.watch([
            {source, destination, [debounce: 0]},
            {sub_source, sub_destination, [debounce: 0]},
            {single_source, single_destination, [debounce: 0]}
          ])
        end)
      end)

    # Look... stuff is hard, okay? Don't judge me.
    # FileSystem races against the modification of files in the test, and macOS makes some
    # interesting choices regarding the reporting of events. I'm sure there is a way to get around
    # this, but it matters very little compared to other things.
    Process.sleep(1_000)

    %{watcher: watcher}
  end
end
