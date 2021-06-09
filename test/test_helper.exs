# ExUnit.start()

defmodule AbsinthePlug.Test.Schema do
  use Absinthe.Schema

  @books [
    %{isbn: "A1", title: "Fire", pages: 100, author: %{name: "Ale Ali", age: 18}},
    %{isbn: "B2", title: "Water", pages: 200, author: %{name: "Bea Boa", age: 28}},
    %{isbn: "C3", title: "Earth", pages: 300, author: %{name: "Cal Col", age: 38}},
    %{isbn: "D4", title: "Air", pages: 400, author: %{name: "Dan Don", age: 48}}
  ]

  def get_book_by_isbn(isbn) do
    Enum.find(@books, &(Map.fetch!(&1, :isbn) == isbn))
  end

  object :author do
    field(:name, :string)
    field(:age, :integer)
  end

  object :book do
    field(:isbn, :string)
    field(:title, :string)
    field(:pages, :integer)
    field(:author, :author)
  end

  query do
    field :book, :book do
      arg(:isbn, non_null(:string))
      # middleware OpentelemetryAbsinthe.Middleware
      resolve(fn _parent, args, _resolution ->
        {:ok, get_book_by_isbn(args.isbn)}
      end)
    end
  end
end

defmodule AbsinthePlug.Test.Server do
  use Plug.Builder

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Absinthe.Plug, schema: AbsinthePlug.Test.Schema)
end

:otel_batch_processor.set_exporter(:otel_exporter_pid, self())
child_spec = [{Plug.Cowboy, scheme: :http, plug: AbsinthePlug.Test.Server, options: [port: 8000]}]
{:ok, _pid} = Supervisor.start_link(child_spec, strategy: :one_for_one)

ExUnit.start()
