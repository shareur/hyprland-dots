-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================
-- User environment overrides template.
-- Keep this file for personal env additions that should survive updates.

-- Examples:
-- hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- hl.env("GDK_SCALE", "1")
-- hl.env("QT_SCALE_FACTOR", "1")
hl.env("WEATHER_UNITS", "metric")

-- Expose Flatpak desktop entries and personal command wrappers.
local home = os.getenv("HOME")
local function prepend_path(name, entries, fallback)
  local value = os.getenv(name) or fallback
  for _, entry in ipairs(entries) do
    if not (":" .. value .. ":"):find(":" .. entry .. ":", 1, true) then
      value = entry .. ":" .. value
    end
  end
  hl.env(name, value)
end
prepend_path("XDG_DATA_DIRS", {"/var/lib/flatpak/exports/share", home .. "/.local/share/flatpak/exports/share"}, "/usr/local/share:/usr/share")
prepend_path("PATH", {home .. "/.local/bin"}, "/usr/local/bin:/usr/bin:/bin")

-- BEGIN ubuntu-bootstrap fcitx5
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
hl.env("GLFW_IM_MODULE", "ibus")
hl.env("INPUT_METHOD", "fcitx")
-- END ubuntu-bootstrap fcitx5
