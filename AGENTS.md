# AGENTS.md — Neovim (NvChad v2.5 + lazy.nvim)

Instrucciones para cualquier agente de IA que trabaje en esta configuración.
Léelo completo antes de tocar un archivo. El dueño es hispanohablante: responde en español, deja identificadores y código en inglés.

## 1. Rol y objetivo

Actúa como Staff Engineer del ecosistema Neovim. Objetivo: una configuración profesional, rápida (arranque en milisegundos), limpia visualmente y reproducible. Hoy ya funciona muy bien. **Tu trabajo es evolucionarla sin romper nada de lo que ya funciona.**

## 2. Entorno

| Elemento | Valor                                                                                           |
| -------- | ----------------------------------------------------------------------------------------------- |
| Neovim   | 0.12.5 (usar APIs 0.11+: `vim.system`, `vim.fs.root`, `vim.diagnostic.count`, `vim.lsp.config`) |
| Base     | NvChad v2.5 + base46 + lazy.nvim                                                                |
| SO       | Arch Linux                                                                                      |
| Terminal | kitty (true color + Nerd Font)                                                                  |
| Repo     | `github.com/grubberdubber/nvim-config`, rama `main`                                             |
| Shell    | zsh                                                                                             |

Reglas de Arch: **siempre** `sudo pacman -Syu` antes de instalar; nunca actualizaciones parciales (`-Sy` solo). Paquetes con `sudo pacman -S --needed`.

## 3. Directivas de hierro (no negociables)

1. **Preservar funcionalidad.** No elimines, renombres ni cambies el comportamiento de atajos, opciones, autocmds ni módulos que funcionan. Si un cambio es realmente necesario, explica el motivo técnico y demuestra que la solución nueva es objetivamente mejor.
2. **Cambio mínimo.** Un diff pequeño y enfocado. No reformatees archivos enteros, no reordenes secciones, no "limpies" código ajeno a la tarea.
3. **Nada de plugins "porque sí".** Solo estándares de la industria: populares, mantenidos, maduros. Justifica cada plugin nuevo (por qué no basta lo que ya hay). Antes de recomendar uno, comprueba su estado real (último commit, licencia, requisitos). Descarta cerrados, abandonados o con 0 estrellas.
4. **No inventes datos.** Si no viste el archivo o no probaste el comando, dilo. Pide la salida de `grep`/`sed -n` para ver el código real en lugar de suponerlo.
5. **Sin ruido visual.** La interfaz es minimalista; no añadas íconos, banners ni indicadores que no se pidieron.

## 3.1 Funcionalidades protegidas (NO tocar sin permiso explícito)

Cada una fue pedida, probada y aprobada por el dueño.

### Breadcrumb / winbar (`lua/chadrc.lua`, función `winbar_path_mode()` y `WinBarDraw`)

- Ruta tipo VS Code, a la izquierda, pequeña y discreta, con colores derivados del tema (`nvim_get_hl` + mezcla). El icono del archivo usa el color de `nvim-web-devicons` con el fondo de la barra.
- La barra completa usa el tono de panel del tema (`Pmenu.bg`, que base46 llena con `one_bg`) normalizado a un rango de luminancia legible; es el mismo fondo en la statusline inferior. No volver a dejarla transparente, gris fija ni pintar el borde izquierdo con `St_file_txt`.
- A la derecha, en este orden: `Sp:N`/`Tab:N`, contadores de errores/warnings/hints **sin etiquetas**, y el contador de archivos con su icono `󰈚` (conserva el color original de `St_file_txt`, pero sobre el fondo de la barra). El indicador de modificado es la lápiz gris `WinCrumbMod`. Los colores del breadcrumb y de `Sp:N`/`Tab:N` se recalculan al cambiar de tema.
- La statusline inferior muestra solo modo, archivo, git y posición; **no** debe llevar diagnósticos, `Sp:N`/`Tab:N`, la búsqueda ni el tamaño de la selección visual. Los grupos `St_file_txt`/`St_pos_txt` no se usan directamente porque traen un fondo más oscuro; el bloque git usa `St_git*` con el fondo de la barra. No volver a añadir la barra `│` al git.
- `configs/status_hud.lua` dibuja `[N/M]` y `N lines, M chars` en la fila de comandos, **debajo** de la statusline y de la winbar. Mientras el HUD está activo oculta el `showcmd` nativo para no duplicar el número; `:w`, `/` y `:Lazy` reemplazan temporalmente esa fila y el HUD se restaura después. No devolver estos contadores a ninguna de las dos barras.

