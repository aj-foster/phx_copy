if System.get_env("CI") do
  ExUnit.configure(formatters: [ExUnit.CLIFormatter, JUnitFormatter])
end

ExUnit.after_suite(fn _results ->
  Path.expand("../tmp", __DIR__)
  |> File.rm_rf!()
end)

ExUnit.start()
