defmodule OpentelemetryAbsintheTest.InstrumentationTest do
  use OpentelemetryAbsintheTest.Case

  alias OpentelemetryAbsinthe.Instrumentation
  alias OpentelemetryAbsintheTest.Support.GraphQL.Queries
  alias OpentelemetryAbsintheTest.Support.Query

  @capture_all [
    trace_request_query: true,
    trace_request_variables: true,
    trace_response_result: true,
    trace_response_errors: true,
    trace_request_selections: true
  ]

  @trace_attributes [
    :"graphql.document",
    :"graphql.event.type",
    :"graphql.operation.name",
    :"graphql.operation.type",
    :"graphql.request.selections",
    :"graphql.request.variables",
    :"graphql.response.errors",
    :"graphql.response.result"
  ]

  test "doesn't crash when query is empty" do
    OpentelemetryAbsinthe.Instrumentation.setup(@capture_all)
    attrs = Query.query_for_attrs(Queries.empty_query())

    assert @trace_attributes = attrs |> Map.keys() |> Enum.sort()
  end

  test "handles multiple queries properly" do
    OpentelemetryAbsinthe.Instrumentation.setup(@capture_all)
    attrs = Query.query_for_attrs(Queries.batch_queries(), variables: %{"isbn" => "A1"}, operation_name: "OperationOne")

    assert @trace_attributes = attrs |> Map.keys() |> Enum.sort()
  end

  describe "metadata plugins" do
    setup do
      config =
        Instrumentation.default_config()
        |> Keyword.put(:type, :operation)
        |> Enum.into(%{})

      %{config: config}
    end

    test "standard values are returned when no plugins specified", ctx do
      assert :ok =
               :telemetry.attach(
                 ctx.test,
                 [:opentelemetry_absinthe, :graphql, :handled],
                 fn _telemetry_event, _measurements, metadata, _config ->
                   send(self(), metadata)
                 end,
                 nil
               )

      assert :ok =
               Instrumentation.handle_stop(
                 "Test",
                 %{},
                 %{blueprint: BlueprintArchitect.blueprint(schema: __MODULE__)},
                 ctx.config
               )

      assert_receive %{
                       operation_name: "TestOperation",
                       operation_type: :query,
                       schema: __MODULE__,
                       errors: nil,
                       status: :ok
                     },
                     10
    end

    test "standard values are returned alongside those from plugins", ctx do
      assert :ok =
               :telemetry.attach(
                 ctx.test,
                 [:opentelemetry_absinthe, :graphql, :handled],
                 fn _telemetry_event, _measurements, metadata, _config ->
                   send(self(), metadata)
                 end,
                 nil
               )

      assert :ok =
               Instrumentation.handle_stop(
                 "Test",
                 %{},
                 %{blueprint: BlueprintArchitect.blueprint(schema: __MODULE__, source: "TestSource")},
                 Map.put(ctx.config, :metadata_plugins, [__MODULE__.TestMetadataPlugin])
               )

      assert_receive %{
                       operation_name: "TestOperation",
                       operation_type: :query,
                       schema: __MODULE__,
                       errors: nil,
                       status: :ok,
                       plugin_name: __MODULE__.TestMetadataPlugin,
                       source: "TestSource"
                     },
                     10
    end
  end
end

defmodule OpentelemetryAbsintheTest.InstrumentationTest.TestMetadataPlugin do
  @behaviour OpenTelemetryAbsinthe.MetadataPlugin

  alias Absinthe.Blueprint

  def metadata(%Blueprint{} = blueprint) do
    %{
      plugin_name: __MODULE__,
      source: blueprint.source
    }
  end
end
