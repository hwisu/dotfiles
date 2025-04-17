-- Neovim 설정 및 플러그인 관리 스크립트
-- 변수 설정
local in_vscode = vim.g.vscode ~= nil

-- 보안 취약점 확인 (GHSA-6f9m-hj8h-xjgj)
local function check_security_vulnerability()
  -- Neovim 버전 확인
  local version = vim.version()
  local version_str = string.format("%d.%d.%d", version.major, version.minor, version.patch)

  -- 0.8.3 미만의 버전에서는 보안 경고 표시
  if version.major == 0 and (version.minor < 8 or (version.minor == 8 and version.patch < 3)) then
    vim.notify(
      "보안 경고: 현재 Neovim 버전(" .. version_str .. ")에는 Treesitter 코드 삽입 취약점이 있습니다.\n" ..
      "가능한 빨리 Neovim 0.8.3 이상으로 업그레이드하세요.",
      vim.log.levels.WARN
    )

    -- 안전 조치: 위험한 treesitter 기능 비활성화
    vim.g.loaded_treesitter = 1
    vim.g.loaded_treesitter_query = 1
    vim.g.treesitter_injections_disabled = 1

    return false
  end

  return true
end

-- 보안 취약점 검사 실행
local is_neovim_secure = check_security_vulnerability()

-- 기본 옵션 설정
vim.opt.syntax = "on"
vim.cmd('filetype plugin indent on')
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- lazy.nvim 플러그인 매니저 자동 설치
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- 안정 버전 사용
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 플러그인 설정
require("lazy").setup({
  -- 컬러 스킴
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    config = function()
      require("kanagawa").setup({})
      vim.cmd.colorscheme "kanagawa"
    end,
  },

  -- LSP 설정
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "tsserver", "pyright" },
        automatic_installation = true,
      })
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
      lspconfig.tsserver.setup({})
      lspconfig.pyright.setup({})
    end,
    cond = not in_vscode,
  },

  -- 자동완성
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })
    end,
    cond = not in_vscode,
  },

  -- 파일 탐색기
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
    end,
    cond = not in_vscode,
  },

  -- 파일 검색 및 코드 검색
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end,
    cond = not in_vscode,
  },

  -- 구문 강조
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- 보안 취약점이 있는 버전에서는 안전한 설정으로 구성
      if not is_neovim_secure then
        -- 취약점을 방지하기 위한 최소한의 설정만 사용
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "lua", "vim", "javascript", "typescript", "python", "bash" },
          highlight = { enable = true },
          indent = { enable = true },
          -- 코드 삽입 관련 기능 비활성화
          incremental_selection = { enable = false },
          textobjects = { enable = false },
          -- 주입(injection) 기능 명시적 비활성화
          injections = { enable = false },
        })
      else
        -- 안전한 버전에서 완전한 기능 활성화
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "lua", "vim", "javascript", "typescript", "python", "bash" },
          highlight = { enable = true },
          indent = { enable = true },
          -- 안전하게 추가 기능 사용
          incremental_selection = { enable = true },
          textobjects = { enable = true },
        })
      end
    end,
    cond = not in_vscode and is_neovim_secure,  -- 보안 취약점이 있는 버전에서는 불러오지 않음
  },

  -- Git 통합
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
    cond = not in_vscode,
  },

  -- 상태 표시줄
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
    cond = not in_vscode,
  },
})

-- VSCode 특정 설정
if in_vscode then
  -- VSCode Neovim 특정 키 매핑
  vim.keymap.set('n', '<Space>', '<Cmd>call VSCodeNotify("whichkey.show")<CR>')
  vim.keymap.set('x', '<Space>', '<Cmd>call VSCodeNotify("whichkey.show")<CR>')
end

-- 독립 실행형 Neovim 추가 설정
if not in_vscode then
  -- 키 매핑
  vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
  vim.keymap.set('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
  vim.keymap.set('n', '<leader>h', '<cmd>nohlsearch<cr>', { desc = 'Clear search' })

  -- 커서 위치 기억
  vim.api.nvim_create_autocmd('BufReadPost', {
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lcount = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })
end
