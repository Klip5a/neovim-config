----------------------------------------------------------
-- 1) Инициализация пакетов
----------------------------------------------------------
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Менеджер плагинов
  
  -- Подсветка синтаксиса
  use 'nvim-treesitter/nvim-treesitter'
  
  -- Настройка LSP
  use 'neovim/nvim-lspconfig'
  
  -- Автодополнение
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'saadparwaiz1/cmp_luasnip'
  use 'L3MON4D3/LuaSnip'
  
  -- Вспомогательные инструменты
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim' -- Поиск файлов
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- Для иконок (опционально)
    }
  }
  use 'windwp/nvim-autopairs'    -- Автозакрытие скобок
  use 'prettier/vim-prettier'    -- Форматирование кода (JS/TS/и т.д.)
  use 'ojroques/vim-oscyank'     -- Копирование в системный буфер обмена
end)

----------------------------------------------------------
-- 2) Общие настройки редактора
----------------------------------------------------------
vim.opt.number = true           -- Номера строк
vim.opt.relativenumber = true   -- Относительные номера строк
vim.opt.expandtab = true        -- Пробелы вместо табов
vim.opt.shiftwidth = 4          -- Размер "шага" табуляции
vim.opt.tabstop = 4
vim.opt.smartindent = true      -- Умный отступ
vim.opt.wrap = false            -- Без переноса строк
vim.opt.termguicolors = true    -- Цвета терминала

----------------------------------------------------------
-- 3) Настройка LSP-серверов
----------------------------------------------------------
local lspconfig = require('lspconfig')

-- PHP (intelephense)
lspconfig.intelephense.setup{}

-- Python (pyright)
lspconfig.pyright.setup{}

-- JS/TS (ts_ls)
lspconfig.ts_ls.setup({
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json" },
  root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
})

-- *** C/C++ (clangd) ***
lspconfig.clangd.setup({
  cmd = { "clangd" },
  -- какие типы файлов обрабатываем
  filetypes = { "c", "cpp", "objc", "objcpp" },
  -- как определить корневую директорию проекта
  root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git", "."),
})

----------------------------------------------------------
-- 4) Настройка автодополнения (nvim-cmp)
----------------------------------------------------------
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }),
})

----------------------------------------------------------
-- 5) Настройка Treesitter (подсветка синтаксиса)
----------------------------------------------------------
require('nvim-treesitter.configs').setup {
  ensure_installed = { "c", "cpp", "lua", "python", "php", "javascript", "typescript" }, 
  highlight = {
    enable = true,
  },
}

----------------------------------------------------------
-- 6) Telescope (поиск файлов)
----------------------------------------------------------
vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope live_grep<CR>',  { noremap = true, silent = true })

----------------------------------------------------------
-- 7) Nvim-tree (файловый менеджер)
----------------------------------------------------------
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>f", ":NvimTreeFindFile<CR>", { noremap = true, silent = true })

require("nvim-tree").setup({
  view = {
    width = 30,
    side = "left",
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
  actions = {
    open_file = {
      quit_on_open = true, 
    },
  },
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")

    local opts = function(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    vim.keymap.set("n", "o", api.node.open.edit, opts("Open Alternative"))
    vim.keymap.set("n", "v", api.node.open.vertical, opts("Open Vertical Split"))
    vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open Horizontal Split"))
    vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Node"))
    vim.keymap.set("n", "l", api.node.open.edit, opts("Open Node"))
  end,
})

----------------------------------------------------------
-- 8) Автозакрытие скобок
----------------------------------------------------------
require('nvim-autopairs').setup{}

