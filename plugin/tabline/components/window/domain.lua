local wezterm = require('wezterm')
local util = require('tabline.util')

return {
  default_opts = {
    domain_to_icon = {
      default = wezterm.nerdfonts.md_monitor,
      ssh = wezterm.nerdfonts.md_ssh,
      sshmux = wezterm.nerdfonts.md_ssh,
      wsl = wezterm.nerdfonts.md_microsoft_windows,
      docker = wezterm.nerdfonts.md_docker,
      unix = wezterm.nerdfonts.cod_terminal_linux,
    },
    domain_name_to_icon = {},
  },
  update = function(window, opts)
    local domain_name = window:active_pane():get_domain_name()
    local domain_type, new_domain_name = domain_name:match('^([^:]+):?(.*)')
    local domain_name_to_icon = opts.domain_name_to_icon or {}
    local domain_to_icon = opts.domain_to_icon or {}
    domain_type = (domain_type or 'default'):lower()
    new_domain_name = new_domain_name ~= '' and new_domain_name or domain_name

    if opts.icons_enabled and opts.domain_to_icon then
      local icon = domain_name_to_icon[new_domain_name]
        or domain_to_icon[domain_type]
        or domain_name_to_icon.default
        or domain_to_icon.default
      util.overwrite_icon(opts, icon)
    end
    return new_domain_name
  end,
}
