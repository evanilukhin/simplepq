defmodule Simplepq.MixProject do
  use Mix.Project

  def project do
    [
      app: :simplepq,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: "Simple persisted queue",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],

      # Docs
      name: "Simplepq",
      source_url: "https://github.com/evanilukhin/simplepq",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
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
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/evanilukhin/simplepq"}
    ]
  end
end
