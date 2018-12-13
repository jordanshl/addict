use Mix.Config

config :addict, ecto_repos: [TestAddictRepo]

config :addict, TestAddictRepo,
  username: "postgres",
  password: "postgres",
  database: "addict_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