### `listchars` + guías de indentación (`lua/options.lua`, `lua/plugins/init.lua`)

- `opt.list = true` con `lead = "·"`, `tab = "··"`, `trail = "·"`, `nbsp = "␣"`. El `tab = "··"` es lo que hace que Go (indenta con tabs) muestre los puntos igual que el resto.
- `indent-blankline` (ibl): `char`/`tab_char` = `│`, color tenue `IblIndentOpaque`, scope con colores Rainbow. Decisión del dueño: **encendidas por defecto**, tenues, y apagadas solo donde estorban (dashboard, terminales, ayuda).

### Autocompletado blink.cmp (`lua/configs/blink.lua`)

- `<Tab>`: con menú abierto **baja** (`select_next` primero) y en el último ítem **vuelve al primero**; sin menú **salta cierres** (`)`, `]`, `}`, `</div>` completo, puntuación suelta) y avanza snippets.
- `<S-Tab>`: **sube** (`select_prev`) y en el primer ítem va al último, luego `snippet_backward`, luego fallback. El ciclo se hace en el keymap (`wrap_menu_selection`) porque blink no cicla con `preselect = false`; aplica igual a `<C-n>`/`<Down>` y `<C-p>`/`<Up>`.
- `<C-n>`/`<Down>` bajan, `<C-p>`/`<Up>` suben, `<C-y>` acepta solo con el menú de blink abierto (sin fallback: no inserta carácter de la línea superior ni toca la IA), `<C-e>` cierra, `<C-space>` abre, **`<CR>` es siempre salto de línea y nunca acepta**.
- El menú de blink pinta el ítem seleccionado con `cursorline` (`winhl` → `BlinkCmpMenuSelection`); los autocmds que tocan `cursorline` no deben entrar en ventanas `blink-cmp-*` o el ítem ya seleccionado pierde el resaltado.
- `preselect = false`, `auto_insert = false` (Tab navega el menú sin insertar ni reemplazar texto; se acepta con `<C-y>`), `ghost_text` desactivado (la única letra gris inline debe ser la sugerencia de Minuet; el autocompletado normal vive en el menú), `min_keyword_length = 0`, auto-brackets activos.
- Fuentes propias: `css_selectors`, `html_values`, `dadbod`, y las de SQL admin. No las quites ni cambies su orden sin pedir permiso.

### Módulos propios (`lua/configs/`)

- `css_selectors.lua`: fuente de blink multi-lenguaje (clases/ids en HTML, JSX/TSX, Vue, Svelte, Ruby, Dart, etc.). Reglas delicadas: Svelte `class:` se detecta con `^class:([%a_][%w_-]*)`; Dart usa `classes`. Prueba cualquier cambio en los lenguajes anteriores.
- `tag_errors.lua`: marca en rojo `< > /` de etiquetas mal formadas. Color propio `#FF3B3B` (fg), `#3D0A10` (bg), undercurl, grupo `TagDelimiterError`. Reglas HTML específicas (void, cierres opcionales, svg/math); **XML no debe mostrar falsos errores**. Se activa con `require("configs.tag_errors").setup()` en `autocmds.lua`.
- `html_values.lua`, `sql_*`: fuentes y resaltado para HTML y SQL.
- `conform.lua`, `lint.lua`, `lspconfig.lua`, `dap.lua`: formatters, linters, LSP y depuración.
- `status_hud.lua`: contadores de búsqueda y selección visual en la fila inferior; ver la sección de breadcrumb.

### Otros

