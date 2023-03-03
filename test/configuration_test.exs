defmodule OpentelemetryAbsintheTest.Configuration do
  use OpentelemetryAbsintheTest.Case 

  alias OpentelemetryAbsintheTest.Support.Query
  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries

  doctest OpentelemetryAbsinthe.Instrumentation

  describe "trace configuration" do
    test "records all graphql stuff in attributes by default" do
      OpentelemetryAbsinthe.Instrumentation.setup()

      attributes = Query.query_for_attrs(Queries.query(), variables: %{"isbn" => "A1"})

      assert [
               "graphql.request.query",
               "graphql.request.selections",
               "graphql.request.variables",
               "graphql.response.errors",
               "graphql.response.result"
             ] = attributes |> Map.keys() |> Enum.sort()
    end

    test "gives options provided via application env have precedence over defaults" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_response_result: false
      )

      OpentelemetryAbsinthe.Instrumentation.setup()
      attributes = Query.query_for_attrs(Queries.query(), variables: %{"isbn" => "A1"})

      assert [
               "graphql.request.selections",
               "graphql.request.variables",
               "graphql.response.errors"
             ] = attributes |> Map.keys() |> Enum.sort()
    end

    test "gives options provided to setup() precedence over defaults and application env" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_response_result: false
      )

      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_query: true)
      attributes = Query.query_for_attrs(Queries.query(), variables: %{"isbn" => "A1"})

      assert [
               "graphql.request.query",
               "graphql.request.selections",
               "graphql.request.variables",
               "graphql.response.errors"
             ] = attributes |> Map.keys() |> Enum.sort()
    end
  end
end
