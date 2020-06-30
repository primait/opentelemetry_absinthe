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

  def handle_operation_start(event_name, _measurements, %{
        options: %{params: %{"query" => query, "variables" => variables}}
      }, _) do
    attributes = [
      {"graphql.query", query},
      {"graphql.variables", variables}
    ]

    OpenTelemetry.Tracer.start_span("graphql", %{attributes: attributes})
    :ok
  end

  def handle_operation_start(_, _, _, _), do: :ok

  def handle_operation_stop(event_name, _measurements, data, _) do
    OpenTelemetry.Span.set_attribute("graphql.errors", inspect(data.blueprint.errors))
    OpenTelemetry.Span.set_attribute("graphql.response", inspect(data.blueprint.result))
    OpenTelemetry.Tracer.end_span()
    :ok
  end
end
