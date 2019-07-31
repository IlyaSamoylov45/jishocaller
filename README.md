<img src= "images/jisho.png" width="200" height="200">

# JISHOCALLER
___
### Purpose:
Simple program that wraps the Jisho word search API and returns list of search results for the given word.

### Jisho.org Description
A powerful Japanese-English dictionary. It lets you find words, kanji, example sentences and more quickly and easily. You can find it here: https://jisho.org

### JISHOCALLER Brief Description
Returns a list of maps with words that match based on words, tags and pages using Jisho API.

## Installation
___
Include jishocaller to your deps then run mix deps.get
```elixir
def deps do:
  [
    {:jishocaller, "~> 1.0.0"}
  ]
end
```

## Documentation
___
Documentation found on:
https://hexdocs.pm/jishocaller/api-reference.html

## Brief Usage
To search a word use:
```elixir
JISHOCALLER.search("dog")
```
To search a word using tags:
```elixir
JISHOCALLER.search("出来る", ["jlpt-n5", "verb"])
```
To search a word using tags and pages:
```elixir
JISHOCALLER.search("差す", ["verb"], 1)
```
To search using a tag:
```elixir
JISHOCALLER.search_by_tags(["jlpt-n5", "verb"])
```
To search using a tag and page:
```elixir
JISHOCALLER.search_by_tags(["jlpt-n5", "verb"], 3)
```
