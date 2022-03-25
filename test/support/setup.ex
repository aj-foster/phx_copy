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

    Application.put_env(:phoenix_copy, :default, source: source, destination: destination)

    File.mkdir_p!(Path.join(source, "b"))
    File.mkdir_p!(destination)
    File.write!(Path.join(source, "a.txt"), "Test contents.\n")
    File.write!(Path.join(source, "b/c.txt"), "More test contents.\n")

    assert_file_exists(Path.join(source, "a.txt"))
    assert_file_exists(Path.join(source, "b/c.txt"))

    %{source: source, destination: destination}
  end

  @doc """
  Start a watcher process with previously-configured directories.
  """
  def start_watcher(%{source: source, destination: destination}) do
    watcher =
      Task.async(fn ->
        capture_log(fn ->
          Watcher.watch(source, destination)
        end)
      end)

    # Look... stuff is hard, okay? Don't judge me.
    # FileSystem races against the modification of files in the test, and macOS makes some
    # interesting choices regarding the reporting of events. I'm sure there is a way to get around
    # this, but it matters very little compared to other things.
    Process.sleep(1000)

    %{watcher: watcher}
  end
end
