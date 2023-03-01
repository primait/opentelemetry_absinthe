defmodule OpentelemetryAbsinthe do
  alias OpentelemetryAbsinthe.Instrumentation

  # Allow alias before moduledoc
  # credo:disable-for-next-line
  @moduledoc """
  # OpentelemetryAbsinthe
  An opentelemetry instrumentation library for Absinthe

  ## Usage

  To start collecting traces just put `OpentelemetryAbsinthe.setup()` in your application start function.

  ## Configuration

  OpentelemetryAbsinthe can be configured with the application environment
  ```
  config :opentelemetry_absinthe,
    trace_request_query: false,
    trace_response_error: true
  ```
  configuration can also be passed directly to the setup function
  ```
  OpentelemetryAbsinthe.setup(
    trace_request_query: false,
    trace_response_error: true
  )
  ```

  ## Configuration options
    
    * `span_name`(default: #{Instrumentation.default_config()[:span_name]}): the name of the span attributes will be attached to
    * `trace_request_query`(default: #{Instrumentation.default_config()[:trace_request_query]}): attaches the graphql query as an attribute

      **Important Note**: This is usually safe, since graphql queries are expected to be static. All dynamic data should be passed via graphql variables. 
      However some libraries(for example [dillonkearns/elm-graphql](https://github.com/dillonkearns/elm-graphql/issues/27) stores the variables inline as a part of the query.
      If you expect clients to send dynamic data as a part of the graphql query you should disable this.

    * `trace_request_variables`(default: #{Instrumentation.default_config()[:trace_request_variables]}): attaches the graphql variables as an attribute
    * `trace_request_selections`(default: #{Instrumentation.default_config()[:trace_request_selections]}): attaches the root fields queried as an attribute.
    
      For example given a query like:
      ```
        query($isbn: String!) {
          book(isbn: $isbn) {
            title
            author {
              name
              age
            }
          }
          reader {
            name
          }
        }
      ```
      will result in a graphql.request.selections attribute with the value `["book", "reader"]` being attached.
      Note that aliased fields will use their unaliased name.

    * `trace_response_result`(default: #{Instrumentation.default_config()[:trace_request_result]}): attaches the result returned by the server as an attribute
    * `trace_response_errors`(default: #{Instrumentation.default_config()[:trace_response_errors]}): attaches the errors returned by the server as an attribute
  """

  defdelegate setup(instrumentation_opts \\ []), to: Instrumentation
end
