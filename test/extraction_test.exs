defmodule OpentelemetryAbsintheTest.Extraction do
  use OpentelemetryAbsintheTest.Case

  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries
  alias OpentelemetryAbsintheTest.Support.Query

  describe "extracts" do
    test "request selections" do
      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_selections: true)

      selections =
        Queries.query()
        |> Query.query_for_attrs(variables: %{"isbn" => "A1"})
        |> Map.fetch!("graphql.request.selections")
        |> Jason.decode!()

      assert ["book"] = selections
    end

    test "aliased request selections as their un-aliased name" do
      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_selections: true)

      selections =
        Queries.aliased_query()
        |> Query.query_for_attrs(variables: %{"isbn" => "A1"})
        |> Map.fetch!("graphql.request.selections")
        |> Jason.decode!()

      assert ["book"] = selections
    end
  end
end
