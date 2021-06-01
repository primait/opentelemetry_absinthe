defmodule OpentelemetryAbsinthe.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_absinthe,
      version: "0.3.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      aliases: aliases(),
      description: description()
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
      {:opentelemetry_api, "~> 0.6.0"},
      {:absinthe_plug, "~> 1.5", only: :test},
      {:opentelemetry, "~> 0.6.0", only: :test},
      {:plug_cowboy, "~> 2.2", only: :test},
      {:credo, "~> 1.4", only: [:dev, :test]},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      "format.all": [
        "format mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\" \"config/**/*.{ex,exs}\""
      ]
    ]
  end

  def package do
    [
      name: "opentelemetry_absinthe",
      maintainers: ["Leonardo Donelli"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/primait/opentelemetry_absinthe"}
    ]
  end

  def description do
    "OpentelemetryAbsinthe is a OpenTelemetry instrumentation library for Absinthe."
  end
end
