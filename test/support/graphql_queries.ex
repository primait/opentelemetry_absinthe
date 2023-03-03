defmodule OpentelemetryAbsintheTest.Support.GraphQL.Queries do
  @moduledoc false
  def query do
    """
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
  end

  def aliased_query do
    """
    query($isbn: String!) {
      alias: book(isbn: $isbn) {
        title
      }
    }
    """
  end

  def empty_query do
    """
    query {
    }
    """
  end
end
