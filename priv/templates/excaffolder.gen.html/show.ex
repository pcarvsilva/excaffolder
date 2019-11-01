defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias)%>Live.Show do
  use Phoenix.LiveView
  alias <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias)%>View

 def render(assigns) do
  <%= inspect Module.concat(schema.web_namespace, schema.alias)%>View.render("show.html", assigns)
 end

 def mount(session, socket) do
   {:ok, assign(socket, <%= schema.singular %>: session.<%= schema.singular %>)}
 end

 def handle_event("close-modal",value, socket) do
  send(socket.parent_pid, {"close-modal", value})
  {:noreply, socket}
end


end
