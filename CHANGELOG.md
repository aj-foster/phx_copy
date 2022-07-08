# Changelog

### v0.1.1 (2022-07-07)

* **Add**: Run multiple profiles at once in `Phoenix.Copy.run/1`, `Phoenix.Copy.watch/1`, and `mix phx.copy`.
* **Fix**: Support single-file source and destination paths.

## v0.1.0 (2022-03-24)

* **Fix**: Use default latency of 500ms for watcher on macOS to reduce double-copies

### v0.1.0-rc.2 (2022-03-24)

* **Add**: Add some basic tests
* **Fix**: Removing a file no longer causes an error

### v0.1.0-rc.1 (2022-03-23)

* **Add**: Perform an initial copy when watcher starts

### v0.1.0-rc.0 (2022-03-22)

* Initial release
* **Add**: `mix phx.copy` task
* **Add**: `Phoenix.Copy.watch/1` with Phoenix Endpoint watcher compatibility
