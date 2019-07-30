defmodule JISHOCALLER do
  @moduledoc """
  Wrapper for the Jisho API found on https://jisho.org/
  Search for a word both in Japanese and English and return the result.
  You can search by:
    - word
    - tag(s)
  """

  @doc """
  Search by a word or a term. Returns a JSON result from the call.

  #Parameters:
    - Word or term: "String"

  #Result:
    - A list of Maps where each map is a word that has been found.
    - If successful then {:ok, data} is returned where data is a list of maps or it returns {:ok, "No data"} if there is nothing in the result.
    - If unsuccessful this will return {:error, reason}

  #Examples:
  Searching using an English word:

      iex> JISHOCALLER.search("dog")

  Searching using a term:

      iex> JISHOCALLER.search("fast car")

  Search using Romanji:

      iex> JISHOCALLER.search("hanako")

  Searching using Kana:

      iex> JISHOCALLER.search("にほん")

  Searching using Kanji:

      iex> JISHOCALLER.search("招き猫")

  """
  def search(word) do
    url_for(word)
    |> recieve_result
  end

  @doc """
  Search by a word or a term with tags. Returns a JSON result from the call.

  #Parameters:
    - Word or term : "String"
    - List of Strings ["String", "String" . . .]

  #Result:
    - A list of Maps where each map is a word that has been found using the tag(s).
    - If successful then {:ok, data} is returned where data is a list of maps or it returns {:ok, "No data"} if there is nothing in the result.
    - If unsuccessful this will return {:error, reason}

  #Examples:
  No tags (This is the same as just using search):

      iex> JISHOCALLER.search("dog", [])

  Using only tags:

      iex> JISHOCALLER.search("", ["jlpt-n5"])

  Using a term and a tag:

      iex> JISHOCALLER.search("animal", ["jlpt-n5"])

  Using multiple tags:

      iex> JISHOCALLER.search("出来る", ["jlpt-n5", "verb"])
  """

  def search(word, tags) do
    tags = merge_tags(tags) |> URI.encode_www_form
    url_for(word) <> tags
    |> recieve_result
  end

  @doc """
  Search by a word or a term with tags and a page. Returns a JSON result from the call.

  #Parameters:
    - Word or term : "String"
    - List of Strings ["String", "String" . . .]
    - Page Number: Integer

  #Result:
    - A list of Maps where each map is a word that has been found using the word, tag(s), and page number.
    - If successful then {:ok, data} is returned where data is a list of maps or it returns {:ok, "No data"} if there is nothing in the result.
    - If unsuccessful this will return {:error, reason}

  #Examples:
  A term, no tags, and a page:

      iex> JISHOCALLER.search("差す", [], 1)

  Using only tags and page:

      iex> JISHOCALLER.search("", ["jlpt-n5"], 30)

  Using a term, a tag and a page:

      iex> JISHOCALLER.search("差す", ["verb"], 2)

  Using a term, multiple tags and a page:

      iex> JISHOCALLER.search("出来る", ["jlpt-n5", "verb"], 1)
  """

  def search(word, tags, page) when is_integer(page) and page > 0 do
    tags = merge_tags(tags) |> URI.encode_www_form
    url_for(word) <> tags <> "&page=#{page}"
    |> recieve_result
  end

  @doc """
  Search using tags. Returns a JSON result from the call.

  #Parameters:
    - List of Strings ["String", "String" . . .]

  #Result:
    - A list of Maps where each map is a word that has been found using the tag(s).
    - If successful then {:ok, data} is returned where data is a list of maps or it returns {:ok, "No data"} if there is nothing in the result.
    - If unsuccessful this will return {:error, reason}

  #Examples:
  One tag:

      iex> JISHOCALLER.search_by_tags(["jlpt-n5"])

  Multiple tags:

      iex> JISHOCALLER.search_by_tags(["jlpt-n5", "verb"])
  """

  def search_by_tags(tags) do
    merged = merge_tags(tags) |> URI.encode_www_form
    url_for("") <> merged
    |> recieve_result
  end

  @doc """
  Search using tags and a page. Returns a JSON result from the call.

  #Parameters:
    - List of Strings ["String", "String" . . .]
    - Page Number: Integer

  #Result:
    - A list of Maps where each map is a word that has been found using the tag(s).
    - If successful then {:ok, data} is returned where data is a list of maps or it returns {:ok, "No data"} if there is nothing in the result.
    - If unsuccessful this will return {:error, reason}

  #Examples:
  One tag and page number:

      iex> JISHOCALLER.search_by_tags(["jlpt-n5"], 1)

  Multiple tags and page number:

      iex> JISHOCALLER.search_by_tags(["jlpt-n5", "verb"], 3)
  """

  def search_by_tags(tags, page) when is_integer(page) and page > 0 do
    merged = merge_tags(tags) |> URI.encode_www_form
    url_for("") <> merged <> "&page=#{page}"
    |> recieve_result
  end

  defp recieve_result(result) do
    HTTPoison.get(result, [timeout: 10_000, recv_timeout: 10_000])
    |> parse_json
  end

  defp merge_tags([]), do: ""

  defp merge_tags(tags) do
    Stream.map(tags, &(check_string(&1)))
    |> Stream.map(&(String.trim(&1)))
    |> Stream.map(&(add_hashcode(&1)))
    |> Enum.reduce(fn x, acc -> acc <> x end)
  end

  defp check_string(tag) when is_binary(tag), do: tag

  defp check_string(_), do: ""

  defp add_hashcode(""), do: ""

  defp add_hashcode(tag), do: " ##{tag}"

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
    {:error, "meta status code not 200"}
  end

  defp checkEmptyData([]) do
    {:ok, "No data"}
  end

  defp checkEmptyData(data) do
    {:ok, data}
  end

end
