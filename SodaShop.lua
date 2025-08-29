SMODS.Atlas({
	key = "SodaShop",
	path = "SodaShop.png",
	px = 71,
	py = 95,
})

SMODS.Atlas({
	key = "test",
	path = "test.png",
	px = 71,
	py = 95,
})

SMODS.Atlas({
	key = "unseen",
	path = "UnseenExplosion.png",
	px = 71,
	py = 95,
})

--Dr Pepper
SMODS.Joker({
	key = "drpepper",
	loc_txt = {
		name = "Dr Pepper",
		text = {
			"This Joker gains",
			"{X:mult,C:white} X#1# {} Mult every {C:attention}#2#{C:inactive} [#4#]{}",
			"cards drawn",
			"{C:inactive}(Currently {X:mult,C:white} X#3# {C:inactive} Mult)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 5, y = 3 },
	order = 16,
	cost = 10,
	rarity = 4,
	blueprint_compat = true,
	perishable_compat = false,
	config = {
		extra = {
			cards_remaining = 0,
			x_mult = 0,
			cards = 23,
			xmult_gain = 1,
		},
	},

	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra.xmult_gain,
				card.ability.extra.cards,
				card.ability.extra.x_mult,
				card.ability.extra.cards_remaining,
			},
		}
	end,

	calculate = function(self, card, context)
		if context.hand_drawn and not context.blueprint then
			for i = 1, #context.hand_drawn do
				card.ability.extra.cards_remaining = card.ability.extra.cards_remaining + 1
				if card.ability.extra.cards_remaining >= 23 then
					card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.xmult_gain
					card.ability.extra.cards_remaining = 0
					return {
						message = "Upgrade!",
						colour = G.C.FILTER,
					}
				end
			end
		end

		if context.joker_main then
			return {
				x_mult = card.ability.extra.x_mult,
			}
		end
	end,
})

-- Big Red
SMODS.Joker({
	key = "bigred",
	loc_txt = {
		name = "Big Red",
		text = {
			"This Joker gains",
			"{C:red}+#1#{} Mult when any",
			"{C:attention}Booster Pack{} is skipped",
			"{C:inactive}(Currently {C:red}+#2#{C:inactive} Mult)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 2, y = 0 },
	order = 5,
	cost = 6,
	rarity = 1,
	blueprint_compat = true,
	perishable_compat = false,
	config = {
		extra = {
			mult_gain = 4,
			mult = 0,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
	end,
	calculate = function(self, card, context)
		if context.skipping_booster and not context.blueprint then
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
			return {
				message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.mult_gain } }),
				colour = G.C.RED,
			}
		end
		if context.joker_main then
			return {
				mult = card.ability.extra.mult,
			}
		end
	end,
})

-- Faygo
SMODS.Joker({
	key = "faygo",
	loc_txt = {
		name = "Faygo",
		text = {
			"{C:green}1 in #1#{} chance to",
			"gain {C:attention}+#2#{} hand size",
			"when shop is rerolled",
			"{C:inactive}(Currently {C:attention}+#3#{C:inactive} hand size)",
			"{s:0.8}Resets at end of round",
		},
	},
	atlas = "SodaShop",
	pos = { x = 1, y = 2 },
	order = 18,
	cost = 8,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			odds = 2,
			add_hand_size = 1,
			current_add = 0,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.odds, card.ability.extra.add_hand_size, card.ability.extra.current_add } }
	end,

	add_to_deck = function(self, card, from_debuff)
		G.hand:change_size(card.ability.extra.current_add)
	end,

	remove_from_deck = function(self, card, from_debuff)
		G.hand:change_size(-card.ability.extra.current_add)
	end,

	calculate = function(self, card, context)
		if
			context.reroll_shop
			and not context.blueprint
			and SMODS.pseudorandom_probability(card, "faygo_reroll", 1, card.ability.extra.odds)
		then
			card.ability.extra.current_add = card.ability.extra.current_add + card.ability.extra.add_hand_size
			G.hand:change_size(card.ability.extra.add_hand_size)
			G.E_MANAGER:add_event(Event({
				func = function()
					card_eval_status_text(card, "extra", nil, nil, nil, {
						message = localize({
							type = "variable",
							key = "a_handsize",
							vars = { card.ability.extra.add_hand_size },
						}),
						colour = G.C.FILTER,
						delay = 0.45,
						card = card,
					})
					return true
				end,
			}))
		elseif context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
			G.hand:change_size(-card.ability.extra.current_add)
			card.ability.extra.current_add = 0
			return {
				message = localize("k_reset"),
				colour = G.C.FILTER,
				card = card,
			}
		end
	end,
})

-- Dr Thunder
SMODS.Joker({
	key = "drthunder",
	loc_txt = {
		name = "Dr Thunder",
		text = {
			"Retrigger all Jokers",
			"{C:attention}once{} for every {C:red}Rare{} Joker",
			"to the left of this Joker",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive} retriggers)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 5, y = 1 },
	order = 17,
	cost = 8,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			retriggers = 0,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.retriggers } }
	end,

	calculate = function(self, card, context)
		if context.before and context.cardarea == G.jokers then
			-- Count rare jokers to the left
			local rare_count = 0
			local found_self = false

			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					found_self = true
					break
				elseif G.jokers.cards[i].config.center.rarity == 3 then
					rare_count = rare_count + 1
				end
			end

			card.ability.extra.retriggers = rare_count
		elseif context.retrigger_joker_check and not context.blueprint then
			-- Check if this joker should retrigger other jokers
			if context.other_card ~= card and card.ability.extra.retriggers > 0 then
				return {
					message = localize("k_again_ex"),
					repetitions = card.ability.extra.retriggers,
					card = card,
				}
			end
		end
	end,
})

-- Derpy Soda Pop
SMODS.Joker({
	key = "derpysodapop",
	loc_txt = {
		name = "Derpy Soda Pop",
		text = {
			"Played {C:attention}2s{}, {C:attention}3s{}, and {C:attention}4s{}",
			"each give {X:mult,C:white}X#1#{} Mult when scored",
		},
	},
	atlas = "SodaShop",
	pos = { x = 3, y = 1 },
	order = 14,
	cost = 5,
	rarity = 1,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			x_mult = 2,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and not context.blueprint then
			if
				context.other_card:get_id() == 2
				or context.other_card:get_id() == 3
				or context.other_card:get_id() == 4
			then
				return {
					x_mult = card.ability.extra.x_mult,
					colour = G.C.RED,
					card = card,
				}
			end
		end
	end,
})

