defmodule Phoenix.Copy.WatcherTest do
  use ExUnit.Case, async: false
  import Phoenix.Copy.Assertions
  import Phoenix.Copy.Setup

  setup [:create_directories, :start_watcher]

  describe "when a file changes" do
    test "watcher copies the file", %{source: source, destination: destination} do
      source_file = Path.join(source, "a.txt")
      destination_file = Path.join(destination, "a.txt")

      File.write!(source_file, "New content")
      assert_file_contents(destination_file, "New content")

      source_file = Path.join(source, "b/c.txt")
      destination_file = Path.join(destination, "b/c.txt")

      File.write!(source_file, "More new content")
      assert_file_contents(destination_file, "More new content")
    end
  end

  describe "when a file is removed" do
    test "watcher does not error", %{source: source, watcher: watcher} do
      Path.join(source, "a.txt")
      |> File.rm!()

      Path.join(source, "b/c.txt")
      |> File.rm!()

      assert Task.shutdown(watcher) == nil
    end
  end
end
