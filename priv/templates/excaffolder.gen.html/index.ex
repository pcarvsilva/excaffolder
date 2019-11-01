defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>Live.Index do
  use Phoenix.LiveView
  alias <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>View
  alias <%= inspect context.module %>

 def render(assigns) do
  <%= inspect Module.concat(schema.web_namespace, schema.alias) %>View.render("index.html", assigns)
 end

 def mount(session, socket) do
  <%= inspect context.module %>.subscribe()
   {:ok,
     assign(
       socket,
       show: false,
       changeset: nil,
       <%= schema.plural %>: <%= inspect context.module %>.list_<%= schema.plural %>(),
       new: false,
       current_user: session.current_user,
       edit: false
   )}
 end

 def handle_event("inspect",value, socket) do
   {:noreply,
     assign(
       socket,
       <%= schema.singular %>: <%= inspect context.module %>.get_<%= schema.singular %>!(value["id"]),
       show: true,
       new: false,
       edit: false
     )}
 end

 def handle_event("edit",value, socket) do
   {:noreply,
     assign(
       socket,
       changeset: <%= inspect context.module %>.change_<%= schema.singular %>(<%= inspect context.module %>.get_<%= schema.singular %>!(value["id"])),
       <%= schema.singular %>: <%= inspect context.module %>.get_<%= schema.singular %>!(value["id"]),
       show: false,
       new: false,
       edit: true
     )}
 end

 def handle_event("create",_value, socket) do
  {:noreply,
    assign(
      socket,
      changeset: <%= inspect context.module %>.change_<%= schema.singular %>(%<%= inspect context.module %>.<%= schema.human_singular %>{}),
      show: false,
      new: true,
      edit: false
    )}
end

 def handle_event("close-modal",_value, socket) do
   {:noreply,
     assign(
       socket,
       show: false,
       new: false,
       edit: false,
       changeset: nil
   )}
 end

 def handle_info({"close-modal",_value}, socket) do
  {:noreply,
    assign(
      socket,
      show: false,
      new: false,
      edit: false,
      changeset: nil
  )}
  end

 def handle_info({<%= inspect context.module %>, [:<%= schema.singular %> | _], _}, socket) do
   {:noreply,
     assign(
       socket,
       <%= schema.plural %>: <%= inspect context.module %>.list_<%= schema.plural %>()
   )}
 end


end