-- Red Bull
SMODS.Joker({
	key = "redbull",
	loc_txt = {
		name = "Red Bull",
		text = {
			"Rerolls in shop are {C:attention}free{}",
			"if item purchased from shop.",
			"Not purchasing will deduct",
			"{C:money}reroll cost{} at end of shop",
			"{C:inactive}(Free rerolls used: #1#)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 2, y = 3 },
	order = 25,
	cost = 7,
	rarity = 2,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			purchased_this_shop = false,
			free_rerolls = 0,
			owed_cost = 0,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.free_rerolls } }
	end,

	calculate = function(self, card, context)
		-- Reset at start of shop
		if context.setting_blind and not context.blueprint then
			card.ability.extra.purchased_this_shop = false
			card.ability.extra.free_rerolls = 0
			card.ability.extra.owed_cost = 0

		-- Track purchases
		elseif context.buying_card and not context.blueprint then
			card.ability.extra.purchased_this_shop = true

		-- Handle reroll cost
		elseif context.reroll_shop and not context.blueprint then
			if not card.ability.extra.purchased_this_shop then
				-- Store the cost we'll need to pay later
				card.ability.extra.owed_cost = card.ability.extra.owed_cost + G.GAME.current_round.reroll_cost
				card.ability.extra.free_rerolls = card.ability.extra.free_rerolls + 1

				-- Give money back to make reroll "free"
				ease_dollars(G.GAME.current_round.reroll_cost)

				return {
					message = localize("k_active_ex"),
					colour = G.C.FILTER,
					card = card,
				}
			else
				card.ability.extra.free_rerolls = card.ability.extra.free_rerolls + 1

				-- Give money back to make reroll "free"
				ease_dollars(G.GAME.current_round.reroll_cost)

				return {
					message = localize("k_active_ex"),
					colour = G.C.FILTER,
					card = card,
				}
			end

		-- End of shop - charge for unpaid rerolls
		elseif context.ending_shop and not context.blueprint then
			if not card.ability.extra.purchased_this_shop and card.ability.extra.owed_cost > 0 then
				ease_dollars(-card.ability.extra.owed_cost)

				return {
					message = "-$" .. card.ability.extra.owed_cost,
					colour = G.C.MONEY,
					card = card,
				}
			end
		end
	end,
})

-- Orange Crush
SMODS.Joker({
	key = "orangecrush",
	loc_txt = {
		name = "Orange Crush",
		text = {
			"Each numbered card held in hand",
			"gives {X:mult,C:white}X#1#{} Mult",
			"{C:attention}Face cards{} are {C:red}debuffed",
		},
	},
	atlas = "SodaShop",
	pos = { x = 4, y = 2 },
	order = 21,
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			x_mult = 1.5,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			local numbered_cards = 0

			-- Count numbered cards in hand
			for i = 1, #G.hand.cards do
				local id = G.hand.cards[i]:get_id()
				if id >= 2 and id <= 10 then -- 2-10 are numbered cards
					numbered_cards = numbered_cards + 1
				end
			end

			if numbered_cards > 0 then
				return {
					message = localize("k_active_ex"),
					Xmult_mod = card.ability.extra.x_mult ^ numbered_cards,
					colour = G.C.RED,
					card = card,
				}
			end
		elseif context.other_card and not context.blueprint then
			-- Debuff face cards during individual card evaluation
			if context.other_card.debuff ~= true then
				local id = context.other_card:get_id()
				if id == 11 or id == 12 or id == 13 then
					context.other_card.debuff = true
					return {
						message = localize("k_debuffed"),
						colour = G.C.RED,
						card = context.other_card,
						delay = 0.45,
					}
				end
			end
		end
	end,
})

-- Grape Soda
SMODS.Joker({
	key = "grapesoda",
	loc_txt = {
		name = "Grape Soda",
		text = {
			"This joker gains {X:mult,C:white}X1{} Mult",
			"if first discard is a single {C:attention}Queen",
			"The {C:attention}Queen{} is {C:red}destroyed",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 2, y = 2 },
	order = 19,
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			x_mult = 1,
			first_discard_checked = false,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult } }
	end,

	calculate = function(self, card, context)
		-- Reset at start of round
		if context.setting_blind and not context.blueprint then
			card.ability.extra.first_discard_checked = false

		-- Check first discard
		elseif context.discard and not context.blueprint then
			if not card.ability.extra.first_discard_checked then
				card.ability.extra.first_discard_checked = true

				-- Check if exactly one card discarded and it's a Queen
				if #context.full_hand == 1 and context.full_hand[1]:get_id() == 12 then
					local queen_card = context.full_hand[1]
					card.ability.extra.x_mult = card.ability.extra.x_mult + 1

					-- Destroy the Queen
					queen_card:start_dissolve()

					return {
						message = localize("k_upgrade_ex"),
						colour = G.C.RED,
						card = card,
					}
				end
			end

		-- Apply X Mult during scoring
		elseif context.joker_main and not context.blueprint then
			if card.ability.extra.x_mult > 1 then
				return {
					message = localize("k_active_ex"),
					Xmult_mod = card.ability.extra.x_mult,
					colour = G.C.RED,
					card = card,
				}
			end
		end
	end,
})

-- Ramune
SMODS.Joker({
	key = "ramune",
	loc_txt = {
		name = "Ramune",
		text = {
			"This Joker gains {C:mult}+1{} Mult per card played",
			"while playing your {C:attention}most-played{} poker hand",
			"Resets to {C:mult}+1{} Mult if most-played hand is not played",
			"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult, Most played: #2#)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 1, y = 3 },
	order = 24,
	cost = 7,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			mult = 1,
			most_played_hand = nil,
			last_hand_played = nil,
		},
	},

	loc_vars = function(self, info_queue, card)
		local most_played_hand = "None"
		local max_count = 0

		-- Find most played hand
		for k, v in pairs(G.GAME.hands) do
			if v.played > max_count then
				max_count = v.played
				most_played_hand = localize(k, "poker_hands")
			end
		end

		card.ability.extra.most_played_hand = most_played_hand
		return { vars = { card.ability.extra.mult, most_played_hand } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			-- Find most played hand
			local most_played_type = nil
			local max_count = 0

			for k, v in pairs(G.GAME.hands) do
				if v.played > max_count then
					max_count = v.played
					most_played_type = k
				end
			end

			-- Get current hand type
			local current_hand_type = context.scoring_name

			-- Check if current hand matches most played hand
			if current_hand_type == most_played_type and most_played_type then
				-- Add mult per card played
				local cards_played = #context.full_hand
				card.ability.extra.mult = card.ability.extra.mult + cards_played

				return {
					message = localize("k_upgrade_ex"),
					mult_mod = card.ability.extra.mult,
					colour = G.C.MULT,
					card = card,
				}
			else
				-- Reset to +1 if different hand played
				card.ability.extra.mult = 1

				return {
					message = localize("k_reset"),
					mult_mod = card.ability.extra.mult,
					colour = G.C.MULT,
					card = card,
				}
			end
		end
	end,
})

-- Barq's Root Beer
SMODS.Joker({
	key = "barqsrootbeer",
	loc_txt = {
		name = "Barq's Root Beer",
		text = {
			"Create up to {C:attention}2{} random",
			"{C:tarot}Tarot{} cards if no hands",
			"remaining at end of round",
			"{C:inactive}(Must have room)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 3, y = 3 },
	order = 4,
	cost = 5,
	rarity = 2,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,

	calculate = function(self, card, context)
		if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
			if G.GAME.current_round.hands_left == 0 then
				local created_cards = 0

				-- Create first tarot card
				if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
					G.E_MANAGER:add_event(Event({
						func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									local new_card =
										create_card("Tarot", G.consumeables, nil, nil, nil, nil, nil, "barqs")
									new_card:add_to_deck()
									G.consumeables:emplace(new_card)
									G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
									return true
								end,
							}))
							card_eval_status_text(card, "extra", nil, nil, nil, {
								message = localize("k_plus_tarot"),
								colour = G.C.PURPLE,
							})
							return true
						end,
					}))
					created_cards = created_cards + 1
				end

				-- Create second tarot card
				if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
					G.E_MANAGER:add_event(Event({
						func = function()
							G.E_MANAGER:add_event(Event({
								func = function()
									local new_card =
										create_card("Tarot", G.consumeables, nil, nil, nil, nil, nil, "barqs")
									new_card:add_to_deck()
									G.consumeables:emplace(new_card)
									G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
									return true
								end,
							}))
							return true
						end,
					}))
					created_cards = created_cards + 1
				end
			end
		end
	end,
})

