defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.New do
  use Phoenix.LiveView
  alias <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias)%>View
  alias <%= inspect context.module %>

  def render(assigns) do
    <%= inspect Module.concat(schema.web_namespace, schema.alias)%>View.render("new.html", assigns)
  end

  def handle_event("close-modal",value, socket) do
    send(socket.parent_pid, {"close-modal", value})
    {:noreply, socket}
  end

  def handle_event("validate", %{"<%= schema.singular %>" => params}, socket) do
    params = Map.put(params,"user_id",socket.assigns.current_user)
    |> Map.put("action", :insert)

    changeset = <%= inspect context.module %>.<%= schema.human_singular %>.changeset(%<%= inspect context.module %>.<%= schema.human_singular %>{},params)

    {:noreply, assign(socket,
                      changeset: %{changeset | action: :insert}
                      )}
  end

  def handle_event("save",value, socket) do
    <%= inspect context.module %>.create_<%= schema.singular %>(socket.assigns.changeset.changes)
    send(socket.parent_pid, {"close_modal", value})
    {:stop,socket}
  end

  def mount(session, socket) do
    {:ok, assign(socket,
                changeset: session.changeset,
                csrf_token: session.csrf_token,
                current_user: session.current_user
                )}
  end

end
