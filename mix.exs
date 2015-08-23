defmodule IElixir.Mixfile do
  use Mix.Project

  @version "0.9.0-dev"

  def project do
    [app: :ielixir,
     version: @version,
     source_url: "https://github.com/pprzetacznik/IElixir",
     name: "IElixir",
     elixir: "~> 1.1-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: """
     Jupyter's kernel for Elixir programming language
     """
   ]
  end

  def application do
    [mod: {IElixir, []},
     applications: [:logger, :iex, :sqlite_ecto, :ecto]]
  end

  defp deps do
    [{:erlzmq, github: "zeromq/erlzmq2"},
     {:poison, github: "devinus/poison", override: true},
     {:uuid, github: "okeuday/uuid"},

     {:sqlite_ecto, "~> 0.5.0"},
     {:ecto, "~> 0.15.0"},

     # Docs dependencies
     {:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.7", only: :dev}]
  end
end
