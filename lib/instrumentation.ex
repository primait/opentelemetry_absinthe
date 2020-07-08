defmodule OpentelemetryAbsinthe.Instrumentation do
  @moduledoc """
  Module for automatic instrumentation of Absinthe resolution.

  It works by listening to [:absinthe, :execute, :operation, :start/:stop] telemetry events,
  which are emitted by Absinthe only since v1.5; therefore it won't work on previous versions.

  (you can still call `OpentelemetryAbsinthe.Instrumentation.setup()` in your application startup
  code, it just won't do anything.)
  """

  require OpenTelemetry.Tracer
  require OpenTelemetry.Span

  @default_config [
    span_name: "absinthe graphql resolution",
    trace_request_query: true,
    trace_request_variables: true,
    trace_response_result: true,
    trace_response_errors: true
  ]

  def setup(instrumentation_opts \\ []) do
    OpenTelemetry.register_application_tracer(:opentelemetry_absinthe)

    config =
      @default_config
      |> Keyword.merge(Application.get_env(:opentelemetry_absinthe, :trace_options, []))
      |> Keyword.merge(instrumentation_opts)
      |> Enum.into(%{})

    :telemetry.attach(
      {__MODULE__, :operation_start},
      [:absinthe, :execute, :operation, :start],
      &handle_operation_start/4,
      config
    )

    :telemetry.attach(
      {__MODULE__, :operation_stop},
      [:absinthe, :execute, :operation, :stop],
      &handle_operation_stop/4,
      config
    )
  end

  def teardown() do
    :telemetry.detach({__MODULE__, :operation_start})
    :telemetry.detach({__MODULE__, :operation_stop})
  end

  def handle_operation_start(_event_name, _measurements, metadata, config) do
    params = metadata |> Map.get(:options, []) |> Keyword.get(:params, %{})

    attributes =
      []
      |> put_if(
        config.trace_request_variables,
        {"graphql.request.variables", Jason.encode!(params["variables"])}
      )
      |> put_if(config.trace_request_query, {"graphql.request.query", params["query"]})

    OpenTelemetry.Tracer.start_span(config.span_name, %{attributes: attributes})
    :ok
  end

  def handle_operation_stop(_event_name, _measurements, data, config) do
    result_attributes =
      []
      |> put_if(
        config.trace_response_result,
        {"graphql.response.result", Jason.encode!(data.blueprint.result)}
      )
      |> put_if(
        config.trace_response_errors,
        {"graphql.response.errors", Jason.encode!(data.blueprint.result[:errors])}
      )

    OpenTelemetry.Span.set_attributes(result_attributes)
    OpenTelemetry.Tracer.end_span()
    :ok
  end

  # Surprisingly, that doesn't seem to by anything in the stdlib to conditionally
  # put stuff in a list / keyword list.
  # This snippet is approved by José himself:
  # https://elixirforum.com/t/creating-list-adding-elements-on-specific-conditions/6295/4?u=learts
  defp put_if(list, false, _), do: list
  defp put_if(list, true, value), do: [value | list]
end
