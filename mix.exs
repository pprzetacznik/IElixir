defmodule IElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :ielixir,
     version: "0.9.0-dev",
     source_url: "https://github.com/pprzetacznik/IElixir",
     name: "IElixir",
     elixir: "~> 1.1-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [mod: {IElixir, []},
     applications: [:logger, :iex]]
  end

  defp deps do
    [{:erlzmq, github: "zeromq/erlzmq2"},
     {:poison, github: "devinus/poison", override: true},
     {:uuid, github: "okeuday/uuid"},

     # Docs dependencies
     {:earmark, "~> 0.1", only: :docs},
     {:ex_doc, "~> 0.7", only: :docs},
     {:inch_ex, only: :docs},

     # Test dependencies
     {:excoveralls, "~> 0.3.11", only: :test}]
  end
end
