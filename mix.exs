defmodule OpentelemetryAbsinthe.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_absinthe,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, ">= 1.4.0"},
      {:jason, "~> 1.2"},
      {:opentelemetry_api, "~> 0.3.1"},
    ]
  end
end