-- Surge
SMODS.Joker({
	key = "surge",
	loc_txt = {
		name = "Surge",
		text = {
			"Retrigger all played cards",
			"{C:attention}#1#{} times during the {C:attention}Boss Blind",
		},
	},
	atlas = "SodaShop",
	pos = { x = 2, y = 4 },
	order = 31,
	cost = 8,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			reps = 2,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.reps } }
	end,

	calculate = function(self, card, context)
		if context.repetition and context.cardarea == G.play and not context.blueprint then
			if G.GAME.blind and G.GAME.blind.boss then
				return {
					message = localize("k_again_ex"),
					repetitions = card.ability.extra.reps,
					card = card,
				}
			end
		end
	end,
})

-- A&W Cream Soda
SMODS.Joker({
	key = "creamsoda",
	loc_txt = {
		name = "A&W Cream Soda",
		text = {
			"{C:mult}+#1#{} Mult on {C:attention}first",
			"{C:attention}hand{} of round",
		},
	},
	atlas = "SodaShop",
	pos = { x = 1, y = 1 },
	order = 2,
	cost = 4,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			mult = 23,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			if G.GAME.current_round.hands_played == 0 then
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.mult } }),
					mult_mod = card.ability.extra.mult,
				}
			end
		end
	end,
})

-- Baja Blast
SMODS.Joker({
	key = "baja_blast",
	loc_txt = {
		name = "Baja Blast",
		text = {
			"After {C:attention}#1#{} rounds,",
			"sell this card to multiply",
			"sell values of owned {C:attention}Jokers{}",
			"by {C:money}X#2#{}",
		},
	},
	atlas = "SodaShop",
	pos = { x = 1, y = 0 },
	order = 3,
	cost = 8,
	rarity = 3,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			rounds_remaining = 10,
			multiplier = 3,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rounds_remaining, card.ability.extra.multiplier } }
	end,

	calculate = function(self, card, context)
		-- Update rounds remaining at end of round
		if context.end_of_round and not context.repetition and not context.individual then
			if card.ability.extra.rounds_remaining > 0 then
				card.ability.extra.rounds_remaining = card.ability.extra.rounds_remaining - 1

				-- Update card text to show remaining rounds
				if card.ability.extra.rounds_remaining == 0 then
					card_eval_status_text(card, "extra", nil, nil, nil, {
						message = "Ready!",
						colour = G.C.MONEY,
					})
				else
					card_eval_status_text(card, "extra", nil, nil, nil, {
						message = card.ability.extra.rounds_remaining .. " rounds",
						colour = G.C.BLUE,
					})
				end

				return {
					message = card.ability.extra.rounds_remaining .. " rounds left",
					colour = G.C.FILTER,
				}
			end
		end

		-- Handle selling when ready
		if context.selling_self and card.ability.extra.rounds_remaining <= 0 then
			-- Multiply sell values of all other jokers by 3
			local jokers_affected = 0
			for i = 1, #G.jokers.cards do
				local joker = G.jokers.cards[i]
				if joker ~= card and joker.sell_cost then
					joker.sell_cost = joker.sell_cost * card.ability.extra.multiplier
					jokers_affected = jokers_affected + 1
				end
			end

			if jokers_affected > 0 then
				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "Boosted " .. jokers_affected .. " Jokers!",
					colour = G.C.MONEY,
				})
			end

			return {
				message = "Baja Blast!",
				colour = G.C.MONEY,
			}
		end
	end,
})

-- Pepsi
SMODS.Joker({
	key = "pepsi",
	loc_txt = {
		name = "Pepsi",
		text = {
			"{X:mult,C:white}X#1#{} Mult",
		},
	},
	atlas = "SodaShop",
	pos = { x = 0, y = 3 },
	order = 22,
	cost = 7,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			x_mult = 10,
			debuff_x_mult = 0.5,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult, card.ability.extra.debuff_x_mult } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			-- Check if Coca Cola is present
			local has_coca_cola = false
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].config.center.key == "coca_cola" then
					has_coca_cola = true
					break
				end
			end

			local x_mult_value = has_coca_cola and card.ability.extra.debuff_x_mult or card.ability.extra.x_mult

			return {
				message = has_coca_cola and "Ew! Coke!"
					or localize({ type = "variable", key = "a_xmult", vars = { x_mult_value } }),
				colour = has_coca_cola and G.C.RED or G.C.MULT,
				Xmult_mod = x_mult_value,
			}
		end
	end,
})

-- Coca Cola
SMODS.Joker({
	key = "coca_cola",
	loc_txt = {
		name = "Coca Cola",
		text = {
			"{X:chips,C:white}X#1#{} Chips",
		},
	},
	atlas = "SodaShop",
	pos = { x = 5, y = 0 },
	order = 11,
	cost = 7,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			x_chips = 30,
			debuff_x_chips = 0.5,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_chips, card.ability.extra.debuff_x_chips } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			-- Check if Pepsi is present
			local has_pepsi = false
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i].config.center.key == "pepsi" then
					has_pepsi = true
					break
				end
			end

			local x_chips_value = has_pepsi and card.ability.extra.debuff_x_chips or card.ability.extra.x_chips

			return {
				message = has_pepsi and "Ugh, Pepsi..."
					or localize({ type = "variable", key = "a_xchip", vars = { x_chips_value } }),
				colour = has_pepsi and G.C.RED or G.C.CHIPS,
				Xchip_mod = x_chips_value,
			}
		end
	end,
})

-- Crystal Pepsi
SMODS.Joker({
	key = "crystal_pepsi",
	loc_txt = {
		name = "Crystal Pepsi",
		text = {
			"{C:green}#1# in #2#{} chance to",
			"permanently gain {C:blue}+1{} hand",
			"on reroll",
			"{C:inactive}(They don't get it; they don't see my vision.)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 2, y = 1 },
	order = 13,
	cost = 4,
	rarity = 1,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			odds = 23,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { G.GAME.probabilities.normal, card.ability.extra.odds } }
	end,

	calculate = function(self, card, context)
		if context.reroll_shop and not context.blueprint then
			if pseudorandom("crystal_pepsi") < G.GAME.probabilities.normal / card.ability.extra.odds then
				G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
				ease_hands_played(1)

				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "My Vision!",
					colour = G.C.BLUE,
				})

				return {
					message = "Crystal Clear!",
					colour = G.C.BLUE,
				}
			end
		end
	end,
})

