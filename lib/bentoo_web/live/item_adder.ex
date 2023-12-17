defmodule BentooWeb.ItemAdder do
  use BentooWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, items: [], message: "Which one would you like to buy?")}
  end

  def render(assigns) do
    ~H"""
    <h1 class="mb-4 text-4xl font-extrabold">Current items: <%= @items %></h1>
    <h2>
      <%= @message %>
    </h2>
    <br />
    <h2>
      <%= for item <- ["Max Mara", "Louis Vuitton", "Chanel"] do %>
        <.link
          class="bg-blue-500 hover:bg-blue-700
    text-white font-bold py-2 px-4 border border-blue-700 rounded m-1"
          phx-click="add"
          phx-value-name={item}
        >
          <%= item %>
        </.link>
      <% end %>
    </h2>
    """
  end

  def handle_event("add", %{"name" => item}, socket) do
    message = "Item #{item} added to your cart."
    items = [item | socket.assigns.items]

    {
      :noreply,
      assign(
        socket,
        message: message,
        items: items
      )
    }
  end
end
