defmodule JsonApiClient.Mixfile do
  use Mix.Project

  def project do
    [
      app: :json_api_client,
      version: "3.0.3",
      elixir: "~> 1.5",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "JsonApiClient",
      description: description(),
      package: package(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        ci: :test,
        "coveralls.html": :test,
        "coveralls.post": :test,
        coveralls: :test
      ],
      deps: deps(),
      docs: docs(),
      source_url: "https://github.com/Decisiv/json_api_client",
      dialyzer: [plt_add_deps: :transitive,
                 # We are using Mix.Config.persist, etc. in tests
                 plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.7.2", only: [:dev, :test]},
      {:ex_doc, "~>0.16.3", only: :dev},
      {:httpoison, "~> 0.13.0"},
      {:poison, "~> 3.1"},
      {:mock, "~> 0.3.0", only: :test, runtime: false},
      {:bypass, "~> 0.8", only: :test},
      {:uuid, "~> 1.1", only: :test},
      {:exjsx, "~> 4.0.0"},
      {:uri_query, "~> 0.1.1"},
      {:deep_merge, "~> 0.1.0"},
      {:fuse, "~> 2.4", optional: true}
    ]
  end

  def docs do
    [
      main: "readme",
      source_url: "https://github.com/Decisiv/json_api_client",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: [
        "Chan Park",
        "Cloves Carneiro",
        "George Murphy",
        "Michael Lagutko",
        "Trevor Little"
      ],
      links: %{
        "Github" => "https://github.com/Decisiv/json_api_client"
      }
    ]
  end

  defp description do
    """
      Client package for accessing JSONApi services
    """
  end

  defp aliases do
    [
      ci: ["compile", "credo --strict", "coveralls.html --raise"]
    ]
  end
end
