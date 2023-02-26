defmodule OpentelemetryAbsintheTest.Configuration do
  use OpentelemetryAbsintheTest.Case

  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries
  alias OpentelemetryAbsintheTest.Support.Query

  doctest OpentelemetryAbsinthe.Instrumentation

  describe "trace configuration" do
    test "doesn't record sensitive data in attributes by default" do
      OpentelemetryAbsinthe.Instrumentation.setup()

      attributes = Query.query_for_attrs(Queries.query(), variables: %{"isbn" => "A1"})

      assert [
               "graphql.document",
               "graphql.operation.name",
               "graphql.operation.type",
               "graphql.request.selections"
             ] = attributes |> Map.keys() |> Enum.sort()
    end

    test "gives options provided via application env have precedence over defaults" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_response_result: true
      )

      OpentelemetryAbsinthe.Instrumentation.setup()
      attributes = Query.query_for_attrs(Queries.query(), variables: %{"isbn" => "A1"})

      assert [
               "graphql.operation.name",
               "graphql.operation.type",
               "graphql.request.selections",
               "graphql.response.result"
             ] = attributes |> Map.keys() |> Enum.sort()
    end

    test "gives options provided to setup() precedence over defaults and application env" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_request_selections: false
      )

      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_query: true)
      attributes = Query.query_for_attrs(Queries.query(), variables: %{"isbn" => "A1"})

      assert [
               "graphql.document",
               "graphql.operation.name",
               "graphql.operation.type"
             ] = attributes |> Map.keys() |> Enum.sort()
    end
  end
end
