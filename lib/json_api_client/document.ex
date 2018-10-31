defmodule JsonApiClient.Links do
  @moduledoc """
  JSON API JSON Links
  http://jsonapi.org/format/#document-links
  """
  @type t :: %__MODULE__{
    self: any,
    related: any,
    first: any,
    prev: any,
    next: any,
    last: any
  }
  defstruct(
    self: nil,
    related: nil,
    first: nil,
    prev: nil,
    next: nil,
    last: nil
  )
end

defmodule JsonApiClient.ErrorLink do
  @moduledoc """
  JSON API JSON Error Object
  http://jsonapi.org/format/#errors
  """
  @type t :: %__MODULE__{
    about: any
  }
  defstruct about: nil
end

defmodule JsonApiClient.ErrorSource do
  @moduledoc """
  JSON API JSON Error Object
  http://jsonapi.org/format/#errors
  """

  @type t :: %__MODULE__{
    pointer: any,
    parameter: any
  }
  defstruct pointer: nil, parameter: nil
end

defmodule JsonApiClient.Error do
  @moduledoc """
  JSON API JSON Error Object
  http://jsonapi.org/format/#errors
  """
  @type t :: %__MODULE__{
    id: any,
    links: JsonApiClient.ErrorLink.t() | nil,
    status: any,
    code: any,
    title: any,
    detail: any,
    meta: map | nil,
    source: JsonApiClient.ErrorSource.t() | nil
  }
  defstruct(
    id: nil,
    links: nil,
    status: nil,
    code: nil,
    title: nil,
    detail: nil,
    meta: nil,
    source: nil
  )
end

defmodule JsonApiClient.ResourceIdentifier do
  @moduledoc """
  JSON API Resource Identifier Object
  http://jsonapi.org/format/#document-resource-identifier-objects
  """
  @type t :: %__MODULE__{
    id: any,
    type: any,
    meta: map | nil
  }
  defstruct id: nil, type: nil, meta: nil
end

defmodule JsonApiClient.Relationship do
  @moduledoc """
  JSON API Relationships Object
  http://jsonapi.org/format/#document-resource-object-relationships
  """
  @type t :: %__MODULE__{
    links: JsonApiClient.Links.t() | nil,
    meta: map | nil,
    data: [JsonApiClient.ResourceIdentifier.t()] | JsonApiClient.ResourceIdentifier.t() | nil
  }
  defstruct links: nil, meta: nil, data: nil
end

defmodule JsonApiClient.Resource do
  @moduledoc """
  JSON API Resource Object
  http://jsonapi.org/format/#document-resource-objects
  """
  @type t :: %__MODULE__{
    id: any,
    type: any,
    attributes: map | nil,
    links: JsonApiClient.Links.t() | nil,
    relationships: %{optional(String.t() | atom()) => JsonApiClient.Relationship.t()} | %{},
    meta: map | nil
  }
  defstruct(
    id: nil,
    type: nil,
    attributes: nil,
    links: nil,
    relationships: %{},
    meta: nil
  )
end

defmodule JsonApiClient.JsonApi do
  @moduledoc """
  JSON API JSON API Object
  http://jsonapi.org/format/#document-jsonapi-object
  """
  @type t :: %__MODULE__{
    version: String.t(),
    meta: map | nil
  }
  defstruct version: "1.0", meta: %{}
end

defmodule JsonApiClient.Document do
  @moduledoc """
  JSON API Document Object
  http://jsonapi.org/format/#document-structure
  """
  @type t :: %__MODULE__{
    jsonapi: JsonApiClient.JsonApi.t(),
    data: [JsonApiClient.ResourceIdentifier.t()] | JsonApiClient.ResourceIdentifier.t() | nil,
    links: JsonApiClient.Links.t() | nil,
    meta: map | nil,
    included: [JsonApiClient.ResourceIdentifier.t()],
    errors: [JsonApiClient.Error.t()]
  }
  defstruct(
    jsonapi: nil,
    data: nil,
    links: nil,
    meta: nil,
    included: nil,
    errors: nil
  )
end
