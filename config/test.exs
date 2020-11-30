use Mix.Config

config :ecto_i18n, ecto_repos: [EctoI18n.Test.Repo]

config :ecto_i18n, EctoI18n.Test.Repo,
  priv: "test/support/priv/repo",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: "postgres",
  password: "postgres",
  database: "ecto_i18n_test",
  hostname: "localhost",
  pool_size: 5

config :ecto_i18n, repo: EctoI18n.Test.Repo
config :ecto_i18n, default_locale: "en"

config :logger, :console, level: :error
# config :logger, :console, format: "[$level] $message\n"
