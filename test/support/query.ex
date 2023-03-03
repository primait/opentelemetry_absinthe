defmodule OpentelemetryAbsintheTest.Support.Query do
  @moduledoc false

  import ExUnit.Assertions
  alias OpentelemetryAbsintheTest.Support.GraphQL.Schema
  require Record

  @fields Record.extract(:span, from: "deps/opentelemetry/include/otel_span.hrl")
  Record.defrecordp(:span, @fields)

  def query_for_attrs(query, opts \\ []) do
    :otel_simple_processor.set_exporter(:otel_exporter_pid, self())

    {:ok, _} = Absinthe.run(query, Schema, opts)
    assert_receive {:span, span(attributes: {_, _, _, _, attributes})}, 5000
    attributes
  end
end
