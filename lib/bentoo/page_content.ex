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

  def get_text(document) do
    document
    |> Floki.find("h1, h2, h3, p")
    |> Enum.map(&Floki.text(&1))
    |> Enum.map(&String.trim/1)
    |> Enum.uniq()
  end
end
