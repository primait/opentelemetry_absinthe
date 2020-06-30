defmodule OpentelemetryAbsinthe.Instrumentation do

  require OpenTelemetry.Tracer
  require OpenTelemetry.Span

  def setup() do
    :telemetry.attach(
      {__MODULE__, :operation_start},
      [:absinthe, :execute, :operation, :start],
      &handle_operation_start/4,
      []
    )

    :telemetry.attach(
      {__MODULE__, :operation_stop},
      [:absinthe, :execute, :operation, :stop],
      &handle_operation_stop/4,
      []
    )
  end

  def handle_operation_start(event_name, _measurements, metadata, _) do
    params = metadata |> Map.get(:options, []) |> Keyword.get(:params, %{})

    attributes = [
      {"graphql.request.query", params["query"]},
      {"graphql.request.variables", Jason.encode!(params["variables"])}
    ]

    OpenTelemetry.Tracer.start_span("absinthe graphql resolution", %{attributes: attributes})
    :ok
  end

  def handle_operation_stop(event_name, _measurements, data, _) do
    OpenTelemetry.Span.set_attribute("graphql.response.errors", inspect(data.blueprint.errors))
    OpenTelemetry.Span.set_attribute("graphql.response.result", inspect(data.blueprint.result))
    OpenTelemetry.Tracer.end_span()
    :ok
  end
end
