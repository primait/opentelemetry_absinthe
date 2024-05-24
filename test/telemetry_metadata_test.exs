defmodule OpenTelemetryAbsinthe.TelemetryMetadataTest do
  use ExUnit.Case

  alias OpenTelemetryAbsinthe.TelemetryMetadata

  test "should return an empty metadata when context is empty" do
    assert %{} == TelemetryMetadata.get_telemetry_metadata(%{})
  end

  test "should return an empty metadata when context does not contain metadata" do
    assert %{} == TelemetryMetadata.get_telemetry_metadata(%{foo: :bar})
  end

  test "should return same metadata that was stored" do
    assert %{user_agent: :test} ==
             %{}
             |> TelemetryMetadata.put_telemetry_metadata(%{user_agent: :test})
             |> TelemetryMetadata.get_telemetry_metadata()
  end
end
