defmodule JISHOCALLER.MixProject do
  use Mix.Project

  def project do
    [
      app: :jishocaller,
      version: "1.0.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
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
      {:httpoison, "~> 1.4"},
      {:json, "~> 1.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp description do
    "
    A simple wrapper for the Jisho API (Japanese Dictionary)
    "
  end

  defp package do
    [
      maintainers: ["Ilya Samoylov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/IlyaSamoylov45/jishocaller"}
    ]
  end

end
