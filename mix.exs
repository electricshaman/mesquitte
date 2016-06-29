defmodule Mesquitte.Mixfile do
  use Mix.Project

  def project do
    [app: :mesquitte,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: {Mesquitte, []}]
  end

  defp deps do
    [
      {:ranch, "~> 1.2"}
    ]
  end
end
