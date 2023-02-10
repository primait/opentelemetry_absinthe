defmodule OpentelemetryAbsinthe.Instrumentation do
  @moduledoc """
  Module for automatic instrumentation of Absinthe resolution.

  It works by listening to [:absinthe, :execute, :operation, :start/:stop] telemetry events,
  which are emitted by Absinthe only since v1.5; therefore it won't work on previous versions.

  (you can still call `OpentelemetryAbsinthe.Instrumentation.setup()` in your application startup
  code, it just won't do anything.)
  """

  require OpenTelemetry.Tracer, as: Tracer
  require Record

  @span_ctx_fields Record.extract(:span_ctx,
                     from_lib: "opentelemetry_api/include/opentelemetry.hrl"
                   )

  Record.defrecord(:span_ctx, @span_ctx_fields)

  @default_config [
    span_name: "absinthe graphql resolution",
    trace_request_query: true,
    trace_request_variables: true,
    trace_response_result: true,
    trace_response_errors: true,
    trace_request_selections: true
  ]

  def setup(instrumentation_opts \\ []) do
    config =
      @default_config
      |> Keyword.merge(Application.get_env(:opentelemetry_absinthe, :trace_options, []))
      |> Keyword.merge(instrumentation_opts)
      |> Enum.into(%{})

    :telemetry.attach(
      {__MODULE__, :operation_start},
      [:absinthe, :execute, :operation, :start],
      &__MODULE__.handle_operation_start/4,
      config
    )

    :telemetry.attach(
      {__MODULE__, :operation_stop},
      [:absinthe, :execute, :operation, :stop],
      &__MODULE__.handle_operation_stop/4,
      config
    )
  end

  def teardown do
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

    save_parent_ctx()

    new_ctx = Tracer.start_span(config.span_name, %{attributes: attributes})

    Tracer.set_current_span(new_ctx)
  end

  def handle_operation_stop(_event_name, _measurements, data, config) do
    fields =
      case data do
        %{blueprint: %{operations: [_ | _] = operations}} ->
          operations
          |> Enum.reduce([], fn selections, list ->
            selections.selections
            |> Enum.reduce(list, fn selection, list -> [selection.name | list] end)
          end)
          |> Enum.uniq()

        _ ->
          []
      end

    errors = data.blueprint.result[:errors]

    result_attributes =
      []
      |> put_if(
        config.trace_response_result,
        {"graphql.response.result", Jason.encode!(data.blueprint.result)}
      )
      |> put_if(
        config.trace_response_errors,
        {"graphql.response.errors", Jason.encode!(errors)}
      )
      |> put_if(
        config.trace_request_selections,
        {"graphql.request.selections", Jason.encode!(fields)}
      )

    set_status(errors)

    Tracer.set_attributes(result_attributes)
    Tracer.end_span()

    restore_parent_ctx()
    :ok
  end

  # Surprisingly, that doesn't seem to by anything in the stdlib to conditionally
  # put stuff in a list / keyword list.
  # This snippet is approved by José himself:
  # https://elixirforum.com/t/creating-list-adding-elements-on-specific-conditions/6295/4?u=learts
  defp put_if(list, false, _), do: list
  defp put_if(list, true, value), do: [value | list]

  # taken from https://github.com/opentelemetry-beam/opentelemetry_plug/blob/82206fb09fbeb9ffa2f167a5f58ea943c117c003/lib/opentelemetry_plug.ex#L186
  @ctx_key {__MODULE__, :parent_ctx}
  defp save_parent_ctx do
    ctx = Tracer.current_span_ctx()
    Process.put(@ctx_key, ctx)
  end

  defp restore_parent_ctx do
    ctx = Process.get(@ctx_key, :undefined)
    Process.delete(@ctx_key)
    Tracer.set_current_span(ctx)
  end

  # set status as `:error` in case of errors in the graphql response
  defp set_status(nil), do: :ok
  defp set_status([]), do: :ok
  defp set_status(_errors), do: Tracer.set_status(OpenTelemetry.status(:error, ""))
end
