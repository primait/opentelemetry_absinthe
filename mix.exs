defmodule OpentelemetryAbsinthe.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_absinthe,
      version: "1.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        # Since absinthe is an optional dependency we need to tell dialyxir to include it
        plt_add_apps: [:absinthe]
      ],
      package: package(),
      aliases: aliases(),
      description: description()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:absinthe, "~> 1.7.0", optional: true},
      {:jason, "~> 1.2"},
      {:opentelemetry_api, "~> 1.1"},
      {:telemetry, "~> 0.4 or ~> 1.0.0"}
    ] ++ dev_deps()
  end

  defp dev_deps do
    [
      {:opentelemetry, "~> 1.1", only: :test},
      {:opentelemetry_exporter, "~> 1.1", only: :test},
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
