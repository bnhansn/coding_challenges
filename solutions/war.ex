defmodule War do
  @spec play_game(Deck.t()) :: Game.t()
  def play_game(deck \\ Deck.shuffled()) do
    deck
    |> Game.new()
    |> play_round()
  end

  defp play_round(_game, num_facedown \\ 0, war_cards \\ [])

  defp play_round(%Game{hands: [%Hand{}, %Hand{cards: []}]} = game, _, _) do
    %Game{game | result: "Player A wins"}
  end

  defp play_round(%Game{hands: [%Hand{cards: []}, %Hand{}]} = game, _, _) do
    %Game{game | result: "Player B wins"}
  end

  defp play_round(%Game{round: round} = game, _, _) when round >= 10000 do
    %Game{game | result: "Stalemate"}
  end

  defp play_round(game, num_facedown, war_cards) do
    %Game{hands: [hand_a, hand_b]} = game

    {facedown_cards_a, [faceup_card_a | remaining_cards_a]} =
      Enum.split(hand_a.cards, num_facedown)

    {facedown_cards_b, [faceup_card_b | remaining_cards_b]} =
      Enum.split(hand_b.cards, num_facedown)

    war_cards =
      war_cards ++ facedown_cards_a ++ facedown_cards_b ++ [faceup_card_a, faceup_card_b]

    game = %Game{
      hands: [
        %Hand{cards: remaining_cards_a},
        %Hand{cards: remaining_cards_b}
      ],
      round: game.round + 1
    }

    cond do
      Card.value(faceup_card_a) > Card.value(faceup_card_b) -> award_hand_a_cards(game, war_cards)
      Card.value(faceup_card_a) < Card.value(faceup_card_b) -> award_hand_b_cards(game, war_cards)
      true -> play_war(game, war_cards)
    end
  end

  defp award_hand_a_cards(%Game{hands: [%Hand{cards: cards}, hand_b]} = game, war_cards) do
    game = %Game{
      game
      | hands: [
          %Hand{cards: cards ++ war_cards},
          hand_b
        ]
    }

    play_round(game)
  end

  defp award_hand_b_cards(%Game{hands: [hand_a, %Hand{cards: cards}]} = game, war_cards) do
    game = %Game{
      game
      | hands: [
          hand_a,
          %Hand{cards: cards ++ war_cards}
        ]
    }

    play_round(game)
  end

  defp play_war(
         %Game{hands: [%Hand{cards: hand_a_cards}, %Hand{cards: hand_b_cards}]} = game,
         war_cards
       )
       when length(hand_a_cards) >= 3 and length(hand_b_cards) >= 3,
       do: play_round(game, 2, war_cards)

  defp play_war(
         %Game{hands: [%Hand{cards: hand_a_cards}, %Hand{cards: hand_b_cards}]} = game,
         war_cards
       )
       when length(hand_a_cards) == 2 or length(hand_b_cards) == 2,
       do: play_round(game, 1, war_cards)

  defp play_war(
         %Game{hands: [%Hand{cards: hand_a_cards}, %Hand{cards: hand_b_cards}]} = game,
         war_cards
       )
       when length(hand_a_cards) == 1 or length(hand_b_cards) == 1,
       do: play_round(game, 0, war_cards)

  defp play_war(%Game{hands: [%Hand{} = hand_a, %Hand{cards: []} = hand_b]} = game, war_cards) do
    %Game{
      game
      | hands: [
          %Hand{cards: hand_a.cards ++ war_cards},
          hand_b
        ],
        result: "Player A wins"
    }
  end

  defp play_war(%Game{hands: [%Hand{cards: []} = hand_a, %Hand{} = hand_b]} = game, war_cards) do
    %Game{
      game
      | hands: [
          hand_a,
          %Hand{cards: hand_b.cards ++ war_cards}
        ],
        result: "Player B wins"
    }
  end
end
