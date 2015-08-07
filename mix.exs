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
     deps: deps]
  end

  def application do
    [mod: {IElixir, []},
     applications: [:logger, :iex]]
  end

  defp deps do
    [{:erlzmq, github: "zeromq/erlzmq2"},
     {:poison, github: "devinus/poison"},
     {:uuid, github: "okeuday/uuid"},

     # Docs dependencies
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end
end
