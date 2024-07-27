defmodule RoundTest do
  use ExUnit.Case
  doctest Round

  require(Round)
  require(Deck)
  require(Card)

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
        assert Enum.at(deck.cards, 0) == Enum.at(Enum.at(round.p_hands, p_index), 0)
        assert Enum.at(deck.cards, 1) == Enum.at(Enum.at(round.p_hands, p_index), 1)
        assert Enum.at(deck.cards, 2) == Enum.at(Enum.at(round.p_hands, p_index), 2)
        assert Enum.at(deck.cards, 3) == Enum.at(Enum.at(round.p_hands, p2_index), 0)
        assert Enum.at(deck.cards, 4) == Enum.at(Enum.at(round.p_hands, p2_index), 1)
        assert Enum.at(deck.cards, 5) == Enum.at(Enum.at(round.p_hands, p2_index), 2)
        assert Enum.at(deck.cards, 6) == Enum.at(Enum.at(round.p_hands, p_index), 3)
        assert Enum.at(deck.cards, 7) == Enum.at(Enum.at(round.p_hands, p_index), 4)
        assert Enum.at(deck.cards, 8) == Enum.at(Enum.at(round.p_hands, p_index), 5)
        assert Enum.at(deck.cards, 9) == Enum.at(Enum.at(round.p_hands, p2_index), 3)
        assert Enum.at(deck.cards, 10) == Enum.at(Enum.at(round.p_hands, p2_index), 4)
        assert Enum.at(deck.cards, 11) == Enum.at(Enum.at(round.p_hands, p2_index), 5)

        # check trump suit is determined correctly
        assert round.trump_suit == Enum.at(deck.cards, -1).s

        # check round deck has lost the right number of cards
        assert length(round.deck.cards) == length(deck.cards) - 12
      end)
    end)
  end

  test "[getPlayerScores] calculates player current scores correctly" do
    round = Round.new(Deck.new(), 0)

    # check initial scores start from [0, 0]
    assert Round.getPlayerScores(round) == [0, 0]

    # add some cards to player piles and check if they are calculated correctly for both players
    cards_to_check = [%Card{r: "Q", s: "H", pnts: 4}, %Card{r: "K", s: "D", pnts: 5}]

    round = %Round{round | p_piles: [%Deck{}, %Deck{cards: cards_to_check}]}
    assert Round.getPlayerScores(round) == [0, 9]

    round = %Round{round | p_piles: [%Deck{cards: cards_to_check}, %Deck{}]}
    assert Round.getPlayerScores(round) == [9, 0]

    # check calculation when there is premium points as well
    round = %Round{
      round
      | p_premiums: [
          [%{cards: [%Card{r: "Q", s: "H", pnts: 4}, %Card{r: "K", s: "H", pnts: 5}], pnts: 20}],
          []
        ]
    }

    assert Round.getPlayerScores(round) == [29, 0]
  end

  test "[getPlayerCardOptions] round gets player options correctly" do
    # check round returns empty option list for player who is not playing
    Enum.each(0..1, fn p_turn ->
      round = Round.new(Deck.new(), p_turn)
      p_options = Round.getPlayerCardOptions(round)

      assert length(Enum.at(p_options, p_turn)) == 6
      assert length(Enum.at(p_options, rem(p_turn + 1, 2))) == 0
    end)

    # NOTE: these tests rely on the deck being un-shuffled
    # check correct checking for placed card when getting options
    round = Round.new(Deck.new(), 0)

    # check players can respond with whatever if the deck is not empty and not closed
    round = %Round{round | placed_cards: [nil, %Card{s: "S", r: "9"}]}
    options = Round.getPlayerCardOptions(round)
    assert length(Enum.at(options, 0)) == 6

    # players can give whatever if they don't have a card to respond with
    round = %Round{round | placed_cards: [nil, %Card{s: "D", r: "9"}]}
    options = Round.getPlayerCardOptions(round)
    assert length(Enum.at(options, 0)) == 6

    # empty round deck to check responding to suits logic
    round = %Round{round | deck: %Deck{cards: []}}
    round = %Round{round | placed_cards: [nil, %Card{s: "S", r: "9"}]}
    options = Round.getPlayerCardOptions(round)
    assert length(Enum.at(options, 0)) == 3

    round = %Round{round | placed_cards: [nil, %Card{s: "H", r: "9"}]}
    options = Round.getPlayerCardOptions(round)
    assert length(Enum.at(options, 0)) == 3

    # if player doesn't have requested suit and don't have trump (it is C in this case) then they can give whatever
    round = %Round{round | placed_cards: [nil, %Card{s: "D", r: "9"}]}
    options = Round.getPlayerCardOptions(round)
    assert length(Enum.at(options, 0)) == 6

    # if player doesn't have requested suit and has trump they need to trump
    # add trump card to hand manually to check this
    new_hand = [%Card{s: "C", r: "J"} | Enum.at(round.p_hands, 0)]
    round = %Round{round | p_hands: [new_hand, []]}
    options = Round.getPlayerCardOptions(round)
    assert length(Enum.at(options, 0)) == 1
  end

  test "[getPlayerPremiumOptions] round gets player premium options correctly" do
    round = Round.new(Deck.new(), 0)
    # this test only works on un shuffled deck
    assert round.trump_suit == "C"
    assert round.p_turn == 0

    # check that there are no available premiums on the default dealt cards
    premium_options = Round.getPlayerPremiumOptions(round)
    assert Enum.all?(premium_options, fn options -> length(options) == 0 end)

    # check Q+K premium for 20 pts - modify round hands so player only has that
    new_hands = [[%Card{r: "Q", s: "S"}, %Card{r: "K", s: "S"}], []]
    round = %Round{round | p_hands: new_hands}
    premium_options = Round.getPlayerPremiumOptions(round)

    player_premiums = Enum.at(premium_options, 0)
    assert length(player_premiums) == 1
    assert Enum.at(player_premiums, 0).pnts == 20
    assert Enum.at(Enum.at(player_premiums, 0).cards, 0) == %Card{r: "Q", s: "S"}
    assert Enum.at(Enum.at(player_premiums, 0).cards, 1) == %Card{r: "K", s: "S"}

    # check bad Q+K premium - from different suits - should not be registered as a premium
    new_hands = [[%Card{r: "Q", s: "S"}, %Card{r: "K", s: "D"}], []]
    round = %Round{round | p_hands: new_hands}
    premium_options = Round.getPlayerPremiumOptions(round)
    assert length(Enum.at(premium_options, 0)) == 0

    # check Q+K premium for 40 pts + multiple premiums + premiums being reported in combos AND sorted suit order
    new_hands = [
      [
        %Card{r: "K", s: "S"},
        %Card{r: "Q", s: "C"},
        %Card{r: "Q", s: "S"},
        %Card{r: "K", s: "C"}
      ],
      []
    ]

    round = %Round{round | p_hands: new_hands}
    premium_options = Round.getPlayerPremiumOptions(round)

    player_premiums = Enum.at(premium_options, 0)
    assert length(player_premiums) == 2

    assert Enum.at(player_premiums, 0).pnts == 40
    assert Enum.at(player_premiums, 1).pnts == 20

    assert Enum.at(Enum.at(player_premiums, 0).cards, 0) == %Card{r: "Q", s: "C"}
    assert Enum.at(Enum.at(player_premiums, 0).cards, 1) == %Card{r: "K", s: "C"}

    assert Enum.at(Enum.at(player_premiums, 1).cards, 0) == %Card{r: "Q", s: "S"}
    assert Enum.at(Enum.at(player_premiums, 1).cards, 1) == %Card{r: "K", s: "S"}
  end

  test "[getPlayerOtherOptions] round gets player options correctly" do
    round = Round.new(Deck.new(), 0)

    # this test only works on un shuffled deck
    assert round.trump_suit == "C"
    assert round.p_turn == 0

    # there should only be the option to close the deck at the start
    other_options = Round.getPlayerOtherOptions(round)
    assert Enum.at(other_options, 0) == [:close_deck]
    assert length(Enum.at(other_options, 1)) == 0

    # test the option to end the game early - give p1 a bunch of premiums to meet the threshold of 66
    round = %Round{
      round
      | p_premiums: [
          [
            %{cards: [%Card{r: "Q", s: "H", pnts: 4}, %Card{r: "K", s: "H", pnts: 5}], pnts: 20},
            %{cards: [%Card{r: "Q", s: "D", pnts: 4}, %Card{r: "K", s: "D", pnts: 5}], pnts: 20},
            %{cards: [%Card{r: "Q", s: "C", pnts: 4}, %Card{r: "K", s: "C", pnts: 5}], pnts: 40}
          ],
          []
        ]
    }
    other_options = Round.getPlayerOtherOptions(round)
    assert Enum.at(other_options, 0) == [:close_deck, :end_round]
    assert length(Enum.at(other_options, 1)) == 0


    # test option to swap out trump card at bottom if player holds 9 of trump

    round = %Round{round | p_hands: [[%Card{r: "9", s: "C"}], []]}
    other_options = Round.getPlayerOtherOptions(round)
    assert Enum.at(other_options, 0) == [:swap_card, :close_deck, :end_round]
    assert length(Enum.at(other_options, 1)) == 0
  end
end
