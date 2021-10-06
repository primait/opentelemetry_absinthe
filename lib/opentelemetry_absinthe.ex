defmodule OpentelemetryAbsinthe do
  @moduledoc """
  OpentelemetryAbsinthe is an opentelemetry instrumentation library for Absinthe
  """

  defdelegate setup, to: OpentelemetryAbsinthe.Instrumentation
end
