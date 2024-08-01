defmodule RoundTest do
  use ExUnit.Case
  doctest Round

  test "[new] populates new round struct fields correctly" do
    # check with static unshuffled deck and shuffled deck
    deck_tmp = Deck.new()
    decks = [deck_tmp, Deck.shuffle(deck_tmp)]

    # check creation works correctly with both p1 and p2 starting
    p_starts = [0, 1]

    Enum.each(decks, fn deck ->
      Enum.each(p_starts, fn p_index ->
        p2_index = rem(p_index + 1, 2)

        round = Round.new(deck, p_index)
        # check deals cards correctly (there's probably a better way to do this)
        assert Enum.at(deck.cards, 0) == Enum.at(elem(round.p_hands, p_index), 0)
        assert Enum.at(deck.cards, 1) == Enum.at(elem(round.p_hands, p_index), 1)
        assert Enum.at(deck.cards, 2) == Enum.at(elem(round.p_hands, p_index), 2)
        assert Enum.at(deck.cards, 3) == Enum.at(elem(round.p_hands, p2_index), 0)
        assert Enum.at(deck.cards, 4) == Enum.at(elem(round.p_hands, p2_index), 1)
        assert Enum.at(deck.cards, 5) == Enum.at(elem(round.p_hands, p2_index), 2)
        assert Enum.at(deck.cards, 6) == Enum.at(elem(round.p_hands, p_index), 3)
        assert Enum.at(deck.cards, 7) == Enum.at(elem(round.p_hands, p_index), 4)
        assert Enum.at(deck.cards, 8) == Enum.at(elem(round.p_hands, p_index), 5)
        assert Enum.at(deck.cards, 9) == Enum.at(elem(round.p_hands, p2_index), 3)
        assert Enum.at(deck.cards, 10) == Enum.at(elem(round.p_hands, p2_index), 4)
        assert Enum.at(deck.cards, 11) == Enum.at(elem(round.p_hands, p2_index), 5)

        # check trump suit is determined correctly
        assert round.trump_suit == Enum.at(deck.cards, -1).s

        # check round deck has lost the right number of cards
        assert length(round.deck.cards) == length(deck.cards) - 12
      end)
    end)
  end

  test "[get_player_scores] calculates player current scores correctly" do
    round = Round.new(Deck.new(), 0)

    # check initial scores start from [0, 0]
    assert Round.get_player_scores(round) == [0, 0]

    # add some cards to player piles and check if they are calculated correctly for both players
    cards_to_check = [%Card{r: "Q", s: "H", pnts: 4}, %Card{r: "K", s: "D", pnts: 5}]

    round = %Round{round | p_piles: {%Deck{}, %Deck{cards: cards_to_check}}}
    assert Round.get_player_scores(round) == [0, 9]

    round = %Round{round | p_piles: {%Deck{cards: cards_to_check}, %Deck{}}}
    assert Round.get_player_scores(round) == [9, 0]

    # check calculation when there is premium points as well
    round = %Round{
      round
      | p_premiums: {
          [%{cards: [%Card{r: "Q", s: "H", pnts: 4}, %Card{r: "K", s: "H", pnts: 5}], pnts: 20}],
          []
        }
    }

    assert Round.get_player_scores(round) == [29, 0]
  end

  test "[get_player_final_scores] calculates player final scores correctly" do
    round = Round.new(Deck.new(), 0)
    # scores at start are always 0:0
    assert Round.get_player_final_scores(round) == [0, 0]

    # add however many points we want to test
    round = %Round{round | p_premiums: {[%{pnts: 33}], []}}
    assert Round.get_player_final_scores(round) == [1, 0]

    # add however many points we want to test
    round = %Round{round | p_premiums: {[%{pnts: 67}], []}}
    assert Round.get_player_final_scores(round) == [2, 0]

    # add however many points we want to test
    round = %Round{round | p_premiums: {[%{pnts: 67}], [%{pnts: 47}]}}
    assert Round.get_player_final_scores(round) == [2, 1]

    round = %Round{round | p_premiums: {[%{pnts: 66}], [%{pnts: 66}]}}
    assert Round.get_player_final_scores(round) == [1, 1]

    round = %Round{round | p_premiums: {[%{pnts: 100}], [%{pnts: 100}]}}
    assert Round.get_player_final_scores(round) == [1, 1]

    round = %Round{round | deck_closer: 0}
    assert Round.get_player_final_scores(round) == [0, 3]

    round = %Round{round | p_premiums: {[%{pnts: 100}], [%{pnts: 32}]}}
    assert Round.get_player_final_scores(round) == [3, 0]

    round = %Round{round | p_premiums: {[%{pnts: 67}], [%{pnts: 35}]}}
    assert Round.get_player_final_scores(round) == [2, 1]

    round = %Round{round | p_premiums: {[%{pnts: 67}], [%{pnts: 85}]}}
    assert Round.get_player_final_scores(round) == [0, 3]
  end

  test "[get_player_card_options] round gets player options correctly" do
    # check round returns empty option list for player who is not playing
    Enum.each(0..1, fn p_turn ->
      round = Round.new(Deck.new(), p_turn)
      p_options = Round.get_player_card_options(round)

      assert length(Enum.at(p_options, p_turn)) == 6
      assert length(Enum.at(p_options, rem(p_turn + 1, 2))) == 0
    end)

    # NOTE: these tests rely on the deck being un-shuffled
    # check correct checking for placed card when getting options
    round = Round.new(Deck.new(), 0)

    # check players can respond with whatever if the deck is not empty and not closed
    round = %Round{round | placed_cards: [nil, %Card{s: "S", r: "9"}]}
    options = Round.get_player_card_options(round)
    assert length(Enum.at(options, 0)) == 6

    # players can give whatever if they don't have a card to respond with
    round = %Round{round | placed_cards: [nil, %Card{s: "D", r: "9"}]}
    options = Round.get_player_card_options(round)
    assert length(Enum.at(options, 0)) == 6

    # empty round deck to check responding to suits logic
    round = %Round{round | deck: %Deck{cards: []}}
    round = %Round{round | placed_cards: [nil, %Card{s: "S", r: "9"}]}
    options = Round.get_player_card_options(round)
    assert length(Enum.at(options, 0)) == 3

    round = %Round{round | placed_cards: [nil, %Card{s: "H", r: "9"}]}
    options = Round.get_player_card_options(round)
    assert length(Enum.at(options, 0)) == 3

    # if player doesn't have requested suit and don't have trump (it is C in this case) then they can give whatever
    round = %Round{round | placed_cards: [nil, %Card{s: "D", r: "9"}]}
    options = Round.get_player_card_options(round)
    assert length(Enum.at(options, 0)) == 6

    # if player doesn't have requested suit and has trump they need to trump
    # add trump card to hand manually to check this
    new_hand = [%Card{s: "C", r: "J"} | elem(round.p_hands, 0)]
    round = %Round{round | p_hands: {new_hand, []}}
    options = Round.get_player_card_options(round)
    assert length(Enum.at(options, 0)) == 1
  end

  test "[get_player_premium_options] round gets player premium options correctly" do
    round = Round.new(Deck.new(), 0)
    # this test only works on un shuffled deck
    assert round.trump_suit == "C"
    assert round.p_turn == 0

    # check that there are no available premiums on the default dealt cards
    premium_options = Round.get_player_premium_options(round)
    assert Enum.all?(premium_options, fn options -> length(options) == 0 end)

    # check Q+K premium for 20 pts - modify round hands so player only has that
    new_hands = {[%Card{r: "Q", s: "S"}, %Card{r: "K", s: "S"}], []}
    round = %Round{round | p_hands: new_hands}
    premium_options = Round.get_player_premium_options(round)

    player_premiums = Enum.at(premium_options, 0)
    assert length(player_premiums) == 1
    assert Enum.at(player_premiums, 0).pnts == 20
    assert Enum.at(Enum.at(player_premiums, 0).cards, 0) == %Card{r: "Q", s: "S"}
    assert Enum.at(Enum.at(player_premiums, 0).cards, 1) == %Card{r: "K", s: "S"}

    # check bad Q+K premium - from different suits - should not be registered as a premium
    new_hands = {[%Card{r: "Q", s: "S"}, %Card{r: "K", s: "D"}], []}
    round = %Round{round | p_hands: new_hands}
    premium_options = Round.get_player_premium_options(round)
    assert length(Enum.at(premium_options, 0)) == 0

    # check Q+K premium for 40 pts + multiple premiums + premiums being reported in combos AND sorted suit order
    new_hands = {
      [
        %Card{r: "K", s: "S"},
        %Card{r: "Q", s: "C"},
        %Card{r: "Q", s: "S"},
        %Card{r: "K", s: "C"}
      ],
      []
    }

    round = %Round{round | p_hands: new_hands}
    premium_options = Round.get_player_premium_options(round)

    player_premiums = Enum.at(premium_options, 0)
    assert length(player_premiums) == 2

    assert Enum.at(player_premiums, 0).pnts == 40
    assert Enum.at(player_premiums, 1).pnts == 20

    assert Enum.at(Enum.at(player_premiums, 0).cards, 0) == %Card{r: "Q", s: "C"}
    assert Enum.at(Enum.at(player_premiums, 0).cards, 1) == %Card{r: "K", s: "C"}

    assert Enum.at(Enum.at(player_premiums, 1).cards, 0) == %Card{r: "Q", s: "S"}
    assert Enum.at(Enum.at(player_premiums, 1).cards, 1) == %Card{r: "K", s: "S"}

    # check player cannot re-announce already announced premiums
    round = %Round{round | p_premiums: {[Enum.at(player_premiums, 0)], []}}
    premium_options = Round.get_player_premium_options(round)
    player_premiums = Enum.at(premium_options, 0)

    # player can only announce second premium from before as first has been registered to them
    assert length(player_premiums) == 1
    assert Enum.at(player_premiums, 0).pnts == 20
    assert Enum.at(Enum.at(player_premiums, 0).cards, 0) == %Card{r: "Q", s: "S"}
    assert Enum.at(Enum.at(player_premiums, 0).cards, 1) == %Card{r: "K", s: "S"}
  end

  test "[get_player_other_options] round gets player options correctly" do
    round = Round.new(Deck.new(), 0)

    # this test only works on un shuffled deck
    assert round.trump_suit == "C"
    assert round.p_turn == 0

    # there should only be the option to close the deck at the start
    other_options = Round.get_player_other_options(round)
    assert Enum.at(other_options, 0) == [:close_deck]
    assert length(Enum.at(other_options, 1)) == 0

    # test the option to end the game early - give p1 a bunch of premiums to meet the threshold of 66
    round = %Round{
      round
      | p_premiums: {
          [
            %{cards: [%Card{r: "Q", s: "H", pnts: 4}, %Card{r: "K", s: "H", pnts: 5}], pnts: 20},
            %{cards: [%Card{r: "Q", s: "D", pnts: 4}, %Card{r: "K", s: "D", pnts: 5}], pnts: 20},
            %{cards: [%Card{r: "Q", s: "C", pnts: 4}, %Card{r: "K", s: "C", pnts: 5}], pnts: 40}
          ],
          []
        }
    }

    other_options = Round.get_player_other_options(round)
    assert Enum.at(other_options, 0) == [:close_deck, :end_round]
    assert length(Enum.at(other_options, 1)) == 0

    # test option to swap out trump card at bottom if player holds 9 of trump

    round = %Round{round | p_hands: {[%Card{r: "9", s: "C"}], []}}
    other_options = Round.get_player_other_options(round)
    assert Enum.at(other_options, 0) == [:swap_card, :close_deck, :end_round]
    assert length(Enum.at(other_options, 1)) == 0
  end

  test "[perform_player_move] check players placing cards" do
    round = Round.new(Deck.new(), 0)

    # check error handling
    assert Round.perform_player_move(round, 1, nil, nil) == {:error, "Player does not have turn"}

    assert Round.perform_player_move(round, 0, :test, nil) ==
             {:error,
              "Move type unknown, known types are :card_play, :premium_play and :other_play"}

    # check playing card correctly for both players
    Enum.each(0..1, fn p_index ->
      round_tmp = %Round{round | p_turn: p_index}

      card_to_play = Enum.at(elem(round_tmp.p_hands, p_index), 0)
      updated_round = Round.perform_player_move(round_tmp, p_index, :card_play, card_to_play)
      assert Enum.at(updated_round.placed_cards, p_index) == card_to_play
      assert length(elem(updated_round.p_hands, p_index)) == 5

      # check card removed from hand
      assert Enum.any?(elem(updated_round.p_hands, p_index), fn card -> card == card_to_play end) ==
               false
    end)

    # check player playing card they can't play
    result = Round.perform_player_move(round, 0, :card_play, %Card{r: "A", s: "C"})
    assert result == {:error, "Player cannot place this card"}
  end

  test "[perform_player_move] check players announcing premiums" do
    round = Round.new(Deck.new(), 0)

    hands_to_check = [
      [
        %Card{r: "Q", s: "S"},
        %Card{r: "K", s: "S"},
        %Card{r: "Q", s: "C"},
        %Card{r: "K", s: "C"},
        %Card{r: "Q", s: "H"},
        %Card{r: "K", s: "H"}
      ],
      [
        %Card{r: "Q", s: "S"},
        %Card{r: "K", s: "S"}
      ],
      [
        %Card{r: "Q", s: "S"},
        %Card{r: "K", s: "C"},
        %Card{r: "K", s: "S"},
        %Card{r: "Q", s: "C"}
      ]
    ]

    Enum.each(hands_to_check, fn new_hand ->
      Enum.each(0..1, fn p_index ->
        round_tmp =
          cond do
            p_index == 0 -> %Round{round | p_turn: p_index, p_hands: {new_hand, []}}
            p_index == 1 -> %Round{round | p_turn: p_index, p_hands: {[], new_hand}}
          end

        premiums_to_play = Round.get_player_premium_options(round_tmp) |> Enum.at(p_index)
        assert length(premiums_to_play) == length(new_hand) / 2

        # play all premiums for users
        updated_round =
          Enum.reduce(premiums_to_play, round_tmp, fn premium, updated_round ->
            Round.perform_player_move(updated_round, p_index, :premium_play, premium)
          end)

        assert elem(updated_round.p_premiums, p_index) == Enum.reverse(premiums_to_play)
      end)
    end)

    # check player announcing premium they can't play
    result =
      Round.perform_player_move(round, 0, :premium_play, %{
        cards: [%Card{r: "Q", s: "S", pnts: nil}, %Card{r: "K", s: "S", pnts: nil}],
        pnts: 20
      })

    assert result == {:error, "Player cannot announce this premium"}
  end

  test "[perform_player_move] check players announcing other options" do
    # check both players can close deck
    Enum.each(0..1, fn p_index ->
      round = Round.new(Deck.new(), p_index)
      updated_round = Round.perform_player_move(round, p_index, :other_play, :close_deck)
      assert updated_round.deck_closed == true
      assert updated_round.deck_closer == p_index

      # check players can't close deck if there are fewer <= 2 cards left in round deck
      round = %Round{
        round
        | deck: %Deck{cards: [%Card{r: "9", s: "D", pnts: 0}, %Card{r: "9", s: "H", pnts: 0}]}
      }

      updated_round = Round.perform_player_move(round, p_index, :other_play, :close_deck)
      assert updated_round == {:error, "Player cannot announce this game option"}

      round = %Round{round | deck: %Deck{cards: []}}
      updated_round = Round.perform_player_move(round, p_index, :other_play, :close_deck)
      assert updated_round == {:error, "Player cannot announce this game option"}
    end)

    # helper func to shuffle deck until last card is not 9
    deck_shuffle = fn deck, self ->
      if Enum.at(deck.cards, -1).r == "9" do
        self.(Deck.shuffle(deck), self)
      else
        deck
      end
    end

    # check both players swap out last card
    Enum.each(0..1, fn p_index ->
      round = Round.new(Deck.new(), p_index)

      # check current player does not have 9 of trumps
      assert Enum.any?(elem(round.p_hands, p_index), fn card ->
               card.r == "9" and card.s == round.trump_suit
             end) == false

      # check error handling when player does not have 9 of trumps for :swap_card action
      updated_round = Round.perform_player_move(round, p_index, :other_play, :swap_card)
      assert updated_round == {:error, "Player cannot announce this game option"}

      # now create new round with shuffled deck and give player 9 of trumps
      round = Round.new(Deck.new() |> deck_shuffle.(deck_shuffle), p_index)
      new_hand = [%Card{r: "9", s: round.trump_suit}]

      round =
        cond do
          p_index == 0 -> %Round{round | p_hands: {new_hand, []}}
          p_index == 1 -> %Round{round | p_hands: {[], new_hand}}
        end

      current_last_card = Enum.at(round.deck.cards, -1)
      assert current_last_card.r != "9"

      # perform swapping of 9 of trumps for trump card at the bottom of the deck
      updated_round = Round.perform_player_move(round, p_index, :other_play, :swap_card)

      assert Enum.at(updated_round.deck.cards, -1) == %Card{r: "9", s: round.trump_suit, pnts: 0}

      assert Enum.any?(elem(updated_round.p_hands, p_index), fn card ->
               card == current_last_card
             end)
    end)

    # check both players can end round early
    Enum.each(0..1, fn p_index ->
      round = Round.new(Deck.new(), p_index)

      # players should not be able to end the game in the start
      updated_round = Round.perform_player_move(round, p_index, :other_play, :end_round)
      assert updated_round == {:error, "Player cannot announce this game option"}

      # give 66+ points to player with premiums
      new_premiums = [%{pnts: 40}, %{pnts: 20}, %{pnts: 20}]
      round =
        cond do
          p_index == 0 -> %Round{round | p_premiums: {new_premiums, []}}
          p_index == 1 -> %Round{round | p_premiums: {[], new_premiums}}
        end

      updated_round = Round.perform_player_move(round, p_index, :other_play, :end_round)
      assert updated_round.winner == p_index
      assert updated_round.p_turn == -1
    end)
  end
end
