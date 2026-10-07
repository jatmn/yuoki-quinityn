-- A starting suit would bypass the required visit gate before any research.
local suit=data.raw["bool-setting"]["yuoki-start-with-yi-suit"]
suit.forced_value=false
suit.hidden=true
