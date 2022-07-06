defmodule MAX.MixProject do
  use Mix.Project

  def project do
    [
      app: :max,
      version: "0.1.0",
      elixir: "~> 1.13",
      compilers: [:elixir_make] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MAX.Application, []}
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.6.0"}
    ]
  end
end
