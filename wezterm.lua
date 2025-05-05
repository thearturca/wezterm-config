-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.default_prog = { "pwsh.exe" }
config.font = wezterm.font("Hack Nerd Font Mono")

local theme = require("lua/rose-pine").main
config.colors = theme.colors()
config.window_frame = theme.window_frame()
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 750 }

config.tab_bar_at_bottom = true

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local history = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-history")

local schema = {
	options = { callback = history.Wrapper(sessionizer.DefaultCallback) },
	history.MostRecentWorkspace({}),
	sessionizer.DefaultWorkspace({}),
	sessionizer.AllActiveWorkspaces({}),

	sessionizer.FdSearch({ "f:/projects", fd_path = "fd" }),

	processing = {
		sessionizer.for_each_entry(
			function(entry) -- recolors labels and replaces the absolute path to the home directory with ~
				entry.label = wezterm.format({
					{ Foreground = { Color = "#c4a7e7" } },
					{ Text = entry.label:gsub(wezterm.home_dir, "~") },
				})
			end
		),
	},
}

config.keys = {
	{
		key = "r",
		mods = "LEADER",
		action = sessionizer.show(schema),
	},
	{
		key = "m",
		mods = "LEADER",
		action = history.switch_to_most_recent_workspace,
	},
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		key = "Enter",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "LeftArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},

	{
		key = "RightArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},

	{
		key = "UpArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},

	{
		key = "DownArrow",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "q",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "w",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "p",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(-1),
	},
}

-- and finally, return the configuration to wezterm
return config
