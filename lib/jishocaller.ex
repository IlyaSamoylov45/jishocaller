defmodule JISHOCALLER do
  def search(word) do
    url_for(word)
    |> recieve_result(word)
  end

  def search(word, tags) do
    tags = merge_tags(tags) |> URI.encode_www_form
    url_for(word) <> tags
    |> recieve_result(word)
  end

  defp recieve_result(result, word) do
    result = HTTPoison.get(result, [timeout: 10_000, recv_timeout: 10_000])
    |> parse_json
    case result do
      {:error, _} ->
        result
      _ ->
        %{word => result}
    end
  end

  defp merge_tags(tags) do
    Stream.map(tags, &(check_string(&1)))
    |> Stream.map(&(String.trim(&1)))
    |> Stream.map(&(add_hashcode(&1)))
    |> Enum.reduce(fn x, acc -> acc <> x end)
  end

  defp check_string(tag) when is_binary(tag) do
    tag
  end

  defp check_string(_) do
    ""
  end

  defp add_hashcode("") do
    ""
  end

  defp add_hashcode(tag) do
    " #" <> tag
  end

  defp url_for(word) do
    word = URI.encode(word)
    IO.puts(word)
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

end
