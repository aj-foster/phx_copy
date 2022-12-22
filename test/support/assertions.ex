defmodule Phoenix.Copy.Assertions do
  import ExUnit.Assertions

  @doc """
  Assert that the file at `path` contains `contents`.

  This will check the file every 100 milliseconds until the timeout (default 1 second).
  """
  def assert_file_contents(path, contents, timeout_ms \\ 1_000)

  def assert_file_contents(path, _contents, timeout_ms) when timeout_ms < 0 do
    assert false, "File #{path} did not have expected contents within timeout"
  end

  def assert_file_contents(path, contents, timeout_ms) do
    unless File.exists?(path) and File.read!(path) == contents do
      Process.sleep(100)
      assert_file_contents(path, contents, timeout_ms - 100)
    end
  end

  @doc """
  Assert that a file exists at the given `path`.

  This will check the file every 100 milliseconds until the timeout (default 1 second).
  """
  def assert_file_exists(path, timeout_ms \\ 1_000)

  def assert_file_exists(path, timeout_ms) when timeout_ms < 0 do
    assert false, "File #{path} did not exist within timeout"
  end

  def assert_file_exists(path, timeout_ms) do
    unless File.exists?(path) do
      Process.sleep(100)
      assert_file_exists(path, timeout_ms - 100)
    end
  end
end
