#!/usr/bin/env bash
# Bootstrap de Neovim para Arch Linux.
# Uso: ./bootstrap.sh          (núcleo)
#      ./bootstrap.sh --full   (núcleo + toolchains extra: Java, PHP, .NET, LaTeX...)
set -euo pipefail

NVIM_DIR="$HOME/.config/nvim"
FULL=0

for arg in "$@"; do
    case "$arg" in
    --full) FULL=1 ;;
    -h | --help)
        echo "uso: bootstrap.sh [--full]"
        exit 0
        ;;
    *)
        echo "opción desconocida: $arg"
        exit 1
        ;;
    esac
done

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[aviso]\033[0m %s\n' "$*"; }

[ "$(id -u)" -ne 0 ] || {
    echo "No lo ejecutes como root (usa tu usuario normal)."
    exit 1
}
command -v pacman >/dev/null || {
    echo "Este script es solo para Arch Linux."
    exit 1
}
[ -f "$NVIM_DIR/init.lua" ] || {
    echo "No existe $NVIM_DIR/init.lua. Clona tu repo en $NVIM_DIR primero."
    exit 1
}

# ── 1. Paquetes del sistema ───────────────────────────────────────
# Siempre -Syu: en Arch no se instalan paquetes sueltos sobre un sistema desactualizado.
CORE=(
    neovim git base-devel curl wget unzip tar gzip
    ripgrep fd nodejs npm python python-pip
    tree-sitter-cli go ruby
    xclip wl-clipboard
    ttf-jetbrains-mono-nerd
    firefox
)

EXTRA=(jdk-openjdk php composer dotnet-sdk zathura zathura-pdf-mupdf texlive-latex texlive-binextra)
# Avante compila crates en Rust: cargo es obligatorio (rustup ya lo trae)
if ! pacman -Qq rustup >/dev/null 2>&1; then CORE+=(rust); fi

PKGS=("${CORE[@]}")
[ "$FULL" -eq 1 ] && PKGS+=("${EXTRA[@]}")

log "Actualizando el sistema e instalando dependencias"
sudo pacman -Syu --needed "${PKGS[@]}"

# ── 2. Config de markdownlint (viaja dentro del repo) ─────────────
if [ -f "$NVIM_DIR/markdownlint-cli2.yaml" ] && [ ! -e "$HOME/.markdownlint-cli2.yaml" ]; then
    log "Enlazando ~/.markdownlint-cli2.yaml"
    ln -s "$NVIM_DIR/markdownlint-cli2.yaml" "$HOME/.markdownlint-cli2.yaml"
fi

# ── 3. Plugins (lazy.nvim) ────────────────────────────────────────
# Con lazy-lock.json se restauran las versiones exactas; sin él, se instala lo último.
if [ -f "$NVIM_DIR/lazy-lock.json" ]; then
    log "Restaurando plugins desde lazy-lock.json"
    nvim --headless "+Lazy! restore" +qa
else
    log "Instalando plugins (no hay lazy-lock.json)"
    nvim --headless "+Lazy! sync" +qa
fi
log "Compilando avante.nvim (puede tardar varios minutos)"
nvim --headless "+Lazy! build avante.nvim" +qa ||
    warn "avante no compiló; abre nvim y ejecuta :Lazy build avante.nvim"

# ── 4. Parsers de Tree-sitter ─────────────────────────────────────
log "Compilando parsers de Tree-sitter"
nvim --headless "+Lazy! load nvim-treesitter" "+TSUpdateSync" +qa ||
    warn "Tree-sitter no terminó limpio; abre nvim y ejecuta :TSUpdate"

# ── 5. Herramientas de Mason (LSP, formatters, linters, debuggers) ─
log "Instalando herramientas de Mason (puede tardar varios minutos)"
MASON_LUA="$(mktemp --suffix=.lua)"
trap 'rm -f "$MASON_LUA"' EXIT

cat >"$MASON_LUA" <<'LUA'
local packages = {
  -- LSP
  "asm-lsp", "bash-language-server", "clangd", "css-lsp", "emmet-ls", "gopls",
  "html-lsp", "intelephense", "jdtls", "kotlin-language-server",
  "lua-language-server", "marksman", "nimlangserver", "omnisharp",
  "powershell-editor-services", "pyright", "rust-analyzer", "solargraph",
  "sqlls", "sqls", "texlab", "typescript-language-server",
  -- Formatters y linters
  "black", "clang-format", "google-java-format", "ktlint", "markdownlint-cli2",
  "php-cs-fixer", "prettier", "rubyfmt", "shfmt", "sql-formatter", "sqlfluff",
  "stylelint", "stylua", "taplo", "yamlfmt",
  -- Debuggers
  "codelldb", "delve", "java-debug-adapter", "java-test", "js-debug-adapter",
}

local ok_lazy, lazy = pcall(require, "lazy")
if ok_lazy then lazy.load({ plugins = { "mason.nvim" } }) end

local ok, registry = pcall(require, "mason-registry")
if not ok then
  io.stderr:write("mason-registry no disponible\n")
  vim.cmd("cquit 1")
  return
end

local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(60000, function() return refreshed end, 200)

local unknown = {}
for _, name in ipairs(packages) do
  local found, pkg = pcall(registry.get_package, name)
  if not found then
    table.insert(unknown, name)
  elseif not pkg:is_installed() and not pkg:is_installing() then
    io.stdout:write("  instalando " .. name .. "\n")
    pkg:install()
  end
end

vim.wait(900000, function()
  for _, name in ipairs(packages) do
    local found, pkg = pcall(registry.get_package, name)
    if found and pkg:is_installing() then return false end
  end
  return true
end, 500)

local missing = {}
for _, name in ipairs(packages) do
  local found, pkg = pcall(registry.get_package, name)
  if found and not pkg:is_installed() then table.insert(missing, name) end
end

if #unknown > 0 then io.stdout:write("No existen en el registro: " .. table.concat(unknown, ", ") .. "\n") end
if #missing > 0 then
  io.stdout:write("Fallaron (¿falta su toolchain?): " .. table.concat(missing, ", ") .. "\n")
end
vim.cmd(#missing > 0 and "cquit 2" or "qa")
LUA

nvim --headless "+luafile $MASON_LUA" || warn "Algunas herramientas de Mason no se instalaron (ver lista arriba). Prueba ./bootstrap.sh --full"

# ── 6. Verificación final ─────────────────────────────────────────
log "Verificación"
MASON_BIN="$HOME/.local/share/nvim/mason/bin"
ok=1
for c in nvim git node npm rg fd tree-sitter; do
    if command -v "$c" >/dev/null; then echo "  ✓ $c"; else
        echo "  ✗ $c (falta)"
        ok=0
    fi
done
for c in prettier marksman markdownlint-cli2; do
    if [ -x "$MASON_BIN/$c" ]; then echo "  ✓ $c (mason)"; else
        echo "  ✗ $c (mason, falta)"
        ok=0
    fi
done
[ -d "$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app/node_modules" ] &&
    echo "  ✓ markdown-preview (servidor node)" ||
    {
        echo "  ✗ markdown-preview sin node_modules"
        ok=0
    }

if [ "$ok" -eq 1 ]; then
    log "Listo. Abre nvim y todo debería estar operativo."
else
    warn "Hay piezas pendientes. Revisa los ✗ de arriba."
fi