-- Pepsi Blue
SMODS.Joker({
	key = "pepsi_blue",
	loc_txt = {
		name = "Pepsi Blue",
		text = {
			"{C:chips}+#1#{} Chips per {C:attention}Joker{}",
			"{C:chips}+#2#{} Chips if played hand is {C:attention}#3#{}",
			"({C:chips}+#4#{C:inactive} Chips)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 5, y = 2 },
	order = 23,
	cost = 5,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			chips = 6,
			bonus = 1,
			xchips = 3,
			type = "High Card",
		},
	},

	loc_vars = function(self, info_queue, card)
		return {
			vars = {
				card.ability.extra.chips,
				card.ability.extra.bonus,
				localize(card.ability.extra.type, "poker_hands"),
				card.ability.extra.chips * card.ability.extra.xchips,
			},
		}
	end,

	calculate = function(self, card, context)
		if context.cardarea == G.jokers and context.before and not context.blueprint then
			if context.scoring_name == card.ability.extra.type then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.bonus

				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "+" .. card.ability.extra.bonus .. " Chips!",
					colour = G.C.CHIPS,
				})

				return nil, true
			end
		end

		if context.other_joker and context.other_joker.ability.set == "Joker" then
			if
				context.other_joker.config
				and context.other_joker.config.center
				and context.other_joker.config.center.key == "j_jolly"
			then
				return {
					message = localize({
						type = "variable",
						key = "a_chips",
						vars = { card.ability.extra.chips * card.ability.extra.xchips },
					}),
					chip_mod = card.ability.extra.chips * card.ability.extra.xchips,
				}
			else
				return {
					message = localize({ type = "variable", key = "a_chips", vars = { card.ability.extra.chips } }),
					chip_mod = card.ability.extra.chips,
				}
			end
		end
	end,
})

-- Sprite
SMODS.Joker({
	key = "sprite",
	loc_txt = {
		name = "Sprite",
		text = {
			"This Joker gains {X:mult,C:white}X#2#{} Mult",
			"when a {C:attention}face{} card is added to deck",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 0, y = 4 },
	order = 29,
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			x_mult = 1,
			x_mult_gain = 1,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_mult, card.ability.extra.x_mult_gain } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			if card.ability.extra.x_mult > 1 then
				return {
					message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.x_mult } }),
					Xmult_mod = card.ability.extra.x_mult,
					colour = G.C.MULT,
				}
			end
		end

		if context.buying_card and context.card then
			local card_rank = context.card.base.value
			-- Check if it's a face card (Jack=11, Queen=12, King=13)
			if card_rank and (card_rank == 11 or card_rank == 12 or card_rank == 13) then
				card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain

				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "X" .. card.ability.extra.x_mult_gain .. " Mult!",
					colour = G.C.MULT,
				})

				return {
					message = "Face Value!",
					colour = G.C.GREEN,
				}
			end
		end
	end,
})

-- Mountain Dew
SMODS.Joker({
	key = "mountain_dew",
	loc_txt = {
		name = "Mountain Dew",
		text = {
			"{C:chips}+#1#{} Chips",
			"Equal to twice the chips",
			"from first hand of",
			"previous {C:attention}Ante{}",
		},
	},
	atlas = "SodaShop",
	pos = { x = 3, y = 2 },
	order = 20,
	cost = 5,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			chips = 0,
			stored_chips = 0,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			if card.ability.extra.chips > 0 then
				return {
					message = localize({ type = "variable", key = "a_chips", vars = { card.ability.extra.chips } }),
					chip_mod = card.ability.extra.chips,
					colour = G.C.CHIPS,
				}
			end
		end

		-- Store chips from first hand of the round
		if context.before and not context.blueprint and G.GAME.current_round.hands_played == 0 then
			card.ability.extra.stored_chips = context.chips or 0

			card_eval_status_text(card, "extra", nil, nil, nil, {
				message = "Memorizing: " .. card.ability.extra.stored_chips,
				colour = G.C.GREEN,
			})
		end

		-- Update chips at start of new ante
		if context.setting_blind and not context.blueprint then
			if card.ability.extra.stored_chips > 0 then
				card.ability.extra.chips = card.ability.extra.stored_chips * 2
				card.ability.extra.stored_chips = 0

				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "Do the Dew: +" .. card.ability.extra.chips,
					colour = G.C.CHIPS,
				})

				return {
					message = "Energized!",
					colour = G.C.GREEN,
				}
			end
		end
	end,
})

-- Code Red
-- Code Red
SMODS.Joker({
	key = "code_red",
	loc_txt = {
		name = "Code Red",
		text = {
			"All {C:attention}suits{}",
			"considered {C:hearts}Hearts{}",
		},
	},
	atlas = "SodaShop",
	pos = { x = 4, y = 0 },
	order = 10,
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,

	calculate = function(self, card, context)
		-- Override suit checking for all cards in scoring hand
		if context.cardarea == G.hand and context.individual and not context.blueprint then
			if context.other_card then
				-- Force the card to be treated as Hearts for all suit checks
				context.other_card.base.suit = "Hearts"
				context.other_card.config.card.suit = "Hearts"
			end
		end

		-- Also apply when cards are being evaluated for hand types
		if context.before and not context.blueprint then
			for i = 1, #context.scoring_hand do
				context.scoring_hand[i].base.suit = "Hearts"
				context.scoring_hand[i].config.card.suit = "Hearts"
			end

			return {
				message = "Code Red!",
				colour = G.C.RED,
			}
		end
	end,
})

-- Silver Bullet
SMODS.Joker({
	key = "silver_bullet",
	loc_txt = {
		name = "Silver Bullet",
		text = {
			"Sell this joker to",
			"{C:attention}end{} the boss blind",
			"and {C:green}win{} the round",
			"{C:inactive}(It must not be cold enough){}",
		},
	},
	atlas = "SodaShop",
	pos = { x = 4, y = 3 },
	order = 27,
	cost = 4,
	rarity = 1,
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	unlocked = true,
	discovered = true,

	loc_vars = function(self, info_queue, card)
		local main_end = nil
		if card.area and (card.area == G.jokers) then
			local disableable = G.GAME.blind and ((not G.GAME.blind.disabled) and G.GAME.blind.boss)
			main_end = {
				{
					n = G.UIT.C,
					config = { align = "bm", minh = 0.4 },
					nodes = {
						{
							n = G.UIT.C,
							config = {
								ref_table = card,
								align = "m",
								colour = disableable and G.C.GREEN or G.C.RED,
								r = 0.05,
								padding = 0.06,
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = " "
											.. localize(disableable and "k_active" or "ph_no_boss_active")
											.. " ",
										colour = G.C.UI.TEXT_LIGHT,
										scale = 0.32 * 0.9,
									},
								},
							},
						},
						{
							n = G.UIT.C,
							config = { align = "m", colour = G.C.RED, r = 0.05, padding = 0.06 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = " Sell Cost: -$25 ",
										colour = G.C.UI.TEXT_LIGHT,
										scale = 0.32 * 0.9,
									},
								},
							},
						},
					},
				},
			}
		end
		return { main_end = main_end }
	end,

	calculate = function(self, card, context)
		if context.selling_self then
			if G.GAME.blind and not G.GAME.blind.disabled and G.GAME.blind.boss then
				-- Deduct $25 from player money
				ease_dollars(-25)

				return {
					message = "Silver Shot!",
					colour = G.C.MONEY,
					func = function()
						-- End the boss blind and win the round
						G.GAME.chips = G.GAME.blind.chips
						G.STATE = G.STATES.HAND_PLAYED
						G.STATE_COMPLETE = true
						end_round()
					end,
				}
			else
				return {
					message = "No Boss Found",
					colour = G.C.RED,
				}
			end
		end
	end,
})

