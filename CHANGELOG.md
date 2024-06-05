# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### v0.1.4 (2024-06-05)

* **Add**: Relax constraints to allow version `1.0` of dependency `filesystem` (thanks [@nshafer](https://github.com/nshafer))

### v0.1.3 (2023-02-26)

* **Add**: Automatically dereference symlinks during copy (requires Elixir 1.14) (thanks [@derek-zhou](https://github.com/derek-zhou))
* **Fix**: Choose the correct destination for files with nested watchers with Elixir before 1.12
* **Fix**: Tests requiring multiple file watchers for the same directory failed on Linux
* **Fix**: CI did not work due to lack of `inotify-tools`
* **Fix**: CI now tests against Elixir 1.10 / OTP 21 as well as later versions

### v0.1.2 (2022-12-21)

* **Add**: Profiles can include a `debounce` option to avoid duplicate copy events (thanks [@kuon](https://github.com/kuon))

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
