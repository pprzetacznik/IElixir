defmodule IElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ielixir,
      version: read_version(),
      source_url: "https://github.com/pprzetacznik/IElixir",
      name: "IElixir",
      elixir: ">= 1.20.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: false,
      deps: deps(),
      description: """
      Jupyter's kernel for Elixir programming language
      """,
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.github": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      mod: {IElixir, []},
      applications: [:logger, :iex, :ecto, :ecto_sql, :ecto_sqlite3, :erlzmq, :jason, :uuid, :floki]
    ]
  end

  defp deps do
    [
      {:erlzmq, "~> 3.0"},
      {:floki, "~> 0.38.5"},
      {:jason, "~> 1.4"},
      {:uuid, "~> 1.7.5", [hex: "uuid_erl", repo: "hexpm"]},
      {:ecto, "~> 3.14"},
      {:ecto_sql, "~> 3.14"},
      {:ecto_sqlite3, "~> 0.26"},
      {:exqlite, "~> 0.40"},

      # Docs dependencies
      {:ex_doc, "~> 0.40", only: :docs, runtime: false},
      {:inch_ex, "~> 2.1.0", only: :docs},

      # Test dependencies
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp package do
    [
      files: [
        "config",
        "lib",
        "priv",
        "resources",
        "mix.exs",
        "README.md",
        "LICENSE",
        "install_script.sh",
        "start_script.sh",
        ".travis.yml"
      ],
      exclude_patterns: ["resources/.ipynb_checkpoints", "resources/macro.ex"],
      maintainers: ["Piotr Przetacznik"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/pprzetacznik/ielixir",
        "Docs" => "http://hexdocs.pm/ielixir/"
      }
    ]
  end

  def read_version() do
    "VERSION"
    |> File.read!
    |> String.trim
  end
end
