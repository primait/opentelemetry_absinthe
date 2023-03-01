defmodule OpentelemetryAbsintheTest.Instrumentation do
  use OpentelemetryAbsintheTest.Case

  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries
  alias OpentelemetryAbsintheTest.Support.Query

  @capture_all [
    trace_request_query: true,
    trace_request_variables: true,
    trace_response_result: true,
    trace_response_errors: true,
    trace_request_selections: true
  ]

  describe "query" do
    test "doesn't crash when empty" do
      OpentelemetryAbsinthe.Instrumentation.setup(@capture_all)
      attrs = Query.query_for_attrs(Queries.empty_query())

      assert [
               "graphql.request.query",
               "graphql.request.selections",
               "graphql.request.variables",
               "graphql.response.errors",
               "graphql.response.result"
             ] = attrs |> Map.keys() |> Enum.sort()
    end
  end

  test "handles multiple queries properly" do
    OpentelemetryAbsinthe.Instrumentation.setup(@capture_all)
    attrs = Query.query_for_attrs(Queries.batch_queries(), variables: %{"isbn" => "A1"}, operation_name: "OperationOne")

    assert [
             "graphql.request.query",
             "graphql.request.selections",
             "graphql.request.variables",
             "graphql.response.errors",
             "graphql.response.result"
           ] = attrs |> Map.keys() |> Enum.sort()
  end
end
