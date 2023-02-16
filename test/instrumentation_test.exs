defmodule OpentelemetryAbsintheTest.Instrumentation do
  use ExUnit.Case
  alias AbsinthePlug.Test.Schema
  require Record

  doctest OpentelemetryAbsinthe.Instrumentation

  for {name, spec} <- Record.extract_all(from_lib: "opentelemetry/include/otel_span.hrl") do
    Record.defrecord(name, spec)
  end

  @query """
  query($isbn: String!) {
    book(isbn: $isbn) {
      title
      author {
        name
        age
      }
    }
  }
  """

  setup do
    Application.delete_env(:opentelemetry_absinthe, :trace_options)
    OpentelemetryAbsinthe.Instrumentation.teardown()
    :otel_batch_processor.set_exporter(:otel_exporter_pid, self())
  end

  describe "trace configuration" do
    test "by default all graphql stuff is recorded in attributes" do
      OpentelemetryAbsinthe.Instrumentation.setup()
      {:ok, _} = Absinthe.run(@query, Schema, variables: %{"isbn" => "A1"})
      assert_receive {:span, span(attributes: attributes)}, 5000

      assert [
               "graphql.request.query",
               "graphql.request.variables",
               "graphql.response.errors",
               "graphql.response.result"
             ] = attributes |> keys() |> Enum.sort()
    end

    test "options provided via application env have precedence over defaults" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_response_result: false
      )

      OpentelemetryAbsinthe.Instrumentation.setup()
      {:ok, _} = Absinthe.run(@query, Schema, variables: %{"isbn" => "A1"})
      assert_receive {:span, span(attributes: attributes)}, 5000

      assert [
               "graphql.request.variables",
               "graphql.response.errors"
             ] = attributes |> keys() |> Enum.sort()
    end

    test "options provided to setup() have precedence over defaults and application env" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_response_result: false
      )

      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_query: true)
      {:ok, _} = Absinthe.run(@query, Schema, variables: %{"isbn" => "A1"})
      assert_receive {:span, span(attributes: attributes)}, 5000

      assert [
               "graphql.request.query",
               "graphql.request.variables",
               "graphql.response.errors"
             ] = attributes |> keys() |> Enum.sort()
    end

    test "additional attributes are included in spans" do
      additional_attributes = [env: "test"]
      OpentelemetryAbsinthe.Instrumentation.setup(additional_attributes: additional_attributes)

      {:ok, _} = Absinthe.run(@query, Schema, variables: %{"isbn" => "A1"})
      assert_receive {:span, span(attributes: attributes)}, 5000

      assert [
               :env,
               "graphql.request.query",
               "graphql.request.variables",
               "graphql.response.errors",
               "graphql.response.result"
             ] = attributes |> keys() |> Enum.sort()

      assert elem(attributes, 4)[:env] == "test"
    end
  end

  defp keys(attributes_record), do: attributes_record |> elem(4) |> Map.keys()
end
