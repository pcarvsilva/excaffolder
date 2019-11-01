defmodule Mix.Tasks.Excaffolder.Gen.Html do
  @shortdoc "Generates controller, views, and context for an HTML resource"

  @moduledoc """
  Generates controller, views, and context for an HTML resource.

      mix excaffolder.gen.html Accounts User users name:string age:integer

  The first argument is the context module followed by the schema module
  and its plural name (used as the schema table name).

  The context is an Elixir module that serves as an API boundary for
  the given resource. A context often holds many related resources.
  Therefore, if the context already exists, it will be augmented with
  functions for the given resource.

  > Note: A resource may also be split
  > over distinct contexts (such as `Accounts.User` and `Payments.User`).

  The schema is responsible for mapping the database fields into an
  Elixir struct.

  Overall, this generator will add the following files to `lib/`:

    * a context module in `lib/app/accounts/accounts.ex` for the accounts API
    * a schema in `lib/app/accounts/user.ex`, with an `users` table
    * a view in `lib/app_web/views/user_view.ex`
    * a controller in `lib/app_web/controllers/user_controller.ex`
    * live view CRUD templates using tailwind css and animate css in `lib/app_web/templates/user`
    * live view `lib/app_web/live/user/`

  A migration file for the repository and test files for the context and
  controller features will also be generated.

  The location of the web files (controllers, views, templates, etc) in an
  umbrella application will vary based on the `:context_app` config located
  in your applications `:generators` configuration. When set, the Phoenix
  generators will generate web files directly in your lib and test folders
  since the application is assumed to be isolated to web specific functionality.
  If `:context_app` is not set, the generators will place web related lib
  and test files in a `web/` directory since the application is assumed
  to be handling both web and domain specific functionality.
  Example configuration:

      config :my_app_web, :generators, context_app: :my_app

  Alternatively, the `--context-app` option may be supplied to the generator:

      mix excaffolder.gen.html Sales User users --context-app warehouse

  ## Web namespace

  By default, the controller and view will be namespaced by the schema name.
  You can customize the web module namespace by passing the `--web` flag with a
  module name, for example:

      mix excaffolder.gen.html Sales User users --web Sales

  Which would generate a `lib/app_web/controllers/sales/user_controller.ex` and
  `lib/app_web/views/sales/user_view.ex`.

  ## Generating without a schema or context file

  In some cases, you may wish to bootstrap HTML templates, controllers, and
  controller tests, but leave internal implementation of the context or schema
  to yourself. You can use the `--no-context` and `--no-schema` flags for
  file generation control.

  ## table

  By default, the table name for the migration and schema will be
  the plural name provided for the resource. To customize this value,
  a `--table` option may be provided. For example:

      mix excaffolder.gen.html Accounts User users --table cms_users

  ## binary_id

  Generated migration can use `binary_id` for schema's primary key
  and its references with option `--binary-id`.

  ## Default options

  This generator uses default options provided in the `:generators`
  configuration of your application. These are the defaults:

      config :your_app, :generators,
        migration: true,
        binary_id: false,
        sample_binary_id: "11111111-1111-1111-1111-111111111111"

  You can override those options per invocation by providing corresponding
  switches, e.g. `--no-binary-id` to use normal ids despite the default
  configuration or `--migration` to force generation of the migration.

  Read the documentation for `excaffolder.gen.schema` for more information on
  attributes.
  """
  use Mix.Task

  alias Mix.Phoenix.{Context, Schema}
  alias Mix.Tasks.Excaffolder.Gen

  @doc false
  def run(args) do
    if Mix.Project.umbrella? do
      Mix.raise "mix excaffolder.gen.html can only be run inside an application directory"
    end

    {context, schema} = Mix.Tasks.Excaffolder.Gen.Context.build(args)
    Mix.Tasks.Excaffolder.Gen.Context.prompt_for_code_injection(context)

    binding = [context: context, schema: schema, inputs: inputs(schema)]
    paths = Mix.Phoenix.generator_paths()

    prompt_for_conflicts(context)

    context
    |> copy_new_files(paths, binding)
    |> print_shell_instructions()
  end

  defp prompt_for_conflicts(context) do
    context
    |> files_to_be_generated()
    |> Kernel.++(context_files(context))
    |> Mix.Phoenix.prompt_for_conflicts()
  end
  defp context_files(%Context{generate?: true} = context) do
    Mix.Tasks.Excaffolder.Gen.Context.files_to_be_generated(context)
  end
  defp context_files(%Context{generate?: false}) do
    []
  end

  @doc false
  def files_to_be_generated(%Context{schema: schema, context_app: context_app}) do
    web_prefix = Mix.Phoenix.web_path(context_app)
    test_prefix = Mix.Phoenix.web_test_path(context_app)
    web_path = to_string(schema.web_path)

    [
      {:eex, "controller.ex",       Path.join([web_prefix, "controllers" , web_path, "#{schema.singular}_controller.ex"])},
      {:eex, "edit.html.eex",       Path.join([web_prefix, "templates"   , web_path, schema.singular, "edit.html.leex"])},
      {:eex, "form.html.eex",       Path.join([web_prefix, "templates"   , web_path, schema.singular, "form.html.eex"])},
      {:eex, "index.html.eex",      Path.join([web_prefix, "templates"   , web_path, schema.singular, "index.html.leex"])},
      {:eex, "new.html.eex",        Path.join([web_prefix, "templates"   , web_path, schema.singular, "new.html.leex"])},
      {:eex, "show.html.eex",       Path.join([web_prefix, "templates"   , web_path, schema.singular, "show.html.leex"])},
      {:eex, "view.ex",             Path.join([web_prefix, "views"       , web_path, "#{schema.singular}_view.ex"])},
      {:eex, "index.ex",        Path.join([web_prefix, "live"        , web_path, schema.singular, "index.ex"])},
      {:eex, "new.ex",        Path.join([web_prefix, "live"        , web_path, schema.singular, "new.ex"])},
      {:eex, "show.ex",       Path.join([web_prefix, "live"        , web_path, schema.singular, "show.ex"])},
      {:eex, "controller_test.exs", Path.join([test_prefix, "controllers", web_path, "#{schema.singular}_controller_test.exs"])},
    ]
  end

  @doc false
  def copy_new_files(%Context{} = context, paths, binding) do
    files = files_to_be_generated(context)
    Mix.Phoenix.copy_from(paths, "../excaffolder/priv/templates/excaffolder.gen.html", binding, files)
    if context.generate?, do: Mix.Tasks.Excaffolder.Gen.Context.copy_new_files(context, paths, binding)
    context
  end

  @doc false
  def print_shell_instructions(%Context{schema: schema, context_app: ctx_app} = context) do
    if schema.web_namespace do
      Mix.shell.info """

      Add the resource to your #{schema.web_namespace} :browser scope in #{Mix.Phoenix.web_path(ctx_app)}/router.ex:

          scope "/#{schema.web_path}", #{inspect Module.concat(context.web_module, schema.web_namespace)}, as: :#{schema.web_path} do
            pipe_through :browser
            ...
            resources "/#{schema.plural}", #{inspect schema.alias}Controller
          end
      """
    else
      Mix.shell.info """

      Add the resource to your browser scope in #{Mix.Phoenix.web_path(ctx_app)}/router.ex:

          resources "/#{schema.plural}", #{inspect schema.alias}Controller
      """
    end
    if context.generate?, do: Mix.Tasks.Excaffolder.Gen.Context.print_shell_instructions(context)
  end

  defp inputs(%Schema{} = schema) do
    Enum.map(schema.attrs, fn
      {_, {:references, _}} ->
        {nil, nil, nil}
      {key, :integer} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, %>), error(key)}
      {key, :float} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, step: "any" %>), error(key)}
      {key, :decimal} ->
        {label(key), ~s(<%= number_input f, #{inspect(key)}, step: "any" %>), error(key)}
      {key, :boolean} ->
        {label(key), ~s(<%= checkbox f, #{inspect(key)} %>), error(key)}
      {key, :text} ->
        {label(key), ~s(<%= textarea f, #{inspect(key)} %>), error(key)}
      {key, :date} ->
        {label(key), ~s(<%= date_select f, #{inspect(key)} %>), error(key)}
      {key, :time} ->
        {label(key), ~s(<%= time_select f, #{inspect(key)} %>), error(key)}
      {key, :utc_datetime} ->
        {label(key), ~s(<%= datetime_select f, #{inspect(key)} %>), error(key)}
      {key, :naive_datetime} ->
        {label(key), ~s(<%= datetime_select f, #{inspect(key)} %>), error(key)}
      {key, {:array, :integer}} ->
        {label(key), ~s(<%= multiple_select f, #{inspect(key)}, ["1": 1, "2": 2] %>), error(key)}
      {key, {:array, _}} ->
        {label(key), ~s(<%= multiple_select f, #{inspect(key)}, ["Option 1": "option1", "Option 2": "option2"] %>), error(key)}
      {key, _}  ->
        {label(key), ~s(<%= text_input f, #{inspect(key)} %>), error(key)}
    end)
  end

  defp label(key) do
    ~s(<%= label f, #{inspect(key)},class: "shadow appearance-none border rounded w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" %>)
  end

  defp error(field) do
    ~s(<%= error_tag f, #{inspect(field)},class: "text-red-500 text-xs italic" %>)
  end
end
