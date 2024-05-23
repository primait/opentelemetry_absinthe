defmodule OpenTelemetryAbsinthe.StandardMetadataPluginTest do
  use ExUnit.Case

  alias OpenTelemetryAbsinthe.StandardMetadataPlugin

  test "should include operation name" do
    assert %{operation_name: "FindByUUID"} =
             [operations: [BlueprintArchitect.operation(name: "FindByUUID")]]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end

  test "should include operation type" do
    assert %{operation_type: :mutation} =
             [operations: [BlueprintArchitect.operation(type: :mutation)]]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end

  test "should include schema" do
    assert %{schema: __MODULE__} =
             [schema: __MODULE__]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end

  test "should include nil errors" do
    assert %{errors: nil} =
             [result: %{}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()

    assert %{errors: nil} =
             [result: %{errors: nil}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end

  test "should include empty errors" do
    assert %{errors: []} =
             [result: %{errors: []}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end

  test "should include errors" do
    assert %{errors: [:stuff_went_wrong, :wrong_number]} =
             [result: %{errors: [:stuff_went_wrong, :wrong_number]}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end

  test "should include ok status" do
    assert %{status: :ok} =
             [result: %{}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()

    assert %{status: :ok} =
             [result: %{errors: nil}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()

    assert %{status: :ok} =
             [result: %{errors: []}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end

  test "should include error status when there are errors" do
    assert %{status: :error} =
             [result: %{errors: [:stuff_went_wrong, :wrong_number]}]
             |> BlueprintArchitect.blueprint()
             |> StandardMetadataPlugin.metadata()
  end
end
