defmodule Bentoo.PageContent do
  def get_document(url) do
    with {:ok, uri} <- URI.new(url),
         {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(uri),
         {:ok, document} <- Floki.parse_document(body) do
      document
    else
      error -> error
    end
  end

  def get_text_from_document(document, html_tags) do
    document
    |> Floki.find(build_query_string(html_tags))
    |> Enum.map(&get_content_from_node/1)
    |> Enum.uniq()
  end

  def get_content_from_node(node) do
    tag = elem(node, 0)

    case Enum.member?(~w[header main nav footer section article aside], tag) do
      true -> {tag, Floki.attribute(node, "class")}
      false -> {tag, Floki.text(node, deep: false)}
    end
  end

  def build_query_string(html_tags) do
    html_tags
    |> expand_html_tags()
    |> MapSet.to_list()
    |> Enum.join(", ")
  end

  defp expand_html_tags(%{
         block_elements_selected: block_elements,
         single_elements_selected: single_elements
       }) do
    case MapSet.size(block_elements) == 0 do
      true ->
        single_elements

      false ->
        Enum.reduce(block_elements, block_elements, fn block_element, acc ->
          Enum.reduce(single_elements, acc, fn single_element, acc ->
            MapSet.put(acc, "#{block_element} #{single_element}")
          end)
        end)
    end
  end
end
