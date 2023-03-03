defmodule OpentelemetryAbsintheTest.Extraction do
  use OpentelemetryAbsintheTest.Case

  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries
  alias OpentelemetryAbsintheTest.Support.Query

  describe "extracts" do
    test "request query" do
      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_query: true)
      query = Queries.query()

      assert ^query = query |> Query.query_for_attrs() |> Map.fetch!("graphql.request.query")
    end

    test "request variables" do
      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_variables: true)
      variables = %{"isbn" => "A1", "author" => "Mara Bos"}

      assert ^variables =
               Queries.query() |> Query.query_for_attrs() |> Map.fetch!("graphql.request.variables") |> Jason.decode!()
    end

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

    test "response result" do
      OpentelemetryAbsinthe.Instrumentation.setup(trace_response_results: true)

      selections =
        Queries.query()
        |> Query.query_for_attrs(variables: %{"isbn" => "A1"})
        |> Map.fetch!("graphql.response.result")
        |> Jason.decode!()

      assert %{"data" => %{"book" => %{"author" => %{"age" => 18, "name" => "Ale Ali"}, "title" => "Fire"}}} = selections
    end
  end
end
