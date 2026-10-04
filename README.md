# nvim-config — Staff Engineer Setup

NvChad v2.5 para desarrollo profesional en 30+ lenguajes. **Sin configuración manual post-instalación.** Los permisos de Mason se aplican automáticamente.

## Instalación en laptop nueva (una sola vez)

```bash
# 1. Dependencias base
sudo apt update && sudo apt install -y \
  neovim git curl unzip nodejs npm \
  python3 python3-pip ripgrep fd-find build-essential

# 2. Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
  | grep '"tag_name"' | cut -d'"' -f4)
curl -Lo /tmp/lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin

# 3. Instalar config
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
git clone https://github.com/TU_USUARIO/nvim-config ~/.config/nvim

# 4. Abrir Neovim — Lazy instala todo automáticamente
nvim
```

## Lenguajes

| Categoría | Lenguajes |
|---|---|
| Web / Frontend | HTML, CSS, JavaScript, TypeScript, PHP, Emmet |
| Sistemas | C, C++, Rust, Go, C#, Java, Assembly x86/x64 |
| Móvil | Swift, Kotlin, Dart/Flutter, Objective-C |
| Scripting | Python, Bash, PowerShell, Ruby, Perl |
| Ciencia de Datos | R, Julia, MATLAB, SQL / PL-SQL / T-SQL |
| Funcional | Scala, Lua |

## Atajos — Debugger (estándar IDE)

| Atajo | Acción |
|---|---|
| `F5` | Iniciar / Continuar |
| `F9` | Toggle Breakpoint ● |
| `F10` | Step Over |
| `F11` | Step Into |
| `F12` | Step Out |
| `Shift+F5` | Detener debugger |
| `<leader>B` | Breakpoint condicional ◉ |
| `<leader>du` | Toggle UI del debugger |

## Atajos — General

| Atajo | Acción |
|---|---|
| `<leader>sr` / visual | Sniprun: ejecutar |
| `<leader>ro` | Iron: abrir REPL |
| `<leader>rs` / visual | Iron: enviar al REPL |
| `<leader>db` | Dadbod: base de datos |
| `<leader>xx` | Trouble: panel de errores |
| `<leader>gg` | Lazygit |
| `<C-g>` | Codeium: aceptar sugerencia IA |
| `gd` | LSP: ir a definición |
| `K` | LSP: hover docs |
| `<leader>ca` | LSP: code actions |
| `<leader>rn` | LSP: renombrar símbolo |
| `<Tab>/<S-Tab>` | Siguiente/anterior buffer |
| `Alt+j/k` | Mover línea/selección |
