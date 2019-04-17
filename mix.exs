defmodule Edns.MixProject do
  use Mix.Project

  def project do
    [
      app: :edns,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Edns.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dnsm, path: "../dnsm"},
      {:jason, "~> 1.1"},
      {:mcc, "~> 1.2"},
      {:typed_struct, "~> 0.1.4"},
      {:poolboy, "~> 1.5"},
      {:recon, "~> 2.4"},
      {:excoveralls, "~> 0.10.6", only: [:test]}
    ]
  end
end
