defmodule BentooWeb.SeekerLive do
  alias Bentoo.PageContent
  alias Bentoo.Seeker
  alias Bentoo.Seeker.URL

  use BentooWeb, :live_view
  require Logger

  @html_tags %{
    block_elements_all: MapSet.new(~w[header main nav footer section aside article]),
    block_elements_selected: MapSet.new(["section"]),
    single_elements_all: MapSet.new(~w[h1 h2 h3 h4 h5 h6 p a]),
    single_elements_selected: MapSet.new(["h2"])
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

  def handle_event("block-elements-select-all", _params, socket) do
    block_elements_all = socket.assigns.html_tags.block_elements_all

    updated_html_tags = %{socket.assigns.html_tags | block_elements_selected: block_elements_all}

    {:noreply, assign(socket, html_tags: updated_html_tags)}
  end

  def handle_event("single-elements-select-all", _params, socket) do
    single_elements_all = socket.assigns.html_tags.single_elements_all

    updated_html_tags = %{
      socket.assigns.html_tags
      | single_elements_selected: single_elements_all
    }

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

  def block_element?(tag) do
    Enum.member?(~w[header main nav footer section aside article], tag)
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
      true -> "bg-purple-900"
      false -> "bg-purple-500"
    end
  end

  def tag_selected?(
        :single_element,
        %{single_elements_selected: single_elements} = _html_tags,
        html_tag
      ) do
    case Enum.member?(single_elements, html_tag) do
      true -> "bg-purple-900"
      false -> "bg-purple-500"
    end
  end

  def block_elements_selected_all?(
        %{
          block_elements_selected: block_elements_selected,
          block_elements_all: block_elements_all
        } = html_tags
      ) do
    case MapSet.equal?(block_elements_selected, block_elements_all) do
      true -> "bg-purple-900"
      false -> "bg-purple-500"
    end
  end

  def single_elements_selected_all?(
        %{
          single_elements_selected: single_elements_selected,
          single_elements_all: single_elements_all
        } = html_tags
      ) do
    case MapSet.equal?(single_elements_selected, single_elements_all) do
      true -> "bg-purple-900"
      false -> "bg-purple-500"
    end
  end

  defdelegate build_query_string(html_tags), to: PageContent
end
