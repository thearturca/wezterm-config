-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "pwsh.exe" }
end

config.font = wezterm.font("Hack Nerd Font Mono")
local theme = require("lua/rose-pine").moon
config.colors = theme.colors()
config.window_frame = theme.window_frame()
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.win32_system_backdrop = "Acrylic"
config.max_fps = 240

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 750 }

config.tab_bar_at_bottom = true

local sessionizer = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer.wezterm")
local history = wezterm.plugin.require("https://github.com/mikkasendke/sessionizer-history")

local function isEntryActive(entryId)
	local all_workspaces = wezterm.mux.get_workspace_names()
	for _, v in ipairs(all_workspaces) do
		if entryId == v then
			return true
		end
	end
	return false
end

local schema = {
	options = { callback = history.Wrapper(sessionizer.DefaultCallback), prompt = "Workspaces: " },
	history.MostRecentWorkspace({}),
	sessionizer.DefaultWorkspace({ label_overwrite = "🏠 Home" }),
	sessionizer.AllActiveWorkspaces({}),

	processing = {
		sessionizer.for_each_entry(function(entry)
			local is_active = isEntryActive(entry.id)
			if entry.label:find("^Recent ") ~= nil then
				entry.label = entry.label:gsub("Recent", "🔙")
			elseif entry.label == "🏠 Home" then
				entry.label = "🏠 Home"
			elseif is_active then
				entry.label = "📂 " .. entry.label
			else
				entry.label = "📁 " .. entry.label
			end
		end),
		sessionizer.for_each_entry(function(entry)
			entry.label = entry.label:gsub(wezterm.home_dir, "~")
		end),
		sessionizer.for_each_entry(function(entry)
			if entry.label == "🏠 Home" or entry.label:find("^🔙") then
				entry.label = wezterm.format({
					{
						Foreground = {
							Color = "#e0def4",
						},
					},
					{ Text = entry.label },
				})
			elseif entry.label:find("^📂 ") then
				entry.label = wezterm.format({
					{
						Foreground = {
							Color = "#c4a7e7",
						},
					},
					{ Text = entry.label },
				})
			else
				entry.label = wezterm.format({
					{ Foreground = {
						Color = "#908caa",
					} },
					{ Text = entry.label },
				})
			end
		end),
	},
}

local workspaces = require("lua/search-workspace_local")

local fd_path = "/usr/bin/fd"

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	fd_path = "fd"
end

for _, workspace in ipairs(workspaces) do
	table.insert(schema, sessionizer.FdSearch({ workspace, fd_path = fd_path }))
end

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