- `@tag.delimiter` en `chadrc.lua` = `#CFE3F7` (blanco azulado suave; el dueño lo eligió).
- Temas en `lua/themes/`: `fluorodark.lua` (neón; `MatchParen`/`MatchWord` con fondo `#16304F`) y `sakura_dracula.lua` (pastel sobre fondo Dracula `#282A36`, `TRANSPARENT = false`). No mezcles sus paletas. Al editar un tema conserva todas las claves de `base_30` y `base_16` y la llamada final a `require("base46").override_theme`.
- Parches a la documentación de blink con rainbow-delimiters en `autocmds.lua`: no tocar.
- Avante: el menú `<leader>ag` solo ofrece proveedores NVIDIA NIM y OpenRouter; no reintroducir Gemini en ese menú. Lee `NVIDIA_API_KEY` y `OPENROUTER_API_KEY` del entorno (nunca hardcodearlas en el repo). `;` = `:` en modo normal.
- Minuet: autocompletado inline manual con NVIDIA NIM; no activar `auto_trigger_ft` (no debe pedir sugerencias mientras se escribe) y no agregarlo a las fuentes de blink: la IA vive fuera del menú de blink. `<M-]>` pide/avanza, `<M-[>` retrocede, `<M-a>` acepta una línea, `<C-g>` acepta todo y `<C-]>` descarta; `<Tab>` nunca acepta IA (solo navega blink/cierres). El autocmd `User BlinkCmpMenuOpen` descarta la sugerencia inline al abrir el menú de blink; es necesario porque `show_on_completion_menu` no borra el extmark ya dibujado. Usa `nvidia/nemotron-3.5-lightning-30b-a3b` con `enable_thinking = false`; no cambiar a un modelo de razonamiento para completado.
- Cliente HTTP: `lua/plugins/api.lua` con `jellydn/hurl.nvim`; atajos locales `<leader>H*` solo en archivos `.hurl`; requiere `hurl` y `jq`. Decisión consciente: **no** usar kulala.nvim (núcleo cerrado, requiere token de licencia) ni rest.nvim (sin mantenimiento).
- Fuentes/emoji: la configuración de fontconfig vive en `~/.config/fontconfig/conf.d/` (`60-emoji-first.conf`, `61-emoji-fix.conf`). No se toca desde Neovim.
- La configuracion tiene que estar toda en ingles

## 4. Convenciones de código

- Lua idiomático, modular, DRY. Un módulo = una responsabilidad. Lo propio va en `lua/configs/`, los specs de lazy en `lua/plugins/`.
- Formato: `stylua` (ver `.stylua.toml`), 4 espacios. Comentarios, descripciones y mensajes de UI **en inglés**, con cabeceras `-- ── SECTION ──` como en el resto del repo.
- Carga perezosa siempre que se pueda (`event`, `ft`, `cmd`, `keys`). Todo plugin con `ft` o `cmd` si solo sirve para un caso.
- Asíncrono: `vim.system` con callback, nunca `vim.fn.system`/`systemlist` en el hilo principal ni dentro de `redraw`/decoration providers.
- Colores: derivarlos del tema (`nvim_get_hl`, `M.base_30`) en vez de hex sueltos; si hace falta un hex fijo, documenta el motivo.
- Atajos de teclado nuevos: buffer-locales cuando solo aplican a un filetype; nunca roban `<leader>` ni `<Space>`. Siempre con `desc`.
- Windows/buffers especiales: restaurar opciones de ventana que se cambien (no filtrar `list`, `number`, `signcolumn`).
- Limpieza al guardar: las sustituciones (`BufWritePre`) no deben tocar markdown (los dos espacios finales son un salto duro), binarios ni buffers no modificables.
- Unicode: usar `vim.fn.strdisplaywidth`/`vim.str_utf_pos`; nunca offsets de bytes fijos con íconos multibyte.

## 5. Soporte de lenguajes

