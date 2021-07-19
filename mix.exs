defmodule EctoI18n.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_i18n,
      version: "0.0.3",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, ">= 3.0.0", optional: true},
      {:ecto_sql, ">= 3.0.0", only: :test},
      {:postgrex, "~> 0.15.0", only: :test}
    ]
  end

  defp aliases do
    [
      test: ["ecto.drop", "ecto.create", "ecto.migrate", "test"]
    ]
  end
end
