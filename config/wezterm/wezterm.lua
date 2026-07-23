-- WezTerm (macOS) — minimal starter, extend as needed
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 13.0
config.hide_tab_bar_if_only_one_tab = true

return config
