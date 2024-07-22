defmodule UeberauthWorkosAuthkit.MixProject do
  use Mix.Project

  def project do
    [
      app: :ueberauth_workos_authkit,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/jumpwire-ai/ueberauth_workos_authkit",
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
      # Switch to upstream workos library once this PR is merged:
      # https://github.com/workos/workos-elixir/pull/60
      {:workos, github: "jumpwire-ai/workos-elixir"},
      {:oauth2, "~> 2.0"},
      {:jose, "~> 1.11"},

      {:mock, "~> 0.3", only: :test},
    ]
  end
end
