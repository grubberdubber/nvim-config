```markdown
# nvim-config — Staff Engineer Setup

NvChad v2.5 optimizado para auditorías de seguridad, pentesting y desarrollo profesional en 30+ lenguajes. **Sin configuración manual post-instalación.** Los permisos de Mason y la interfaz dinámica se aplican automáticamente.

## Instalación en entorno nuevo (una sola vez)

```bash
# 1. Dependencias base (Debian/Kali/Ubuntu)
sudo apt update && sudo apt install -y \
  neovim git curl unzip nodejs npm \
  python3 python3-pip ripgrep fd-find build-essential

# 2. Lazygit
LAZYGIT_VERSION=$(curl -s "[https://api.github.com/repos/jesseduffield/lazygit/releases/latest](https://api.github.com/repos/jesseduffield/lazygit/releases/latest)" \
  | grep '"tag_name"' | cut -d'"' -f4)
curl -Lo /tmp/lazygit.tar.gz \
  "[https://github.com/jesseduffield/lazygit/releases/download/$](https://github.com/jesseduffield/lazygit/releases/download/$){LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION#v}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin

# 3. Instalar config
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
git clone [https://github.com/TU_USUARIO/nvim-config](https://github.com/TU_USUARIO/nvim-config) ~/.config/nvim

# 4. Abrir Neovim — Lazy instala todo automáticamente
nvim

```

## Lenguajes Soportados

| Categoría | Lenguajes |
| --- | --- |
| Web / Frontend | HTML, CSS, JavaScript, TypeScript, PHP, Emmet |
| Sistemas / Bajo Nivel | C, C++, Rust, Go, C#, Java, Assembly x86/x64 |
| Scripting & Exploits | Python, Bash, PowerShell, Ruby, Perl |
| Móvil | Swift, Kotlin, Dart/Flutter, Objective-C |
| Ciencia de Datos / DBs | R, Julia, MATLAB, SQL / PL-SQL / T-SQL |
| Funcional | Scala, Lua |

## Atajos — Navegación y Archivos (Oil & Harpoon)

| Atajo | Acción |
| --- | --- |
| `-` | Oil: Abrir directorio actual (Navegación como buffer) |
| `<leader>rf` | Renombrar el archivo actual rápidamente |
| `<leader>ha` | Harpoon: Agregar archivo al menú rápido |
| `<C-e>` | Harpoon: Abrir menú rápido |
| `<leader>1` al `4` | Harpoon: Saltar instantáneamente al archivo 1, 2, 3 o 4 |

## Atajos — Ventanas y Terminal

| Atajo | Acción |
| --- | --- |
| `<leader>q` | Cerrar ventana / panel / terminal actual |
| `<C-\><C-n>` | Terminal: Salir del modo edición al modo normal |
| `<C-h/j/k/l>` | Moverse entre ventanas divididas |

## Atajos — Debugger (Estándar IDE)

| Atajo | Acción |
| --- | --- |
| `F5` | Iniciar / Continuar |
| `F9` | Toggle Breakpoint ● |
| `F10` | Step Over |
| `F11` | Step Into |
| `F12` | Step Out |
| `Shift+F5` | Detener debugger |
| `<leader>B` | Breakpoint condicional ◉ |
| `<leader>du` | Toggle UI del debugger |

## Atajos — General y LSP

| Atajo | Acción |
| --- | --- |
| `<C-g>` | Codeium: Aceptar sugerencia IA |
| `<leader>sr` | Sniprun: Ejecutar línea o bloque visual |
| `<leader>ro` | Iron: Abrir REPL |
| `<leader>db` | Dadbod: Interfaz de Base de Datos |
| `<leader>gg` | Lazygit |
| `gd` | LSP: Ir a definición |
| `K` | LSP: Ver documentación (Hover) |
| `<leader>ca` | LSP: Code actions |
| `<leader>rn` | LSP: Renombrar símbolo en el código |
| `<Tab>/<S-Tab>` | Siguiente / Anterior buffer |
| `Alt+j/k` | Mover línea o selección arriba/abajo |

```

