defmodule JsonApiClient.Request do
  @moduledoc """
  Describes a JSON API HTTP Request
  """
  alias __MODULE__
  alias JsonApiClient.Resource

  @type http_methods :: :get | :post | :update | :delete | :put | :head | :options | :connect | :trace | :patch

  @type t :: %__MODULE__{
          base_url: String.t() | nil,
          params: map | nil,
          id: binary | nil,
          resource: Resource.t() | nil,
          method: http_methods,
          headers: map,
          options: map,
          service_name: atom | nil,
          attributes: map
        }

  defstruct(
    base_url: nil,
    params: %{},
    id: nil,
    resource: nil,
    method: :get,
    headers: %{},
    options: %{},
    service_name: nil,
    attributes: %{}
  )

  @type name :: atom | String.t()

  @doc "Create a request"
  @spec new() :: Request.t()
  def new do
    %__MODULE__{}
  end

  @doc "Create a request with the given base URL"
  @spec new(base_url :: String.t()) :: Request.t()
  def new(base_url) do
    %__MODULE__{base_url: base_url}
  end

  @doc "Add an id to the request."
  @spec id(req :: Request.t(), id :: binary) :: Request.t()
  def id(%Request{} = req, id), do: %Request{req | id: id}

  @doc "Specify the HTTP method for the request."
  @spec method(req :: Request.t(), method :: atom) :: Request.t()
  def method(%Request{} = req, method), do: %Request{req | method: method}

  @doc "Associate a resource with this request"
  @spec resource(req :: Request.t(), resource :: Resource.t()) :: Request.t()
  def resource(%Request{} = req, resource), do: %Request{req | resource: resource}

  @doc "Associate a service_name with this request"
  @spec service_name(req :: Request.t(), service_name :: atom) :: Request.t()
  def service_name(%Request{} = req, service_name) when is_atom(service_name) do
    %Request{req | service_name: service_name}
  end

  @doc "Associate a path with this request"
  @spec path(req :: Request.t(), Resource.t() | name) :: Request.t()
  def path(%Request{} = req, %{type: _, id: _} = res), do: %Request{req | base_url: get_url(resource(req, res))}
  def path(%Request{} = req, path), do: %Request{req | base_url: join_url_parts([req.base_url, String.trim(path, "/")])}

  @doc """
  Specify which fields to include

  Takes a request and the fields you want to include as a keyword list where
  the keys are types and the values are a comma separated string or a list of
  field names.

      fields(%Request{}, user: ~(name, email), comment: ~(body))
      fields(%Request{}, user: "name,email", comment: "body")
  """
  @spec fields(req :: Request.t(), fields_to_add :: [{atom, name | [name]}]) :: any
  def fields(%Request{} = req, fields_to_add) do
    current_fields = req.params[:fields] || %{}
    new_fields = Enum.into(fields_to_add, current_fields)
    params(%Request{} = req, fields: new_fields)
  end

  @doc """
  Add a a header to the request.".

      header(%Request{}, "X-My-Header", "My header value")
  """
  @spec header(req :: Request.t(), header_name :: name, header_value :: String.t()) :: Request.t()
  def header(%Request{} = req, header_name, header_value),
    do: %Request{req | headers: Map.put(req.headers, header_name, header_value)}

  defp encode_fields(%{fields: %{} = fields} = params) do
    encoded_fields =
      fields
      |> Enum.map(fn
        {k, v} when is_list(v) -> {k, Enum.join(v, ",")}
        {k, v} -> {k, v}
      end)
      |> Enum.into(%{})

    Map.put(params, :fields, encoded_fields)
  end

  defp encode_fields(params), do: params

  @doc """
  Specify which relationships to include

  Takes a request and the relationships you want to include.
  Relationships can be expressed as a string or a list of
  relationship strings.

      include(%Request{}, "coments.author")
      include(%Request{}, ["author", "comments.author"])
  """
  @spec include(req :: Request.t(), [name] | name) :: Request.t()
  def include(%Request{} = req, relationship_list)
      when is_list(relationship_list) do
    existing_relationships = req.params[:include] || []
    params(req, include: existing_relationships ++ relationship_list)
  end

  def include(%Request{} = req, relationships)
      when is_binary(relationships) or is_atom(relationships) do
    include(req, [relationships])
  end

  defp encode_include(%{include: include} = params) when is_list(include) do
    encoded_include =
      include
      |> List.flatten()
      |> Enum.join(",")

    Map.put(params, :include, encoded_include)
  end

  defp encode_include(include), do: include

  @doc "Specify the sort param for the request."
  @spec sort(req :: Request.t(), sort :: param_value) :: Request.t()
  def sort(%Request{} = req, sort), do: params(req, sort: sort)
  @doc "Specify the page param for the request."
  @spec page(req :: Request.t(), page :: param_value) :: Request.t()
  def page(%Request{} = req, page), do: params(req, page: page)
  @doc "Specify the filter param for the request."
  @spec filter(req :: Request.t(), filter :: param_value) :: Request.t()
  def filter(%Request{} = req, filter), do: params(req, filter: filter)

  @doc ~S"""
  Add query params to the request.

  Will add to existing params when called multiple times with different keys,
  but individual parameters will be overwritten. Supports nested attributes.

      iex> req = new("http://api.net") |> params(a: "foo", b: "bar")
      iex> req |> get_query_params |> URI.encode_query
      "a=foo&b=bar"

      iex> req = new("http://api.net")   \
      ...> |> params(a: "foo", b: "bar") \
      ...> |> params(a: "new", c: "baz")
      iex> req |> get_query_params |> URI.encode_query
      "a=new&b=bar&c=baz"
  """
  @type param_value :: atom | binary | number | param_enum | list
  @type param_enum :: [{name, param_value}] | %{optional(name) => param_value}
  @spec params(req :: Request.t(), list :: param_enum) :: Request.t()
  def params(%Request{} = req, list) do
    Enum.reduce(list, req, fn {param, val}, acc ->
      new_params = Map.put(acc.params, param, val)
      %Request{acc | params: new_params}
    end)
  end

  @doc ~S"""
  Get the url for the request

  The URL returned does not include the query string

  ## Examples

      iex> new("http://api.net") |> id("123") |> get_url
      "http://api.net/123"
      iex> post = %JsonApiClient.Resource{type: "posts", id: "123"}
      iex> new("http://api.net") |> resource(post) |> get_url
      "http://api.net/posts/123"
  """
  @spec get_url(Request.t()) :: String.t()
  def get_url(%Request{base_url: base_url, id: id}) when not is_nil(id),
    do: [base_url, id] |> join_url_parts |> normalize_url

  def get_url(%Request{base_url: base_url, resource: %{type: type}, method: :post}),
    do: [base_url, type] |> join_url_parts |> normalize_url

  def get_url(%Request{base_url: base_url, resource: %{type: type, id: id}}),
    do: [base_url, type, id] |> join_url_parts |> normalize_url

  def get_url(%Request{base_url: base_url}), do: base_url |> normalize_url

  defp normalize_url(url) do
    set_default_path = &%{&1 | path: &1.path || "/"}

    url
    |> URI.parse()
    |> set_default_path.()
    |> to_string
  end

  defp join_url_parts(parts) do
    parts
    |> Enum.reject(&is_nil/1)
    |> Enum.join("/")
  end

  @doc """
  Get the query parameters for the request

  Retruns an Enumerable suitable for passing to `URI.encode_query`.

  The "params" stored in the Request struct are represented as nested hashed and arrays. This function flattens out the hashes and converts the values for attributes that take lists like `incldues` and `fields` and converts them to the comma separated strings that JSON API expects.

  ## Examples

      iex> req = new("http://api.net")
      iex> req |> fields(type1: [:a, :b, :c]) |> get_query_params
      [{"fields[type1]", "a,b,c"}]
      iex> req |> params(a: %{b: %{c: "foo"}}) |> get_query_params
      [{"a[b][c]", "foo"}]
  """
  @spec get_query_params(Request.t()) :: [{binary, binary}]
  def get_query_params(%Request{params: params}) when params != %{} do
    params
    |> encode_fields
    |> encode_include
    |> UriQuery.params()
  end

  def get_query_params(%Request{} = _req), do: []

  @doc """
  Retruns the HTTP body of the request
  """
  @spec get_body(Request.t()) :: String.t()
  def get_body(%Request{method: method, resource: resource})
      when method in [:post, :patch, :put] and not is_nil(resource) do
    Poison.encode!(%{data: resource})
  end

  def get_body(%Request{} = _req), do: ""
end
