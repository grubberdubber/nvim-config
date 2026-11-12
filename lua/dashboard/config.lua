-- Dashboard configuration. Every section, limit and behavior lives here so the
-- UI can be tuned without touching the data/render modules.
return {
    -- Nerd Font icons. Set to false for a pure ASCII layout; widths are
    -- computed from display cells either way.
    icons = true,

    -- Highlight the row under the cursor (in addition to the cursor itself).
    highlight_selection = true,

    -- Hide the terminal cursor while the dashboard is focused.
    hide_cursor = false,

    -- Hard limits for every list. Anything above is reachable through the
    -- corresponding Telescope picker.
    limits = {
        -- Stored project history (the JSON file) keeps up to 30 entries;
        -- this is how many are rendered and reachable with 1-9.
        projects = 9,
        buffers = 5,
        directories = 5,
        recents = 8,
        pins = 10,
        todos = 4,
        sessions = 3,
        lsp_names = 3,
        diagnostics = 5,
    },

    -- Section order. Remove an entry to hide that section entirely.
    sections = {
        "header",
        "status",
        "diagnostics",
        "actions",
        "sessions",
        "buffers",
        "projects",
        "directories",
        "recents",
        "todos",
        "pins",
    },

    show = {
        startup = true,
        plugins = true,
        lsp = true,
        formatters = true,
        last_build = true,
    },
}
