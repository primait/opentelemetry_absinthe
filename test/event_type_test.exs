defmodule OpentelemetryAbsintheTest.EvenType do
  use OpentelemetryAbsintheTest.Case

  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries
  alias OpentelemetryAbsintheTest.Support.Query

  @graphql_document :"graphql.document"
  @graphql_operation_name :"graphql.operation.name"
  @graphql_operation_type :"graphql.operation.type"
  @graphql_request_selections :"graphql.request.selections"
  @graphql_event_type :"graphql.event.type"

  doctest OpentelemetryAbsinthe.Instrumentation

  test "records operation on query" do
    OpentelemetryAbsinthe.Instrumentation.setup()

    attributes = Query.query_for_attrs(Queries.query(), variables: %{"isbn" => "A1"})

    assert @graphql_event_type in Map.keys(attributes)
    assert :operation == Map.get(attributes, @graphql_event_type)
  end

  # NOTE: a subscription test could go here, but setting up subscription testing just for this didn't seem worth it
end
