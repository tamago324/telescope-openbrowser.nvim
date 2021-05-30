# telescope-openbrowser.nvim

Integration for [open-browser.vim](https://github.com/tyru/open-browser.vim) with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

## Requirements

* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* [open-browser.vim](https://github.com/tyru/open-browser.vim)


## Installation

```
Plug 'tamago324/telescope-openbrowser.nvim'
Plug 'tyru/open-browser.vim'


-- Setup
lua require 'telescope'.setup {
  -- ...
  extensions = {
    -- Add bookmark urls
    openbrowser = {
      bookmarks = {
        ['luv docs'] = 'https://github.com/luvit/luv/blob/master/docs.md',
      },
      bookmark_filepath = '~/config/nvim/telescope_openbrowser_bookamarks'
    }
  }
}

lua require'telescope'.load_extensions('openbrowser')
```

## Usage

```
lua require 'telescope'.extensions.openbrowser.list{}
```

or

```
Telescope openbrowser list
```

## Configuration

Edit `~/.config/nvim/telescope_openbrowser_bookamarks`

```
luv docs	https://github.com/luvit/luv/blob/master/docs.md
# this is comment
```

* Use a tab character to separate the name from the URL
* Lines beginning with `#` will be ignored

## License

MIT

