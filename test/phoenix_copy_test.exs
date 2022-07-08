defmodule Phoenix.CopyTests do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog
  import Phoenix.Copy.Assertions
  import Phoenix.Copy.Setup

  alias Phoenix.Copy

  setup :create_directories

  describe "config_for!/1" do
    test "retrieves configuration for the given profile",
         %{source: source, destination: destination} do
      assert Copy.config_for!(:default) == [
               source: source,
               destination: destination
             ]
    end

    test "raises for unconfigured profile" do
      assert_raise ArgumentError, fn ->
        Copy.config_for!(:unknown)
      end
    end
  end

  describe "run/1" do
    test "copies files from source to destination", %{destination: destination} do
      assert File.ls!(destination) == []

      copied =
        Copy.run(:default)
        |> MapSet.new()

      expected =
        MapSet.new([
          destination,
          Path.join(destination, "a.txt"),
          Path.join(destination, "b"),
          Path.join(destination, "b/c.txt"),
          Path.join(destination, "e"),
          Path.join(destination, "e/f.txt")
        ])

      assert MapSet.equal?(copied, expected)
    end

    test "overwrites files in the destination", %{destination: destination} do
      assert File.ls!(destination) == []
      Copy.run(:default)

      copied =
        Copy.run(:default)
        |> MapSet.new()

      expected =
        MapSet.new([
          destination,
          Path.join(destination, "a.txt"),
          Path.join(destination, "b"),
          Path.join(destination, "b/c.txt"),
          Path.join(destination, "e"),
          Path.join(destination, "e/f.txt")
        ])

      assert MapSet.equal?(copied, expected)
    end

    test "copies files from multiple profiles", %{
      destination: destination,
      sub_destination: sub_destination
    } do
      assert File.ls!(destination) == []

      copied =
        Copy.run([:default, :sub])
        |> MapSet.new()

      expected =
        MapSet.new([
          destination,
          Path.join(destination, "a.txt"),
          Path.join(destination, "b"),
          Path.join(destination, "b/c.txt"),
          Path.join(destination, "e"),
          Path.join(destination, "e/f.txt"),
          sub_destination,
          Path.join(sub_destination, "c.txt")
        ])

      assert MapSet.equal?(copied, expected)
    end
  end

  describe "watch/1" do
    test "immediately copies files", %{destination: destination} do
      assert File.ls!(destination) == []

      watcher =
        Task.async(fn ->
          capture_log(fn ->
            Copy.watch(:default)
          end)
        end)

      assert_file_exists(Path.join(destination, "a.txt"))

      Task.shutdown(watcher)
    end

    test "copies files from multiple profiles", %{
      destination: destination,
      sub_destination: sub_destination
    } do
      assert File.ls!(destination) == []

      watcher =
        Task.async(fn ->
          capture_log(fn ->
            Copy.watch([:default, :sub])
          end)
        end)

      assert_file_exists(Path.join(sub_destination, "c.txt"))

      Task.shutdown(watcher)
    end
  end
end