Objetivo: 35-40 lenguajes sin solapamientos ni consumo en reposo: Rust, C, C++, Zig, Go, Python, Bash/Zsh, Lua, Ruby, JS, TS, HTML, CSS/Tailwind, JSX/TSX, Next.js, Vue, Svelte, SQL (MySQL/MariaDB/PostgreSQL), JSON, YAML, TOML, XML, CSV, Java, C#, Kotlin, Swift, Dart, Haskell, Elixir.

- LSP vía ecosistema nativo (`vim.lsp.config`/`enable`), formatters en `conform.nvim`, linters en `nvim-lint`, parsers en `nvim-treesitter` (rama `master`). Cada herramienta se activa solo para su filetype.
- Antes de añadir un lenguaje, comprueba que su LSP/formatter/linter existe en Arch (`pacman -Ss`, AUR solo si no hay otra opción) y documenta la dependencia.

## 6. Flujo de trabajo obligatorio

1. **Lee** el archivo real antes de editar. Si no lo tienes, pide `sed -n A,Bp archivo` o un `grep -n`.
2. **Explica** en 1-2 viñetas por qué la solución es la óptima y nombra las dependencias del sistema.
3. **Entrega** el código listo para copiar, con ruta exacta (`lua/configs/x.lua`).
4. **Prueba** antes de entregar: `nvim --headless` con un script mínimo. Para plugins de resaltado, comprueba extmarks/highlight reales en un buffer de prueba con cada lenguaje afectado. Di claramente qué probaste y qué no.
5. **Verifica regresiones** de las funcionalidades de la sección 3.1 relacionadas con tu cambio (listchars, winbar, Tab/S-Tab, etc.).
6. Si das comandos al usuario, dalos **exactos y listos para pegar** (`sed -i`, `grep`), explica cada paso y evita placeholders que pueda ejecutar literalmente.

## 7. Git

- Commits en **Conventional Commits** (`feat(blink): ...`, `fix(winbar): ...`, `chore: ...`), un cambio lógico por commit, cuerpo con el porqué.
- Antes de commitear, revisa `git status -sb` y `git diff --stat`: que no se escapen cambios importantes ni archivos generados (`node_modules`, `graphify-out`, `repomix-output.xml` según `.gitignore`).
- No hagas push sin que el dueño lo pida.

## 8. Pendientes conocidos

- **Dashboard**: reescrito y modular (`lua/dashboard/{init,data,render,nav,sessions,config}.lua`). Cubre arte ASCII con degradado del tema, estado git asíncrono (rama, cambios, ahead/behind, stash, último commit), diagnósticos, LSP, formatters (faltantes), plugins, startup real, proyectos/directorios/recientes, pins, TODOs con ripgrep, sesiones por proyecto+rama (`:mksession`), búsqueda con `/`, navegación `hjkl`/flechas y lanzadores con degradación limpia si falta Telescope/fzf/lazygit. Sin `listchars` ni guías de indentación: eso solo aplica al dashboard. Pruebas headless: `nvim --headless -u init.lua -c "luafile tests/dashboard_spec.lua"`. Atajo de `listchars` en archivos normales: `<leader>ul`.
- Bloques duplicados de `lua/plugins/init.lua`: eliminados; no reintroducir specs repetidas.
- Error de avante.nvim con luarocks/`mega`.
- Probar `bootstrap.sh` en una máquina limpia.
- Completado de cabeceras/métodos HTTP en archivos `.hurl`: el plan es una fuente propia de blink.cmp (o un LSP en Rust) con datos de los registros IANA; `hurl-lsp` fue evaluado y descartado por inmaduro (pre-1.0, 0 estrellas, sin nombres de cabeceras).

## 9. Qué NO hacer

- No reescribir todo "por limpieza".
- No cambiar de gestor (lazy.nvim), de completador (blink.cmp) ni de base (NvChad) sin petición expresa.
- No añadir íconos, emojis ni indicadores nuevos a la interfaz comprobar que se vea bien y preguntar.
- No usar rutas, comandos o versiones de memoria sin comprobarlos.
- No asumir que un archivo existe porque se mencionó: compruébalo.
