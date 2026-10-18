local simulations = {}
for stage in pairs(require("scripts.biology-processes")) do
  simulations[stage] = {
    planet = "quinityn",
    checkboard = false,
    init = string.format('storage.biology_demo = require("__yuoki-quinityn__/scripts/biology-demo").start(%q)', stage),
    update = 'require("__yuoki-quinityn__/scripts/biology-demo").update(storage.biology_demo)',
  }
end
return simulations
