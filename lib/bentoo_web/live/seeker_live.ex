defmodule BentooWeb.SeekerLive do
  alias Bentoo.PageContent
  alias Bentoo.Seeker
  alias Bentoo.Seeker.URL

  use BentooWeb, :live_view
  require Logger

  @html_tags %{
    block_elements: MapSet.new(["section"]),
    single_elements: MapSet.new(["h2"])
  }

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       content: PageContent.get_content("https://nos.nl/", @html_tags),
       html_tags: @html_tags
     )
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
    html_tags = socket.assigns.html_tags

    {:noreply,
     socket
     |> assign(content: PageContent.get_content(url_params["url"], html_tags))
     |> assign_url()
     |> clear_form()}
  end

  def handle_event("update_html_tags", %{"html_tag" => tag}, socket) do
    html_tags = socket.assigns.html_tags

    updated_html_tags =
      case block_element?(tag) do
        true -> update_block_elements(html_tags, tag)
        false -> update_single_elements(html_tags, tag)
      end

    {:noreply, assign(socket, html_tags: updated_html_tags)}
  end

  def update_block_elements(html_tags, tag) do
    case MapSet.member?(html_tags.block_elements, tag) do
      true -> update_in(html_tags.block_elements, &MapSet.delete(&1, tag))
      false -> update_in(html_tags.block_elements, &MapSet.put(&1, tag))
    end
  end

  def update_single_elements(html_tags, tag) do
    case MapSet.member?(html_tags.single_elements, tag) do
      true -> update_in(html_tags.single_elements, &MapSet.delete(&1, tag))
      false -> update_in(html_tags.single_elements, &MapSet.put(&1, tag))
    end
  end

  def block_element?(tag) do
    Enum.member?(~w[section aside article], tag)
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def html_tags_to_string(%{
        block_elements: block_elements,
        single_elements: single_elements
      }) do
    combined_html_tags =
      Enum.reduce(block_elements, block_elements, fn block_element, acc ->
        Enum.reduce(single_elements, acc, fn single_element, acc ->
          MapSet.put(acc, "#{block_element} #{single_element}")
        end)
      end)

    combined_html_tags
    |> MapSet.to_list()
    |> Enum.join(", ")
  end
end