-- Cactus Cooler
-- Cactus Cooler
SMODS.Joker({
	key = "cactus_cooler",
	loc_txt = {
		name = "Cactus Cooler",
		text = {
			"At end of round, increase",
			"sell value of Joker to the right",
			"by {C:money}X#1#{}",
		},
	},
	atlas = "SodaShop",
	pos = { x = 3, y = 0 },
	order = 6,
	cost = 10,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			increase = 2,
		},
	},

	loc_vars = function(self, info_queue, card)
		card.ability.blueprint_compat_ui = card.ability.blueprint_compat_ui or ""
		card.ability.blueprint_compat_check = nil
		return {
			vars = { card.ability.extra.increase },
			main_end = (card.area and card.area == G.jokers) and {
				{
					n = G.UIT.C,
					config = { align = "bm", minh = 0.4 },
					nodes = {
						{
							n = G.UIT.C,
							config = {
								ref_table = card,
								align = "m",
								colour = G.C.JOKER_GREY,
								r = 0.05,
								padding = 0.06,
							},
							nodes = {
								{
									n = G.UIT.T,
									config = {
										ref_table = card.ability,
										ref_value = "blueprint_compat_ui",
										colour = G.C.UI.TEXT_LIGHT,
										scale = 0.32 * 0.8,
									},
								},
							},
						},
					},
				},
			} or nil,
		}
	end,

	update = function(self, card, front)
		if G.STAGE == G.STAGES.RUN then
			local other_joker = nil
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					other_joker = G.jokers.cards[i + 1]
					break
				end
			end
			if other_joker and other_joker ~= card then
				card.ability.blueprint_compat = "compatible"
				card.ability.blueprint_compat_ui = "Target: " .. other_joker.ability.name
			else
				card.ability.blueprint_compat = "incompatible"
				card.ability.blueprint_compat_ui = "No target to the right"
			end
		end
	end,

	calculate = function(self, card, context)
		if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
			local check = false
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					if i < #G.jokers.cards then
						local target_joker = G.jokers.cards[i + 1]
						if target_joker and target_joker.sell_cost then
							check = true
							target_joker.sell_cost = math.floor(target_joker.sell_cost * card.ability.extra.increase)

							card_eval_status_text(target_joker, "extra", nil, nil, nil, {
								message = "Upgraded!",
								colour = G.C.MONEY,
							})
						end
					end
					break
				end
			end
			if check then
				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "Cool!",
					colour = G.C.ORANGE,
				})

				return {
					message = "Prickly!",
					colour = G.C.GREEN,
				}
			end
		end
	end,
})

-- Diet Coke
-- Diet Coke
SMODS.Joker({
	key = "diet_coke",
	loc_txt = {
		name = "Diet Coke",
		text = {
			"{C:chips}+#1#{} Chips",
		},
	},
	atlas = "SodaShop",
	pos = { x = 4, y = 1 },
	order = 15,
	cost = 4,
	rarity = 1,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			chips = 30,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips } }
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			return {
				message = localize({ type = "variable", key = "a_chips", vars = { card.ability.extra.chips } }),
				chip_mod = card.ability.extra.chips,
				colour = G.C.CHIPS,
			}
		end
	end,
})

-- 7UP
-- 7UP
SMODS.Joker({
	key = "seven_up",
	loc_txt = {
		name = "7UP",
		text = {
			"{C:mult}+#1#{} Mult",
			"{C:mult}+#2#{} Mult per {C:attention}7{} scored",
			"{C:attention}7s{} score twice",
			"{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)",
		},
	},
	atlas = "SodaShop",
	pos = { x = 0, y = 0 },
	order = 1,
	cost = 6,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			mult = 0,
			mult_gain = 10,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, card.ability.extra.mult_gain } }
	end,

	calculate = function(self, card, context)
		-- Apply current mult bonus
		if context.joker_main and not context.blueprint then
			if card.ability.extra.mult > 0 then
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { card.ability.extra.mult } }),
					mult_mod = card.ability.extra.mult,
					colour = G.C.MULT,
				}
			end
		end

		-- Make 7s score twice
		if context.individual and context.cardarea == G.play and not context.blueprint then
			if context.other_card:get_id() == 7 then
				return {
					chips = context.other_card.base.nominal,
					card = context.other_card,
				}
			end
		end

		-- Gain mult for each 7 scored
		if context.before and not context.blueprint then
			local sevens_count = 0
			for k, v in ipairs(context.scoring_hand) do
				if v:get_id() == 7 then
					sevens_count = sevens_count + 1
				end
			end

			if sevens_count > 0 then
				card.ability.extra.mult = card.ability.extra.mult + (sevens_count * card.ability.extra.mult_gain)

				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "+" .. sevens_count * card.ability.extra.mult_gain .. " Mult!",
					colour = G.C.MULT,
				})

				return {
					message = "7up yours!",
					colour = G.C.GREEN,
				}
			end
		end
	end,
})

-- Squirt
-- Squirt
SMODS.Joker({
	key = "squirt",
	loc_txt = {
		name = "Squirt",
		text = {
			"{X:chips,C:white}X#1#{} Chips",
			"At end of blind, if score is",
			"greater than {C:attention}2X{} blind requirement,",
			"gain {X:chips,C:white}X2{} Chips permanently",
		},
	},
	atlas = "SodaShop",
	pos = { x = 1, y = 4 },
	order = 30,
	cost = 7,
	rarity = 2,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = {
		extra = {
			x_chips = 1,
		},
	},

	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.x_chips } }
	end,

	calculate = function(self, card, context)
		-- Apply current x_chips multiplier
		if context.joker_main and not context.blueprint then
			if card.ability.extra.x_chips > 1 then
				return {
					message = localize({ type = "variable", key = "a_xchip", vars = { card.ability.extra.x_chips } }),
					Xchip_mod = card.ability.extra.x_chips,
					colour = G.C.CHIPS,
				}
			end
		end

		-- Check at end of blind for scaling
		if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
			if G.GAME.blind and G.GAME.blind.chips then
				local blind_requirement = G.GAME.blind.chips
				local final_score = G.GAME.chips

				-- If score is greater than 2x the blind requirement
				if final_score > (blind_requirement * 2) then
					card.ability.extra.x_chips = card.ability.extra.x_chips * 2

					card_eval_status_text(card, "extra", nil, nil, nil, {
						message = "X2 Chips!",
						colour = G.C.CHIPS,
					})

					return {
						message = "Squeezed!",
						colour = G.C.YELLOW,
					}
				end
			end
		end
	end,
})

