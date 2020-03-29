# Instructions
#
# Simulate the card game War https://en.wikipedia.org/wiki/War_(card_game). A
# test suite has been provided that can be run with WarTests.run().
#
# In a game of War, the deck is split evenly between two players. In each round,
# the players lay one card down. Whoever lays the highest card wins the other
# player's card, and those two cards are added to the bottom of the winners
# deck. The game normally continues until one player has all of the cards. In
# this implementation, if the game progresses for more than 10,000 rounds, it
# should end in a "Stalemate".
#
# If both players lay the same card, a round of "war" is started. Each player
# lays two additional cards facedown, and one more card faceup. Whoever lays the
# highest faceup card wins all the cards. If both players lay the same card, but
# one of them has no additional cards for the round of war, the other player
# automatically wins.

defmodule Card do
  defstruct [:suit, :rank]

  @type t :: %__MODULE__{
          suit: atom(),
          rank: atom() | pos_integer()
        }

  def value(%__MODULE__{rank: :ace}), do: 14
  def value(%__MODULE__{rank: :king}), do: 13
  def value(%__MODULE__{rank: :queen}), do: 12
  def value(%__MODULE__{rank: :jack}), do: 11
  def value(%__MODULE__{rank: rank}) when is_integer(rank), do: rank
end

defmodule Deck do
  defstruct cards: []

  @suits [:club, :diamond, :heart, :spade]
  @ranks [:ace, :king, :queen, :jack, 10, 9, 8, 7, 6, 5, 4, 3, 2]
  @cards for suit <- @suits,
             rank <- @ranks,
             do: %Card{suit: suit, rank: rank}

  @type t :: %__MODULE__{cards: [Card.t()]}

  def new do
    %__MODULE__{cards: @cards}
  end

  def shuffled do
    %__MODULE__{cards: Enum.shuffle(@cards)}
  end
end

defmodule Hand do
  defstruct cards: []

  @type t :: %__MODULE__{cards: [Card.t()]}
end

defmodule Game do
  defstruct result: "", hands: [], round: 0

  @type t :: %__MODULE__{hands: [Hand.t()], round: non_neg_integer(), result: String.t()}

  @spec new(Deck.t()) :: t()
  def new(%Deck{cards: cards}) do
    %__MODULE__{
      hands: [
        %Hand{cards: Enum.slice(cards, 0, 26)},
        %Hand{cards: Enum.slice(cards, 26, 51)}
      ]
    }
  end
end

defmodule War do
  # TODO implement this play_game/1 function to return a completed Game struct.
  # The Game's result should be "Player A wins", "Player B wins" or "Stalemate".
  # Player A & B are denoted by the order of the Hands in the Game struct.
  @spec play_game(Deck.t()) :: Game.t()
  def play_game(deck \\ Deck.shuffled()) do
    Game.new(deck)
  end
end

defmodule WarTests do
  @tests [:test_one, :test_two, :test_three, :test_four, :test_five, :test_six]

  def run do
    tests = Enum.map(@tests, fn test -> apply(__MODULE__, test, []) end)
    pass_count = Enum.count(tests, &(&1 === :passed))
    fail_count = Enum.count(tests, &(&1 === :failed))
    IO.puts("\n#{pass_count} passed, #{fail_count} failed")
  end

  def test_one do
    log("Player A wins with a stacked deck")

    stacked_deck = stack_high_cards(Deck.new())
    %Game{result: result} = War.play_game(stacked_deck)
    expected_result = "Player A wins"

    assert(expected_result, result)
  end

  def test_two do
    log("Player B wins with a stacked deck")

    stacked_deck = stack_low_cards(Deck.new())
    %Game{result: result} = War.play_game(stacked_deck)
    expected_result = "Player B wins"

    assert(expected_result, result)
  end

  def test_three do
    log("Player A has all cards in the deck after winning")

    stacked_deck = stack_high_cards(Deck.new())
    %Game{hands: [%Hand{cards: cards}, _]} = War.play_game(stacked_deck)
    expected_cards = Deck.new().cards
    actual_cards = organize_cards(cards)

    assert(expected_cards, actual_cards)
  end

  def test_four do
    log("Player B has all cards in the deck after winning")

    stacked_deck = stack_low_cards(Deck.new())
    %Game{hands: [_, %Hand{cards: cards}]} = War.play_game(stacked_deck)
    actual_cards = organize_cards(cards)
    expected_cards = Deck.new().cards

    assert(expected_cards, actual_cards)
  end

  def test_five do
    log("a game returns a valid result with a shuffled deck")

    %Game{result: result} = War.play_game()

    cond do
      result in ["Player A wins", "Player B wins", "Stalemate"] -> passed()
      true -> failed("Player A wins or Player B wins or Stalemate", result)
    end
  end

  def test_six do
    log("a completed game with a shuffled deck has all original cards")

    %Game{hands: [%Hand{cards: cards_a}, %Hand{cards: cards_b}]} = War.play_game()
    actual_cards = organize_cards(cards_a ++ cards_b)
    expected_cards = Deck.new().cards

    assert(expected_cards, actual_cards)
  end

  defp assert(expected, actual) when expected == actual, do: passed()
  defp assert(expected, actual), do: failed(expected, actual)

  defp log(msg) do
    IO.puts(IO.ANSI.yellow() <> ">>> #{msg}" <> IO.ANSI.reset())
  end

  defp passed do
    IO.puts(IO.ANSI.green() <> "passed" <> IO.ANSI.reset())
    :passed
  end

  defp failed(expected, result) do
    IO.puts(
      IO.ANSI.red() <>
        "expected: #{inspect(expected)}, got: #{inspect(result)}" <> IO.ANSI.reset()
    )

    :failed
  end

  defp organize_cards(cards) do
    clubs = cards |> filter_suit(:club) |> sort_by_value()
    diamonds = cards |> filter_suit(:diamond) |> sort_by_value()
    hearts = cards |> filter_suit(:heart) |> sort_by_value()
    spades = cards |> filter_suit(:spade) |> sort_by_value()
    clubs ++ diamonds ++ hearts ++ spades
  end

  defp filter_suit(cards, suit), do: Enum.filter(cards, &(&1.suit == suit))

  defp sort_by_value(cards), do: cards |> Enum.sort_by(&Card.value/1) |> Enum.reverse()

  defp stack_high_cards(%Deck{cards: cards}) do
    {high_cards, low_cards} = Enum.split_with(cards, fn card -> Card.value(card) > 7 end)
    %Deck{cards: high_cards ++ low_cards}
  end

  defp stack_low_cards(%Deck{cards: cards}) do
    {high_cards, low_cards} = Enum.split_with(cards, fn card -> Card.value(card) > 7 end)
    %Deck{cards: low_cards ++ high_cards}
  end
end
