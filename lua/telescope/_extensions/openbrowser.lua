local actions = require 'telescope.actions'
local actions_state = require 'telescope.actions.state'
local pickers = require 'telescope.pickers'
local sorters = require 'telescope.sorters'
local finders = require 'telescope.finders'
local previewers = require 'telescope.previewers'
local entry_display = require 'telescope.pickers.entry_display'

local conf = require'telescope.config'.values

local a = vim.api
local Path = require'plenary.path'

local bookmarks = {
  -- {
  --   name = url
  -- }
}
local bookmark_filepath = vim.fn.stdpath('config') .. '/' .. 'telescope_openbrowser_bookamarks'

-----------------------------
-- Private
-----------------------------

local read_bookmark_file = function(path)
  local p = Path:new(vim.fn.expand(path))
  if p == nil or not p:exists() then
    return {}
  end

  local res = {}
  for _, line in ipairs(p:readlines()) do
    -- # がついていたらコメント
    if not line:match('^%s*#') then
      local key, val = line:match('^([^\t]+)\t(.*)')
      if key ~= nil and val ~= nil then
        res[key] = val
      end
    end
  end
  return res
end

-----------------------------
-- Export
-----------------------------
local list = function(opts)
  opts = opts or {}

  local list = vim.tbl_extend('force', vim.g.openbrowser_search_engines or {}, bookmarks)
  list = vim.tbl_extend('force', list, read_bookmark_file(bookmark_filepath))

  local names = {}
  local results = {}

  for name in pairs(list) do
    table.insert(results, {
      name = name,
      url = list[name]
    })
    table.insert(names, name)
  end

  local max_name_width = math.max(
    unpack(
      vim.tbl_map(
        function(name)
          return vim.fn.strdisplaywidth(name)
        end, names)))

  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = max_name_width },
      { remaining = true }
    },
  }

  local make_display = function(entry)
    return displayer {
      entry.name,
      {entry.url, 'Comment'}
    }
  end

  pickers.new(opts, {
    prompt_title = 'Openbrowser',
    finder = finders.new_table {
      results = results,
      entry_maker = opts.entry_maker or function(entry)
        return {
          value = entry.name .. ' ' .. entry.url,
          ordinal = entry.name .. ' ' .. entry.url,
          display = make_display,

          name = entry.name,
          url = entry.url,
        }
      end,
    },
    -- previewer = nil,
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = actions_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if entry.url:find('{query}') then
          local key = string.format(':OpenBrowserSmartSearch -%s ', entry.name)
          a.nvim_feedkeys(a.nvim_replace_termcodes(key, true, false, true), 'n', true)
        else
          vim.fn['openbrowser#open'](entry.url)
        end
      end)

      return true
    end,
  }):find()
end

return require'telescope'.register_extension {
  setup = function(ext_config)
    bookmarks = ext_config.bookmarks or {}
    bookmark_filepath = ext_config.bookmark_filepath or nil
  end,
  exports = {
    list = list
  }
}
