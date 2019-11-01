defmodule Excaffolder.MixProject do
  use Mix.Project

  def project do
    [
      app: :excaffolder,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
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
      {:phoenix, "~> 1.4.10"},
      {:ex_doc, "~> 0.18", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp description do
    """
    Library for generating code for phoenix live view adding tailwind.css and animate.css.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Pedro Carvalho"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/pcarvsilva/excaffolder"}
    ]
  end

end
