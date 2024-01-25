defmodule BentooWeb.SeekerLive do
  alias Bentoo.PageContent
  alias Bentoo.Seeker
  alias Bentoo.Seeker.URL

  use BentooWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(content: PageContent.get_content("https://schaken.nl/"))
     |> assign_url()
     |> clear_form()}
  end

  def assign_url(socket) do
    socket
    |> assign(:url, %URL{})
  end

  def clear_form(socket) do
    form =
      socket.assigns.url
      |> Seeker.change_url()
      |> to_form()

    assign(socket, form: form)
  end

  def handle_event(
        "select_html_tags",
        _params,
        socket
      ) do
    Logger.debug("Html tags received")

    {:noreply, socket}
  end

  def handle_event(
        "validate",
        %{"url" => url_params},
        %{assigns: %{url: url}} = socket
      ) do
    changeset =
      url
      |> Seeker.change_url(url_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"url" => url_params}, socket) do
    {:noreply,
     socket
     |> assign(content: PageContent.get_content(url_params["url"]))
     |> assign_url()
     |> clear_form()}
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def block_element?(e) do
    tag = elem(e, 0)

    Enum.member?(~w[section aside article], tag)
  end
end
