defmodule OpenTelemetryAbsinthe.MetadataPlugin do
  @moduledoc """
    A MetadataPlugin is used to allow library integrators to add their own
    metadata to the broadcasted telemetry events.

    Note: plugins are run after `OpenTelemetryAbsinthe.MetadataPlugin.StandardMetadata`
    so they should avoid the keys:
    ```
      operation_name
      operation_type
      schema
      errors
      status
    ```
  """
  alias Absinthe.Blueprint

  @type metadata :: %{
          atom() => any()
        }

  @callback metadata(Blueprint.t()) :: metadata()
end
