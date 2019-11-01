defmodule <%= inspect context.module %> do
  @moduledoc """
  The <%= context.name %> context.
  """

  import Ecto.Query, warn: false
  alias <%= inspect schema.repo %>

  @topic inspect(__MODULE__)


  @doc """
  Subscribes for receiving notifications for modifications in this context
  """
  def subscribe do
    Phoenix.PubSub.subscribe(<%= inspect :application.get_application(__MODULE__) %>.PubSub, @topic,link: true)
  end

  @doc """
  Broadcasts a change on given context for hearing modifications in this module

    ## Use Cases

      iex> broadcast_change(<%= schema.singular %>, :created)()
      iex> broadcast_change(<%= schema.singular %>, :updated)()

  """
  defp broadcast_change({:ok, result}, event) do
    Phoenix.PubSub.broadcast(<%= inspect :application.get_application(__MODULE__) %>.PubSub, @topic, {__MODULE__, event, result})
    {:ok, result}
  end
end
