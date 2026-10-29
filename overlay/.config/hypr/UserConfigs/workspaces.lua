-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User workspace rules for Lua workflow.
-- PersistWorkspaceLayout.sh writes workspace layout rules into this file.
-- Keep custom hl.workspace_rule(...) entries here so upgrades preserve them.

-- Example:
-- hl.workspace_rule({
--     workspace = "1",
--     monitor = "eDP-1",
--     layout = "dwindle",
-- })
hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", layout = "scrolling" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1", layout = "scrolling" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", layout = "master" })
hl.workspace_rule({ workspace = "5", monitor = "HDMI-A-1", layout = "dwindle" })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1", layout = "monocle" })
hl.workspace_rule({ workspace = "6", monitor = "FALLBACK", layout = "scrolling" })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1", layout = "dwindle" })
hl.workspace_rule({ workspace = "7", monitor = "FALLBACK", layout = "dwindle" })
hl.workspace_rule({ workspace = "8", monitor = "Unknown-1", layout = "scrolling" })
hl.workspace_rule({ workspace = "2", monitor = "Unknown-1", layout = "master" })