-- Coke Zero
-- Coke Zero
SMODS.Joker({
	key = "coke_zero",
	loc_txt = {
		name = "Coke Zero",
		text = {
			"At start of {C:attention}Ante{}, create a",
			"{C:dark_edition}Negative{} rental copy of a",
			"random {C:attention}Joker{} you own",
		},
	},
	atlas = "SodaShop",
	pos = { x = 0, y = 1 },
	order = 12,
	cost = 8,
	rarity = 3,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = { extra = {} },

	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,

	calculate = function(self, card, context)
		if context.setting_blind and not context.blueprint and G.GAME.blind.boss then
			-- Get all jokers except Coke Zero itself
			local available_jokers = {}
			for i = 1, #G.jokers.cards do
				local joker = G.jokers.cards[i]
				if joker ~= card then
					available_jokers[#available_jokers + 1] = joker
				end
			end

			if #available_jokers > 0 then
				-- Pick a random joker to copy
				local target = pseudorandom_element(available_jokers, pseudoseed("coke_zero"))

				-- Create a copy of the joker
				local new_card = copy_card(target, nil, nil, G.jokers)

				-- Make it negative and rental
				new_card:set_edition({ negative = true }, true)
				new_card.ability.rental = true
				new_card.ability.coke_zero_copy = true

				-- Add to jokers
				new_card:add_to_deck()
				G.jokers:emplace(new_card)

				card_eval_status_text(card, "extra", nil, nil, nil, {
					message = "Copied: " .. target.ability.name,
					colour = G.C.DARK_EDITION,
				})

				return {
					message = "Zero Sugar!",
					colour = G.C.BLACK,
				}
			end
		end
	end,
})

-- Canned Underwear
-- Canned Underwear
SMODS.Joker({
	key = "canned_underwear",
	loc_txt = {
		name = "Canned Underwear",
		text = {
			"{X:chips,C:white}X3{} Chips for every {C:attention}Joker{} to the left",
			"{X:mult,C:white}X2{} Mult for every {C:attention}Joker{} to the right",
			"{C:inactive}(Chips : Mult){}",
		},
	},
	atlas = "SodaShop",
	pos = { x = 3, y = 4 },
	order = 9,
	cost = 12,
	rarity = 4, -- Legendary
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = { extra = {} },

	-- Safely compute left/right counts (works even when G.jokers is not available)
	_count_neighbors = function(self, card)
		local left_count, right_count = 0, 0
		-- Only count neighbors if the card is actually placed in the Jokers area
		if card and card.area and G and G.jokers and card.area == G.jokers and G.jokers.cards then
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					left_count = i - 1
					right_count = #G.jokers.cards - i
					break
				end
			end
		end
		return left_count, right_count
	end,

	loc_vars = function(self, info_queue, card)
		local left_count, right_count = self:_count_neighbors(card)

		-- Compute multipliers (X3 per left, X2 per right). Clamp at least 1x.
		local x_chips = math.max(1, 3 ^ left_count)
		local x_mult = math.max(1, 2 ^ right_count)

		return {
			vars = {},
			-- Only render the little "Xchips : Xmult" pill when the card is in the jokers row
			main_end = (card.area and G and G.jokers and card.area == G.jokers) and {
				{
					n = G.UIT.C,
					config = { align = "bm", minh = 0.4 },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "m", colour = G.C.JOKER_GREY, r = 0.05, padding = 0.06 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = "X" .. number_format(x_chips) .. " : X" .. number_format(x_mult),
										colour = G.C.UI.TEXT_LIGHT,
										scale = 0.32 * 0.9,
									},
								},
							},
						},
					},
				},
			} or nil,
		}
	end,

	calculate = function(self, card, context)
		if context.joker_main and not context.blueprint then
			local left_count, right_count = self:_count_neighbors(card)

			-- Multipliers
			local x_chips = math.max(1, 3 ^ left_count)
			local x_mult = math.max(1, 2 ^ right_count)

			-- Build return table using standard keys
			local ret = {}

			if x_chips > 1 then
				ret.x_chips = x_chips
			end
			if x_mult > 1 then
				ret.x_mult = x_mult
			end

			if x_chips > 1 or x_mult > 1 then
				ret.message = "Smells Fresh!"
				ret.colour = G.C.MULT
				return ret
			end
		end
	end,
})

-- Slurm
SMODS.Joker({
	key = "slurm",
	loc_txt = {
		name = "Slurm",
		text = {
			"{C:mult}+#1#{} Mult#2#",
			"Only evolves when",
			"{C:attention}leftmost{} Joker",
			"{C:inactive}(Stage #3#){}",
		},
	},
	atlas = "SodaShop",
	pos = { x = 4, y = 4 },
	order = 28,
	cost = 7,
	rarity = 2, -- Uncommon
	blueprint_compat = false, -- Incompatible with blueprint/brainstorm
	perishable_compat = true,
	eternal_compat = true,
	config = { extra = { rounds_held = 0, stage = 1, reset_flag = false } },
	loc_vars = function(self, info_queue, center)
		local stage = (center and center.ability and center.ability.extra and center.ability.extra.stage) or 1
		local mult_value = 3
		local extra_text = ""

		if stage == 1 then
			mult_value = 3
			extra_text = ""
		elseif stage == 2 then
			mult_value = 3
			extra_text = ", {C:money}$1{} per hand"
		elseif stage == 3 then
			mult_value = 5
			extra_text = ", {C:money}$2{} per hand"
		elseif stage == 4 then
			mult_value = 8
			extra_text = ", {C:money}$3{} per hand, {X:mult,C:white}X1.2{} Mult"
		else -- stage 5+
			mult_value = 12
			extra_text = ", {C:money}$5{} per hand, {X:mult,C:white}X1.5{} Mult"
		end

		return { vars = { mult_value, extra_text, stage } }
	end,
	calculate = function(self, card, context)
		-- Check if this is the start of a new round
		if context.setting_blind and not context.blueprint then
			local is_leftmost = (G.jokers.cards[1] == card)

			if is_leftmost then
				-- Increase rounds held
				card.ability.extra.rounds_held = card.ability.extra.rounds_held + 1
				card.ability.extra.reset_flag = false

				-- Check for stage evolution (every 5 rounds)
				local new_stage = math.min(5, math.floor((card.ability.extra.rounds_held - 1) / 5) + 1)

				if new_stage > card.ability.extra.stage then
					card.ability.extra.stage = new_stage
					card_eval_status_text(card, "extra", nil, nil, nil, {
						message = "Slurm Evolved! Stage " .. new_stage,
						colour = G.C.FILTER,
					})
				end
			else
				-- Not leftmost - reset if we haven't already shown the reset message
				if not card.ability.extra.reset_flag then
					card.ability.extra.rounds_held = 0
					card.ability.extra.stage = 1
					card.ability.extra.reset_flag = true

					card_eval_status_text(card, "extra", nil, nil, nil, {
						message = "Slurm Addiction Reset!",
						colour = G.C.RED,
					})
				end
			end
		end

		-- Apply effects based on current stage
		if context.joker_main then
			local stage = card.ability.extra.stage
			local ret = {}

			if stage == 1 then
				-- Stage 1: +3 Mult
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { 3 } }),
					mult_mod = 3,
				}
			elseif stage == 2 then
				-- Stage 2: +3 Mult, $1 per hand
				ease_dollars(1)
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { 3 } }) .. ", $1",
					mult_mod = 3,
					dollars = 1,
				}
			elseif stage == 3 then
				-- Stage 3: +5 Mult, $2 per hand
				ease_dollars(2)
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { 5 } }) .. ", $2",
					mult_mod = 5,
					dollars = 2,
				}
			elseif stage == 4 then
				-- Stage 4: +8 Mult, $3 per hand, X1.2 Mult
				ease_dollars(3)
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { 8 } }) .. ", $3, X1.2",
					mult_mod = 8,
					Xmult_mod = 1.2,
					dollars = 3,
				}
			else -- stage 5+
				-- Stage 5: +12 Mult, $5 per hand, X1.5 Mult
				ease_dollars(5)
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { 12 } }) .. ", $5, X1.5",
					mult_mod = 12,
					Xmult_mod = 1.5,
					dollars = 5,
				}
			end
		end
	end,
})

