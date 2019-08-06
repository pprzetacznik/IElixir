defmodule IElixir.Mixfile do
  use Mix.Project

  @version "0.9.18"

  def project do
    [app: :ielixir,
     version: @version,
     source_url: "https://github.com/pprzetacznik/IElixir",
     name: "IElixir",
     elixir: ">= 1.5.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     consolidate_protocols: false,
     deps: deps(),
     description: """
     Jupyter's kernel for Elixir programming language
     """,
     package: package(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [
       "coveralls": :test,
       "coveralls.detail": :test,
       "coveralls.post": :test,
       "coveralls.html": :test
     ]]
  end

  def application do
    [mod: {IElixir, []},
     extra_applications: [:logger, :runtime_tools, :logger, :iex, :ecto, :erlzmq, :poison, :uuid]]
  end

  defp deps do
    [{:erlzmq, "~> 3.0"},
     {:poison, "~> 3.0"},
     {:uuid_erl, "~> 1.7.5", app: false},
     {:ecto_sql, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},

     #Rukh as a dependency:
     #{:rukh, path: "/home/harun/Lana-Labs/Backend/lana-backend-scala/rukh" , runtime: false},

     # Docs dependencies
     {:earmark, "~> 1.3.2", only: :docs},
     {:ex_doc, "~> 0.20", only: :docs},
     {:inch_ex, "~> 2.0", only: :docs},

     # Test dependencies
     {:excoveralls, "~> 0.8", only: :test}]
  end

  defp package do
    [files: ["config",
             "lib",
             "priv",
             "resources",
             "mix.exs",
             "README.md",
             "LICENSE",
             "install_script.sh",
             "start_script.sh",
             ".travis.yml"],
     exclude_patterns: ["resources/.ipynb_checkpoints",
                        "resources/macro.ex"],
     maintainers: ["Piotr Przetacznik"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/pprzetacznik/ielixir",
              "Docs" => "http://hexdocs.pm/ielixir/"}]
  end
end
