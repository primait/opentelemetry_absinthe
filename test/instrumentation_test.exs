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

  @aliased_query """
  query($isbn: String!) {
    alias: book(isbn: $isbn) {
      title
    }
  }
  """

  @empty_query """
  query {
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
               "graphql.request.selections",
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
               "graphql.request.selections",
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
               "graphql.request.selections",
               "graphql.request.variables",
               "graphql.response.errors"
             ] = attributes |> keys() |> Enum.sort()
    end

    test "request selections correctly extracted" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_response_result: false
      )

      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_query: true)
      {:ok, _} = Absinthe.run(@query, Schema, variables: %{"isbn" => "A1"})
      assert_receive {:span, span(attributes: {_, _, _, _, attributes})}, 5000

      selections = Jason.decode!(attributes["graphql.request.selections"])

      refute Enum.member?(selections, "books")

      # technically, this test also confirms the above, but it's nice to call out the intent.
      assert ["book"] = selections
    end

    test "aliased request selections extracted as their un-aliased name" do
      Application.put_env(:opentelemetry_absinthe, :trace_options,
        trace_request_query: false,
        trace_response_result: false
      )

      OpentelemetryAbsinthe.Instrumentation.setup(trace_request_query: true)
      {:ok, _} = Absinthe.run(@aliased_query, Schema, variables: %{"isbn" => "A1"})
      assert_receive {:span, span(attributes: {_, _, _, _, attributes})}, 5000

      selections = Jason.decode!(attributes["graphql.request.selections"])

      assert ["book"] = selections
    end

    test "empty query doesn't crash" do
      OpentelemetryAbsinthe.Instrumentation.setup()
      {:ok, _} = Absinthe.run(@empty_query, Schema)
      assert_receive {:span, span(attributes: attributes)}, 5000

      assert [
               "graphql.request.query",
               "graphql.request.selections",
               "graphql.request.variables",
               "graphql.response.errors",
               "graphql.response.result"
             ] = attributes |> keys() |> Enum.sort()
    end
  end

  defp keys(attributes_record), do: attributes_record |> elem(4) |> Map.keys()
end
