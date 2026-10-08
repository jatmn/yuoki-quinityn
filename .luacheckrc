stds.factorio = {
  read_globals = {
    "defines", "log", "settings",
    table = {fields = {deepcopy = {}}},
  },
}
std = "lua52+factorio"
not_globals = {"io", "os", "dofile", "loadfile", "coroutine"}
max_line_length = false
exclude_files = {"build/**", ".cache/**"}

-- Factorio's data and runtime environments expose different globals.
files["data*.lua"].globals = {"data"}
-- Existing heavy-oil opt-out has an intentionally empty branch; the bridge loop
-- retains an unused index. Keep these two baseline warnings local to this file.
files["data-final-fixes.lua"].ignore = {"542", "213/i"}
files["settings*.lua"].globals = {"data"}
files["prototypes/**"].globals = {"data"}
files["control.lua"].globals = {"game", "storage"}
files["control.lua"].read_globals = {"script", "prototypes", "helpers", "remote", "rendering"}
files["scripts/**"].globals = {"game", "storage"}
files["scripts/**"].read_globals = {"script", "prototypes", "helpers", "remote", "rendering"}
files["tests/**"].globals = {"game", "storage"}
files["tests/**"].read_globals = {"script", "prototypes", "helpers", "remote", "rendering"}
