# Notatki do tej konfiguracji

Rzeczy, które łatwo zapomnieć, a które nie wynikają wprost z kodu.
Sam `init.lua` jest udokumentowany komentarzami — tu są tylko decyzje i procedury.

## Gdzie dopisać nowe narzędzie

Zasada nadrzędna: **mason instaluje to, co zadeklarowane w configu — nie odwrotnie.**
Jeśli doinstalujesz coś ręcznie przez `:Mason` i nie dopiszesz tego tutaj,
świeży `git clone` na nowej maszynie tego nie odtworzy.

Trzy miejsca, zależnie od rodzaju pakietu. Zakładka w `:Mason`
(`LSP` / `Formatter` / `Linter` / `DAP`) mówi, które wybrać.

### Serwer LSP → `init.lua`, tabela `servers`

```lua
local servers = {
  gopls = {},
  rust_analyzer = {},   -- <- tu
```

Nazwa w konwencji **lspconfig**, nie mason (`ts_ls`, nie `typescript-language-server`) —
`mason-lspconfig` tłumaczy ją automatycznie. Pełna lista: `:help lspconfig-all`.

Jedno miejsce załatwia dwie rzeczy: mason instaluje pakiet **i** serwer zostaje włączony.
Gdy serwer wymaga konfiguracji, zamiast `{}` podaj tabelę — wzorem `lua_ls` niżej.

### Formatter / linter → `init.lua`, `vim.list_extend(ensure_installed, {...})`

```lua
vim.list_extend(ensure_installed, {
  'stylua',
  'goimports',
  'prettier',   -- <- tu
})
```

Tu używa się **nazwy pakietu mason** (tej z `:Mason`) — nie ma czego tłumaczyć.
Sam pakiet to połowa roboty: formatter trzeba jeszcze podpiąć pod filetype w
`formatters_by_ft` w bloku conform.nvim (`init.lua`), inaczej nic go nie odpali.

### Debugger (DAP) → `lua/kickstart/plugins/debug.lua`, `ensure_installed`

```lua
ensure_installed = {
  'delve',
  'codelldb',   -- <- tu
},
```

### Weryfikacja

Zrestartuj nvima — `mason-tool-installer` doinstaluje brakujące sam. Potem:

- `:Mason` — czy pakiet jest zainstalowany
- `:checkhealth lsp` — czy serwer się podpina

## Decyzje, które warto pamiętać

### nvim-treesitter siedzi na gałęzi `main`, nie `master`

`master` został zamrożony (ostatni commit z kodem: 2025-05) i od 2026-03 jawnie
**nie wspiera Neovima 0.12**. Uwaga przy czytaniu dokumentacji w sieci: większość
poradników opisuje stare API z `master` (`ensure_installed`, `highlight = { enable = true }`),
którego tu **nie ma**. Na `main`:

- parsery instaluje się jawnie przez `require('nvim-treesitter').install {...}`
- podświetlanie i wcięcia włącza autocmd `FileType` w `init.lua` (`vim.treesitter.start()`)
- lazy-loading nie jest wspierany — stąd `lazy = false`
- wymagany `tree-sitter-cli >= 0.26.1` (zainstalowany przez brew jako `tree-sitter-cli`,
  **nie** `tree-sitter` — ta formuła to sama biblioteka)

Nowy parser: dopisz do listy w `ts.install {...}` w `init.lua`. Nieznane języki i tak
doinstalują się same przy pierwszym otwarciu pliku.

### Debugowanie TS/JS zostało usunięte

Było oparte na `mxsdev/nvim-dap-vscode-js` (porzucony od 2023-03) i na buildzie
`microsoft/vscode-js-debug`, który wymagał npm przy każdym update, Node >= 20
i brudził `package-lock.json`, blokując aktualizacje w lazy.

Konfiguracja (pwa-node, pwa-chrome pod Angulara na `localhost:4200`) jest w historii
gita — commit `ed765e9`. Gdyby wracać, to raczej przez ręczną definicję adaptera
na pakiecie `js-debug-adapter` z mason, bez tego martwego mostu.

### Domyślny Node to 18.10.0 (po EOL)

Przez `nvm` masz też 20, 22 i 24. Nic w tej konfiguracji już tego nie potrzebuje,
ale jeśli jakiś build zacznie się wywalać na
`SyntaxError: Invalid regular expression flags` — to jest ten objaw. Za stary Node.

### Push idzie przez alias SSH `git_rudolfowski`

Generyczny wpis `Host github.com` w `~/.ssh/config` celuje w klucz konta **lulu-soft**.
To repo świadomie go omija — remote wskazuje na `git_rudolfowski:...`.
Nie przestawiaj go na `github.com`, bo push pójdzie z niewłaściwego konta.

### Formatowaniem rządzi conform.nvim — także Go

Jedno miejsce (`formatters_by_ft` w `init.lua`), jeden `<leader>f`, format przy zapisie
tylko dla języków z tej tabeli + C/C++ (przez clangd). Go formatuje conform
(`goimports`), **nie** go.nvim: jego `go.format.goimports()` to asynchroniczny code
action gopls, który zmieniał bufor już po zapisie — plik zostawał niesformatowany.

### Formatowanie C/C++: `~/.clang-format` to symlink do `.clang-format` z repo

Formatuje clangd (conform bez formattera dla C/C++ → `lsp_format = 'fallback'`). Styl LLVM z `IndentWidth: 4` siedzi w
`.clang-format` w tym repo, a `~/.clang-format` musi na niego wskazywać — clangd
szuka pliku w górę drzewa, a `--fallback-style` przyjmuje tylko nazwę stylu, nie YAML.
Na nowej maszynie: `ln -s ~/.config/nvim/.clang-format ~/.clang-format`.
Bez symlinka wyjdzie czyste LLVM (wcięcie 2). Projektowy `.clang-format` ma pierwszeństwo.
