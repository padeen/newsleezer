defmodule Bentoo.PageContent do
  def get_content(url) do
    with {:ok, uri} <- URI.new(url),
         {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(uri),
         {:ok, document} <- Floki.parse_document(body) do
      get_text(document)
    else
      error -> error
    end
  end

  def get_content_from_node(node) do
    tag = elem(node, 0)

    case Enum.member?(~w[section article aside], tag) do
      true -> {tag, Floki.attribute(node, "class")}
      false -> {tag, Floki.text(node)}
    end
  end

  def get_text(document) do
    document
    |> Floki.find("section, section h2")
    |> Enum.map(&get_content_from_node/1)
    |> Enum.uniq()
  end
end
