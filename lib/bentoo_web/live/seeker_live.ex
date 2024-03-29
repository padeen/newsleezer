defmodule BentooWeb.SeekerLive do
  alias Bentoo.PageContent
  alias Bentoo.Seeker
  alias Bentoo.Seeker.URL

  use BentooWeb, :live_view

  @html_tags %{
    block_elements_all: MapSet.new(~w[header main nav footer section aside article]),
    block_elements_selected: MapSet.new(["section"]),
    single_elements_all: MapSet.new(~w[h1 h2 h3 p a]),
    single_elements_selected: MapSet.new(["h2"])
  }

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       content: [],
       document: "",
       html_tags: @html_tags,
       url: %URL{url: ""}
     )
     |> clear_form()}
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
    url = url_params["url"]

    case url == socket.assigns.url do
      true ->
        {:noreply,
         assign(socket,
           content: PageContent.get_text_from_document(socket.assigns.document, html_tags)
         )}

      false ->
        document = PageContent.get_document(url)

        {:noreply,
         assign(socket,
           document: document,
           content: PageContent.get_text_from_document(document, html_tags),
           url: url
         )}
    end
  end

  def handle_event("update-url", %{"url" => url_params}, socket) do
    changeset =
      %URL{}
      |> Seeker.change_url(%{url: url_params})
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("block-elements-select-all", _params, socket) do
    block_elements_all = socket.assigns.html_tags.block_elements_all
    block_elements_selected = socket.assigns.html_tags.block_elements_selected

    updated_html_tags =
      case MapSet.equal?(block_elements_all, block_elements_selected) do
        true -> %{socket.assigns.html_tags | block_elements_selected: MapSet.new()}
        false -> %{socket.assigns.html_tags | block_elements_selected: block_elements_all}
      end

    {:noreply, assign(socket, html_tags: updated_html_tags)}
  end

  def handle_event("single-elements-select-all", _params, socket) do
    single_elements_all = socket.assigns.html_tags.single_elements_all
    single_elements_selected = socket.assigns.html_tags.single_elements_selected

    updated_html_tags =
      case MapSet.equal?(single_elements_all, single_elements_selected) do
        true -> %{socket.assigns.html_tags | single_elements_selected: MapSet.new()}
        false -> %{socket.assigns.html_tags | single_elements_selected: single_elements_all}
      end

    {:noreply, assign(socket, html_tags: updated_html_tags)}
  end

  def handle_event("update_block_elements", %{"html_tag" => tag}, socket) do
    html_tags = socket.assigns.html_tags

    updated_html_tags =
      case MapSet.member?(html_tags.block_elements_selected, tag) do
        true -> update_in(html_tags.block_elements_selected, &MapSet.delete(&1, tag))
        false -> update_in(html_tags.block_elements_selected, &MapSet.put(&1, tag))
      end

    {:noreply, assign(socket, html_tags: updated_html_tags)}
  end

  def handle_event("update_single_elements", %{"html_tag" => tag}, socket) do
    html_tags = socket.assigns.html_tags

    updated_html_tags =
      case MapSet.member?(html_tags.single_elements_selected, tag) do
        true -> update_in(html_tags.single_elements_selected, &MapSet.delete(&1, tag))
        false -> update_in(html_tags.single_elements_selected, &MapSet.put(&1, tag))
      end

    {:noreply, assign(socket, html_tags: updated_html_tags)}
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def tag_selected?(
        :block_element,
        %{block_elements_selected: block_elements} = _html_tags,
        html_tag
      ) do
    case Enum.member?(block_elements, html_tag) do
      true -> "bg-purple-900 hover:bg-purple-900 hover:brightness-75"
      false -> "bg-purple-500 hover:bg-purple-500 hover:brightness-75"
    end
  end

  def tag_selected?(
        :single_element,
        %{single_elements_selected: single_elements} = _html_tags,
        html_tag
      ) do
    case Enum.member?(single_elements, html_tag) do
      true -> "bg-purple-900 hover:bg-purple-900 hover:brightness-75"
      false -> "bg-purple-500 hover:bg-purple-500 hover:brightness-75"
    end
  end

  def block_elements_selected_all?(
        %{
          block_elements_selected: block_elements_selected,
          block_elements_all: block_elements_all
        } = _html_tags
      ) do
    case MapSet.equal?(block_elements_selected, block_elements_all) do
      true -> "bg-purple-900 hover:bg-purple-900 hover:brightness-75"
      false -> "bg-purple-500 hover:bg-purple-500 hover:brightness-75"
    end
  end

  def single_elements_selected_all?(
        %{
          single_elements_selected: single_elements_selected,
          single_elements_all: single_elements_all
        } = _html_tags
      ) do
    case MapSet.equal?(single_elements_selected, single_elements_all) do
      true -> "bg-purple-900 hover:bg-purple-900 hover:brightness-75"
      false -> "bg-purple-500 hover:bg-purple-500 hover:brightness-75"
    end
  end

  def class_from_node(node) do
    Floki.attribute(node, "class")
  end

  def text_from_node(node) do
    Floki.text(node, deep: false)
  end

  def tag_from_node(node) do
    elem(node, 0)
  end

  defdelegate build_query_string(html_tags), to: PageContent
end