--Unseen Explosion
SMODS.Joker({
	key = "unseen_explosion",
	loc_txt = {
		name = "Unseen Explosion",
		text = {
			"Copies ability of",
			"{C:attention}leftmost{} Joker &",
			"Joker to the {C:attention}right{}",
			"{X:mult,C:white}X2{} Mult",
		},
	},
	atlas = "test",
	pos = { x = 0, y = 0 },
	order = 32,
	cost = 8,
	rarity = 3,
	blueprint_compat = true,
	perishable_compat = true,
	eternal_compat = true,
	unlocked = true,
	discovered = true,
	config = { extra = { Xmult = 2 } },

	-- Core logic: X2 Mult + retrigger copied Jokers
	calculate = function(self, card, context)
		-- Apply the X2 mult first
		if context.joker_main and not context.blueprint and not context.brainstorm then
			return {
				message = localize({ type = "variable", key = "a_xmult", vars = { card.ability.extra.Xmult } }),
				Xmult_mod = card.ability.extra.Xmult,
				repetitions = 1,
			}
		end

		-- Handle Blueprint context (leftmost Joker)
		if context.blueprint and context.blueprint_card == card then
			local leftmost_joker = G.jokers.cards[1]
			if leftmost_joker and leftmost_joker ~= card then
				-- Chain to the copied Joker
				context.blueprint_card = leftmost_joker
				if leftmost_joker.calculate_joker then
					return leftmost_joker:calculate_joker(context)
				end
			end
		end

		-- Handle Brainstorm context (right Joker)
		if context.brainstorm and context.brainstorm_card == card then
			local other_joker = nil
			for i = 1, #G.jokers.cards do
				if G.jokers.cards[i] == card then
					other_joker = G.jokers.cards[i + 1]
					break
				end
			end
			if other_joker and other_joker ~= card then
				-- Chain to the copied Joker
				context.brainstorm_card = other_joker
				if other_joker.calculate_joker then
					return other_joker:calculate_joker(context)
				end
			end
		end
	end,
})

-- Override shop generation to implement 1 in 7 chance
local original_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card =
		original_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)

	-- Only affect joker cards in shop
	if _type == "Joker" and area == G.shop_jokers then
		-- 1 in 7 chance for Unseen Explosion to appear in any shop
		if not G.GAME.unseen_explosion_available then
			G.GAME.unseen_explosion_available = (pseudorandom("unseen_explosion_spawn") < 1 / 7)
		end

		-- If this run allows Unseen Explosion and we roll to replace a card
		if G.GAME.unseen_explosion_available and pseudorandom("unseen_explosion_replace") < 0.05 then
			-- Replace this card with Unseen Explosion
			local unseen_center = G.P_CENTERS.j_SodaShop_unseen_explosion
			if unseen_center then
				card.config.center = unseen_center
				card:set_ability(unseen_center, nil, nil)
				G.GAME.unseen_explosion_appeared = true
			end
		end
	end

	return card
end

-- Reset the availability flag when starting a new run
local original_init_game_object = Game.init_game_object
function Game.init_game_object(self)
	local game_object = original_init_game_object(self)
	game_object.unseen_explosion_available = nil
	game_object.unseen_explosion_appeared = nil
	return game_object
end

-- Canned Strawberry Shortcake
SMODS.Joker({
	key = "canned_strawberry_shortcake",
	loc_txt = {
		name = "Canned Strawberry Shortcake",
		text = {
			"{C:attention}Dessert Special:{}",
			"On {C:attention}final hand{} of blind,",
			"earn {C:money}$2{} per hand played",
			"this blind {C:inactive}(Currently: #1#){}",
		},
	},
	atlas = "test",
	pos = { x = 0, y = 0 },
	order = 8,
	cost = 5,
	rarity = 1, -- Common
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = { extra = {} },
	loc_vars = function(self, info_queue, center)
		local hands_played = G.GAME.current_round.hands_played or 0
		return { vars = { hands_played } }
	end,
	calculate = function(self, card, context)
		-- Check if this is the final hand (hands_left == 0)
		if context.joker_main and G.GAME.current_round.hands_left == 0 then
			local hands_played = G.GAME.current_round.hands_played or 0

			if hands_played > 0 then
				-- Give $2 per hand played this blind
				local money_reward = hands_played * 2
				ease_dollars(money_reward)

				return {
					message = "Dessert Special! $" .. money_reward,
					dollars = money_reward,
					colour = G.C.MONEY,
				}
			end
		end
	end,
})

