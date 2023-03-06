defmodule OpentelemetryAbsintheTest.Instrumentation do
  use OpentelemetryAbsintheTest.Case

  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries
  alias OpentelemetryAbsintheTest.Support.Query

  describe "query" do
    test "doesn't crash when empty" do
      OpentelemetryAbsinthe.Instrumentation.setup()
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
    OpentelemetryAbsinthe.Instrumentation.setup()
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
