defmodule UeberauthWorkosAuthkit.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/workos/ueberauth_workos_authkit"

  def project do
    [
      app: :ueberauth_workos_authkit,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Ueberauth WorkOS AuthKit",
      description: description(),
      source_url: @source_url,
      package: package(),
      docs: [extras: ["README.md", "LICENSE"], source_ref: @version]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ueberauth, "~> 0.10"},
      {:workos, "~> 1.1"},
      {:oauth2, "~> 2.0"},
      {:jose, "~> 1.11"},

      {:mock, "~> 0.3", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
    ]
  end

  defp description do
    "Implementation of an Ueberauth Strategy for WorkOS Single Sign-On with managed users."
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "WorkOS" => "https://workos.com",
      },
    ]
  end
end
