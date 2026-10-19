local simulations = {}
for stage in pairs(require("scripts.tutorial-processes")) do
  simulations[stage] = {
    planet = "quinityn",
    checkboard = false,
    init = string.format(
      'storage.tutorial_demo = require("__yuoki-quinityn__/scripts/tutorial-demo").start(%q)',
      stage
    ),
    update = 'require("__yuoki-quinityn__/scripts/tutorial-demo").update(storage.tutorial_demo)',
  }
end
return simulations
