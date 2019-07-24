defmodule JISHOCALLER do
  def search(word) do
    result = url_for(word)
    |> HTTPoison.get([], [timeout: 10_000, recv_timeout: 10_000])
    |> parse_json
    case result do
      {:error, _} ->
        result
      _ ->
        %{word => parse_result(result)}
    end
  end

  defp url_for(word) do
    word = URI.encode(word)
    "https://jisho.org/api/v1/search/words?keyword=#{word}"
  end

  defp parse_json({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!
    |> getData
  end

  defp parse_json({:error,  %HTTPoison.Error{id: _, reason: reason}}) do
    {:error, reason}
  end

  defp parse_json(_) do
    {:error, "parsing data"}
  end

  defp getData(json) do
    try do
      metaCheck(json["data"], json["meta"])
    rescue
      _ -> {:error, "error with getting data"}
    end
  end

  defp metaCheck(data, %{"status" => 200}) do
    checkEmptyData(data)
  end

  defp metaCheck(_data, %{"status" => _}) do
    {:error, "Status code not 200"}
  end

  defp checkEmptyData([]) do
    {:error, "No data"}
  end

  defp checkEmptyData(data) do
    data
  end

  defp parse_result(result) do
    result
  end
end
