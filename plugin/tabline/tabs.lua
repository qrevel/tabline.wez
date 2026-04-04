local config = require('tabline.config')
local util = require('tabline.util')
local extension = require('tabline.extension')

local M = {}
local parts_by_tab_id = {}

local left_tab_separator = { Text = config.opts.options.tab_separators.left or config.opts.options.tab_separators }
local right_tab_separator = { Text = config.opts.options.tab_separators.right or config.opts.options.tab_separators }
local active_attributes, inactive_attributes, active_separator_attributes, inactive_separator_attributes =
  {}, {}, {}, {}
local tab_active, tab_inactive = {}, {}

local function create_attributes(tab, hover)
  local colors = config.theme.tab
  for _, ext in pairs(extension.extensions) do
    if ext.theme and ext.theme.tab then
      colors = util.deep_extend(util.deep_copy(colors), ext.theme.tab)
    end
  end
  local active_fg = colors.active.fg
  local inactive_fg = hover and colors.inactive_hover.fg or colors.inactive.fg
  local has_unseen_output = false
  local is_zoomed = tab.active_pane and tab.active_pane.is_zoomed
  for _, pane in ipairs(tab.panes or {}) do
    if pane.has_unseen_output then
      has_unseen_output = true
      break
    end
  end
  if is_zoomed then
    active_fg = config.theme.colors.ansi[2]
    inactive_fg = config.theme.colors.ansi[2]
  elseif has_unseen_output then
    inactive_fg = config.theme.colors.ansi[3]
  end
  active_attributes = {
    { Foreground = { Color = active_fg } },
    { Background = { Color = colors.active.bg } },
    { Attribute = { Intensity = 'Bold' } },
  }
  inactive_attributes = {
    { Foreground = { Color = inactive_fg } },
    { Background = { Color = hover and colors.inactive_hover.bg or colors.inactive.bg } },
  }
  active_separator_attributes = {
    { Foreground = { Color = colors.active.bg } },
    { Background = { Color = colors.inactive.bg } },
  }
  inactive_separator_attributes = {
    { Foreground = { Color = hover and colors.inactive_hover.bg or colors.inactive.bg } },
    { Background = { Color = colors.inactive.bg } },
  }
end

local function create_tab_content(tab)
  local sections = config.sections
  for _, ext in pairs(extension.extensions) do
    if ext.sections then
      sections = util.deep_extend(util.deep_copy(sections), ext.sections)
    end
  end
  tab_active = util.extract_components(sections.tab_active, active_attributes, tab)
  tab_inactive = util.extract_components(sections.tab_inactive, inactive_attributes, tab)
end

local function tabs(tab)
  local result = {}

  if #tab_active > 0 and tab.is_active then
    util.insert_elements(result, active_separator_attributes)
    table.insert(result, right_tab_separator)
    util.insert_elements(result, active_attributes)
    util.insert_elements(result, tab_active)
    util.insert_elements(result, active_separator_attributes)
    table.insert(result, left_tab_separator)
  elseif #tab_inactive > 0 then
    util.insert_elements(result, inactive_separator_attributes)
    table.insert(result, right_tab_separator)
    util.insert_elements(result, inactive_attributes)
    util.insert_elements(result, tab_inactive)
    util.insert_elements(result, inactive_separator_attributes)
    table.insert(result, left_tab_separator)
  end
  return result
end

M.set_title = function(tab, hover)
  if not config.opts.options.tabs_enabled then
    return
  end
  create_attributes(tab, hover)
  create_tab_content(tab)
  local parts = tabs(tab)
  parts_by_tab_id[tab.tab_id] = parts
  return parts
end

function M.get_parts(tab_id)
  return parts_by_tab_id[tab_id]
end

return M
