-- A starting suit would bypass the required visit gate before any research.
local suit = data.raw["bool-setting"]["yuoki-start-with-yi-suit"]
suit.forced_value = false
suit.hidden = true
-- Quinityn stages both Fatmice modes through research instead of a startup choice.
-- Let Engines define its filter items/recipes; restore the basic mode in final fixes.
local filters = data.raw["bool-setting"]["j_fatmice_behaviour"]
filters.forced_value = true
filters.hidden = true
