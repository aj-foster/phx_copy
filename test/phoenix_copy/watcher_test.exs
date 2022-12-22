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

  describe "with a debounce time configured" do
    setup do: %{debounce: 1_000}
    setup :start_watcher

    test "debounces events for the same file", %{source: source, destination: destination} do
      {:ok, watcher_pid} = FileSystem.start_link(dirs: [destination])
      FileSystem.subscribe(watcher_pid)

      source_file = Path.join(source, "one.txt")
      another_file = Path.join(source, "two.txt")
      destination_file = Path.join(destination, "one.txt") |> Path.absname()

      # In manual testing, macOS batched filesystem events without a manual delay.
      File.write!(source_file, "New content")
      Process.sleep(250)
      File.write!(source_file, "New content plus")
      Process.sleep(250)
      File.write!(another_file, "Something else")
      File.write!(source_file, "New content plus plus")
      assert_file_contents(destination_file, "New content plus plus", 5_000)

      Process.sleep(1_000)
      {:messages, messages} = :erlang.process_info(self(), :messages)

      assert Enum.count(messages, fn message ->
               match?({:file_event, _pid, {^destination_file, _events}}, message)
             end) == 1
    end
  end
end