-- Canned Corn Soup
SMODS.Joker({
	key = "canned_corn_soup",
	loc_txt = {
		name = "Canned Corn Soup",
		text = {
			"{C:mult}+Mult{} based on",
			"your current {C:money}money{}.",
			"Currently: {C:mult}+#1#{} Mult",
		},
	},
	atlas = "test",
	pos = { x = 0, y = 0 },
	order = 7,
	cost = 4,
	rarity = 1, -- Common
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = { extra = {} },
	loc_vars = function(self, info_queue, center)
		-- Convert big number to regular number for comparison
		local money = to_number(G.GAME.dollars) or 0
		local mult_bonus = 0

		-- Calculate mult based on money
		if money <= -10 then
			mult_bonus = 40
		elseif money <= -5 then
			mult_bonus = 30
		elseif money == 0 then
			mult_bonus = 20
		elseif money <= 10 then
			mult_bonus = 15
		elseif money <= 20 then
			mult_bonus = 12
		elseif money <= 30 then
			mult_bonus = 8
		elseif money <= 40 then
			mult_bonus = 5
		elseif money <= 50 then
			mult_bonus = 2
		else
			mult_bonus = 1
		end

		return { vars = { mult_bonus } }
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			-- Convert big number to regular number for comparison
			local money = to_number(G.GAME.dollars) or 0
			local mult_bonus = 0

			-- Calculate mult based on current money
			if money <= -10 then
				mult_bonus = 40
			elseif money <= -5 then
				mult_bonus = 30
			elseif money == 0 then
				mult_bonus = 20
			elseif money <= 10 then
				mult_bonus = 15
			elseif money <= 20 then
				mult_bonus = 12
			elseif money <= 30 then
				mult_bonus = 8
			elseif money <= 40 then
				mult_bonus = 5
			elseif money <= 50 then
				mult_bonus = 2
			else
				mult_bonus = 1
			end

			if mult_bonus > 0 then
				return {
					message = localize({ type = "variable", key = "a_mult", vars = { mult_bonus } }),
					mult_mod = mult_bonus,
				}
			end
		end
	end,
})
-- Rerollercoaster Tycoon
SMODS.Joker({
	key = "rerollercoaster_tycoon",
	loc_txt = {
		name = "Rerollercoaster Tycoon",
		text = {
			"{C:attention}#1#{} free {C:green}Reroll",
			"per shop",
			"{C:inactive}(Currently {C:green}#2#{C:inactive} free rerolls){}",
		},
	},
	atlas = "test",
	pos = { x = 0, y = 0 },
	order = 26,
	cost = 6,
	rarity = 2, -- Uncommon
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	unlocked = true,
	discovered = true,
	config = { extra = { rerolls = 1, free_rerolls = 0 } },
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.rerolls or 1, card.ability.extra.free_rerolls or 0 } }
	end,
	calculate = function(self, card, context)
		-- Add a free reroll at the start of each round
		if context.setting_blind and not context.blueprint then
			card.ability.extra.free_rerolls = card.ability.extra.free_rerolls + 1
			card_eval_status_text(card, "extra", nil, nil, nil, {
				message = "+1 Free Reroll",
				colour = G.C.GREEN,
			})
			return {
				message = "Free rerolls: " .. card.ability.extra.free_rerolls,
				colour = G.C.FILTER,
			}
		end
	end,
})

-- Override the reroll function to use free rerolls first
local original_reroll_shop = G.FUNCS.reroll_shop
G.FUNCS.reroll_shop = function(e)
	-- Check if we have any Rerollercoaster Tycoon jokers with free rerolls
	local free_reroll_used = false

	for i = 1, #G.jokers.cards do
		local joker = G.jokers.cards[i]
		if joker.config.center.key == "j_rerollercoaster_tycoon" and joker.ability.extra.free_rerolls > 0 then
			-- Use a free reroll
			joker.ability.extra.free_rerolls = joker.ability.extra.free_rerolls - 1
			free_reroll_used = true

			-- Show feedback
			card_eval_status_text(joker, "extra", nil, nil, nil, {
				message = "Free Reroll Used!",
				colour = G.C.GREEN,
			})

			break -- Only use one free reroll per click
		end
	end

	-- If we used a free reroll, don't charge money
	if free_reroll_used then
		-- Manually trigger the shop reroll without cost
		local cost = G.GAME.current_round.reroll_cost or 5
		G.GAME.current_round.reroll_cost_increase = G.GAME.current_round.reroll_cost_increase or 2

		-- Reroll the shop
		G.shop_jokers:remove()
		G.shop_booster:remove()
		G.shop_vouchers:remove()

		-- Create new shop items
		for i = 1, G.shop_jokers.config.card_limit do
			local card = create_card("Joker", G.shop_jokers, nil, nil, nil, nil, nil, "sho")
			create_shop_card_ui(card, "Joker", G.shop_jokers)
			card.states.visible = false
			G.shop_jokers:emplace(card)
		end

		for i = 1, G.shop_booster.config.card_limit do
			local card = create_card("Booster", G.shop_booster, nil, nil, nil, nil, nil, "sho")
			create_shop_card_ui(card, "Booster", G.shop_booster)
			card.states.visible = false
			G.shop_booster:emplace(card)
		end

		for i = 1, G.shop_vouchers.config.card_limit do
			local card = create_card("Voucher", G.shop_vouchers, nil, nil, nil, nil, nil, "sho")
			create_shop_card_ui(card, "Voucher", G.shop_vouchers)
			card.states.visible = false
			G.shop_vouchers:emplace(card)
		end

		-- Increase the reroll cost for subsequent paid rerolls
		G.GAME.current_round.reroll_cost = cost + G.GAME.current_round.reroll_cost_increase

		-- Play reroll sound
		play_sound("coin2", 1, 0.4)

		-- Update UI
		for k, v in pairs(G.I.CARDAREA) do
			if v.config.type == "shop" then
				v.config.card_limit = #v.cards
			end
		end
	else
		-- No free rerolls available, use original function
		original_reroll_shop(e)
	end
end

--Memento
SMODS.Joker({
	key = "memento",
	loc_txt = {
		name = "Memento",
		text = {
			"{C:attention}Sell{} to remember",
			"when {C:attention}bought{}",
		},
	},
	atlas = "test",
	pos = { x = 0, y = 0 },
	order = 9,
	cost = 12,
	rarity = 3, -- Legendary
	blueprint_compat = false,
	eternal_compat = false, -- Can't be eternal since selling is the mechanic
	perishable_compat = false, -- Too powerful for perishable
	unlocked = true,
	discovered = true,
	config = { extra = { has_saved = false } },
	loc_vars = function(self, info_queue, center)
		local has_saved = center.ability.extra.has_saved
		return { vars = { has_saved and "State Saved" or "No Save" } }
	end,
	add_to_deck = function(self, card, from_debuff)
		-- Save state when bought/added to deck
		if G.STAGE == G.STAGES.RUN then
			-- Save current run state (same as DebugPlus)
			save_run()
			compress_and_save(G.SETTINGS.profile .. "/" .. "memento_save.jkr", G.ARGS.save_run)

			card.ability.extra.has_saved = true

			-- Show confirmation message
			card_eval_status_text(card, "extra", nil, nil, nil, {
				message = "State Remembered!",
				colour = G.C.FILTER,
			})
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		-- Restore state when sold/removed from deck
		if card.ability.extra.has_saved and G.STAGE == G.STAGES.RUN then
			-- Load the saved state (same as DebugPlus)
			G:delete_run()
			G.SAVED_GAME = get_compressed(G.SETTINGS.profile .. "/" .. "memento_save.jkr")
			if G.SAVED_GAME ~= nil then
				G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME)
			end

			-- Show message before reverting
			card_eval_status_text(card, "extra", nil, nil, nil, {
				message = "Reverting to Memory...",
				colour = G.C.RED,
			})

			-- Small delay then restart with saved state
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 1.0,
				func = function()
					G:start_run({
						savetext = G.SAVED_GAME,
					})
					return true
				end,
			}))
		end
	end,
})
