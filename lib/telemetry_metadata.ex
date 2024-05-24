defmodule OpenTelemetryAbsinthe.TelemetryMetadata do
  @moduledoc """
    A helper module to allow integrators to add custom data to their context
    which will then be added to the [:opentelemetry_absinthe, :graphql, :handled]
    event
  """
  @key __MODULE__

  @type absinthe_context :: map()
  @type telemetry_metadata :: %{
          optional(atom()) => any()
        }

  @spec put_telemetry_metadata(absinthe_context(), telemetry_metadata()) :: absinthe_context()
  def put_telemetry_metadata(%{} = context, %{} = metadata),
    do: Map.update(context, @key, metadata, &Map.merge(&1, metadata))

  @spec get_telemetry_metadata(absinthe_context()) :: telemetry_metadata()
  def get_telemetry_metadata(%{} = context), do: Map.get(context, @key, %{})
end
