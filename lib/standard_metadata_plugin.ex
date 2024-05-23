defmodule OpenTelemetryAbsinthe.StandardMetadataPlugin do
  @moduledoc """
    An implementation of `OpenTelemetryAbsinthe.MetadataPlugin` behaviour that
    returns standard metadata:
    ```
      operation_name
      operation_type
      schema
      errors
      status
    ```

  """
  @behaviour OpenTelemetryAbsinthe.MetadataPlugin

  alias Absinthe.Blueprint

  @impl OpenTelemetryAbsinthe.MetadataPlugin
  def metadata(%Blueprint{} = blueprint) do
    operation_type = get_operation_type(blueprint)
    operation_name = get_operation_name(blueprint)

    errors = blueprint.result[:errors]
    status = status(errors)

    %{
      operation_name: operation_name,
      operation_type: operation_type,
      schema: blueprint.schema,
      errors: errors,
      status: status
    }
  end

  defp status(nil), do: :ok
  defp status([]), do: :ok
  defp status(_error), do: :error

  @spec get_operation_type(Absinthe.Blueprint.t()) :: any()
  def get_operation_type(%Blueprint{} = blueprint) do
    blueprint |> Absinthe.Blueprint.current_operation() |> Kernel.||(%{}) |> Map.get(:type)
  end

  @spec get_operation_name(Absinthe.Blueprint.t()) :: any()
  def get_operation_name(%Blueprint{} = blueprint) do
    blueprint |> Absinthe.Blueprint.current_operation() |> Kernel.||(%{}) |> Map.get(:name)
  end
end
