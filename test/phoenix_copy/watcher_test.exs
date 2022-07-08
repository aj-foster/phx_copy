defmodule Phoenix.Copy.WatcherTest do
  use ExUnit.Case, async: false
  import Phoenix.Copy.Assertions
  import Phoenix.Copy.Setup

  setup :create_directories

  describe "when a file changes" do
    setup :start_watcher

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
    setup :start_watcher

    test "watcher does not error", %{source: source, watcher: watcher} do
      Path.join(source, "a.txt")
      |> File.rm!()

      Path.join(source, "b/c.txt")
      |> File.rm!()

      assert Task.shutdown(watcher) == nil
    end
  end

  describe "with multiple nested watchers" do
    setup :start_multi_watcher

    test "watcher copies outer files", %{source: source, destination: destination} do
      source_file = Path.join(source, "a.txt")
      destination_file = Path.join(destination, "a.txt")

      File.write!(source_file, "New content")
      assert_file_contents(destination_file, "New content")
    end

    test "watcher copies nested files", %{sub_source: source, sub_destination: destination} do
      source_file = Path.join(source, "e.txt")
      destination_file = Path.join(destination, "e.txt")

      File.write!(source_file, "Some content")
      assert_file_contents(destination_file, "Some content")
    end

    test "watcher copies single files", %{
      single_source: single_source,
      single_destination: single_destination
    } do
      File.write!(single_source, "Some content")
      assert_file_contents(single_destination, "Some content")
    end
  end
end
