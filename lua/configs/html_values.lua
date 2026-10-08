-- Fuente de blink.cmp: valores enumerados de atributos HTML (WHATWG).
-- Sirve en html, php, vue, svelte, jsx/tsx y xml. Los nombres se comparan en
-- minúsculas, así que también cubre JSX (httpEquiv, autoComplete, crossOrigin...).
local source = {}

local FILETYPES = {
    html = true,
    htmldjango = true,
    php = true,
    vue = true,
    svelte = true,
    javascriptreact = true,
    typescriptreact = true,
    xml = true,
}

-- "a b c" -> { "a", "b", "c" }
local function list(s)
    local t = {}
    for w in s:gmatch "%S+" do
        t[#t + 1] = w
    end
    return t
end

local VIEWPORT = "width=device-width, initial-scale=1.0"
local ROBOTS = { "index, follow", "noindex, nofollow", "index, nofollow", "noindex, follow", "all", "none" }
local REFERRER =
    list "no-referrer no-referrer-when-downgrade origin origin-when-cross-origin same-origin strict-origin strict-origin-when-cross-origin unsafe-url"
local MIME_IMG = { "image/png", "image/jpeg", "image/webp", "image/avif", "image/svg+xml", "image/gif", "image/x-icon" }

-- ── 1. Atributos que valen para cualquier etiqueta (o comunes a varias) ──
local GLOBAL = {
    -- Globales
    autocapitalize = list "off none on sentences words characters",
    autocorrect = list "on off",
    contenteditable = list "true false plaintext-only",
    dir = list "ltr rtl auto",
    draggable = list "true false auto",
    enterkeyhint = list "enter done go next previous search send",
    hidden = list "until-found hidden",
    inputmode = list "none text decimal numeric tel search email url",
    spellcheck = list "true false",
    translate = list "yes no",
    popover = list "auto manual",
    writingsuggestions = list "true false",
    lang = list "es en fr de pt it ja zh ko ru ar hi nl pl tr sv",

    -- Enlaces, formularios, recursos
    target = list "_blank _self _parent _top",
    formtarget = list "_blank _self _parent _top",
    rel = list "stylesheet icon preload prefetch preconnect dns-prefetch modulepreload canonical alternate manifest apple-touch-icon noopener noreferrer nofollow author bookmark external help license next prev search tag archives index first last",
    referrerpolicy = REFERRER,
    crossorigin = list "anonymous use-credentials",
    loading = list "lazy eager",
    decoding = list "sync async auto",
    fetchpriority = list "high low auto",
    method = list "get post dialog",
    formmethod = list "get post dialog",
    enctype = list "application/x-www-form-urlencoded multipart/form-data text/plain",
    formenctype = list "application/x-www-form-urlencoded multipart/form-data text/plain",
    popovertargetaction = list "show hide toggle",
    capture = list "user environment",
    wrap = list "soft hard",
    virtualkeyboardpolicy = list "auto manual", -- VirtualKeyboard API (Chromium)
    closedby = list "any closerequest none", -- <dialog>
    command = list "show-modal close request-close show-popover hide-popover toggle-popover", -- <button> (Invoker Commands)
    controlslist = list "nodownload nofullscreen noremoteplayback", -- <audio> <video> (Chromium)
    colorspace = list "limited-srgb display-p3", -- <input type="color">
    shadowrootmode = list "open closed",
    sandbox = list "allow-downloads allow-forms allow-modals allow-orientation-lock allow-pointer-lock allow-popups allow-popups-to-escape-sandbox allow-presentation allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation allow-top-navigation-by-user-activation allow-top-navigation-to-custom-protocols",
    allow = list "accelerometer autoplay camera clipboard-read clipboard-write display-capture encrypted-media fullscreen geolocation gyroscope microphone payment picture-in-picture web-share",
    accept = list "image/* video/* audio/* application/pdf .pdf .png .jpg .jpeg .svg .webp .csv .json",

    autocomplete = list "on off name honorific-prefix given-name additional-name family-name honorific-suffix nickname email username new-password current-password one-time-code organization-title organization street-address address-line1 address-line2 address-line3 address-level4 address-level3 address-level2 address-level1 country country-name postal-code cc-name cc-given-name cc-additional-name cc-family-name cc-number cc-exp cc-exp-month cc-exp-year cc-csc cc-type transaction-currency transaction-amount language bday bday-day bday-month bday-year sex url photo tel tel-country-code tel-national tel-area-code tel-local tel-extension impp shipping billing home work mobile fax pager webauthn",

    -- Específicos de una sola etiqueta (no chocan con otras)
    shape = list "default rect circle poly", -- <area>
    preload = list "none metadata auto", -- <audio> <video>
    scope = list "row col rowgroup colgroup", -- <td> <th>
    kind = list "subtitles captions descriptions chapters metadata", -- <track>
    as = list "audio document embed fetch font image object script style track video worker", -- <link>
    blocking = list "render", -- <link> <script> <style>
    charset = { "UTF-8", "ISO-8859-1" },
    ["http-equiv"] = list "content-type default-style refresh x-ua-compatible content-security-policy", -- <meta>

    -- Accesibilidad (extra, no es HTML puro)
    role = list "alert alertdialog application article banner button cell checkbox columnheader combobox complementary contentinfo definition dialog directory document feed figure form grid gridcell group heading img link list listbox listitem log main marquee math menu menubar menuitem menuitemcheckbox menuitemradio navigation none note option presentation progressbar radio radiogroup region row rowgroup rowheader scrollbar search searchbox separator slider spinbutton status switch tab table tablist tabpanel term textbox timer toolbar tooltip tree treegrid treeitem",
    ["aria-live"] = list "off polite assertive",
    ["aria-hidden"] = list "true false",
    ["aria-expanded"] = list "true false",
    ["aria-pressed"] = list "true false mixed",
    ["aria-checked"] = list "true false mixed",
    ["aria-selected"] = list "true false",
    ["aria-disabled"] = list "true false",
    ["aria-current"] = list "page step location date time true false",
    ["aria-haspopup"] = list "false true menu listbox tree grid dialog",
    ["aria-autocomplete"] = list "none inline list both",
    ["aria-invalid"] = list "false true grammar spelling",
    ["aria-orientation"] = list "horizontal vertical",
    ["aria-sort"] = list "none ascending descending other",
}

-- ── 2. Atributos que cambian según la etiqueta (tienen prioridad) ────────
local BY_TAG = {
    meta = {
        name = list "viewport description keywords author robots theme-color color-scheme generator referrer creator publisher format-detection handheldfriendly mobileoptimized googlebot",
    },
    input = {
        type = list "text password email number tel url search date time datetime-local month week checkbox radio file hidden range color submit image reset button",
    },
    button = { type = list "submit reset button" },
    ol = { type = list "1 a A i I" },
    script = {
        type = {
            "module",
            "importmap",
            "speculationrules",
            "text/javascript",
            "application/json",
            "application/ld+json",
        },
    },
    link = { type = vim.list_extend({ "text/css" }, MIME_IMG) },
    style = { type = { "text/css" } },
    source = {
        type = vim.list_extend(
            { "video/mp4", "video/webm", "video/ogg", "audio/mpeg", "audio/ogg", "audio/wav" },
            MIME_IMG
        ),
    },
}

-- ── 3. <meta content="..."> depende de name= / http-equiv= ───────────────
local META_CONTENT = {
    { "name", "viewport", { VIEWPORT, "width=device-width, initial-scale=1, viewport-fit=cover" } },
    { "name", "robots", ROBOTS },
    { "name", "googlebot", ROBOTS },
    { "name", "color-scheme", { "light dark", "dark light", "light", "dark", "normal" } },
    { "name", "referrer", REFERRER },
    { "name", "format-detection", { "telephone=no", "telephone=no, date=no, email=no, address=no" } },
    { "name", "handheldfriendly", { "true" } },
    { "name", "mobileoptimized", { "width" } },
    { "http-equiv", "content-type", { "text/html; charset=UTF-8" } },
    { "http-equiv", "refresh", { "5; url=" } },
    { "http-equiv", "x-ua-compatible", { "IE=edge" } },
    { "http-equiv", "content-security-policy", { "default-src 'self'" } },
}

function source.new(opts)
    return setmetatable({ opts = opts or {} }, { __index = source })
end

function source:enabled()
    return FILETYPES[vim.bo.filetype] == true
end

function source:get_trigger_characters()
    return { '"', "'" }
end

-- Texto desde unas líneas atrás hasta el cursor (etiquetas en varias líneas)
local function text_before(ctx)
    local row = ctx.cursor[1]
    local first = math.max(0, row - 6)
    local prev = vim.api.nvim_buf_get_lines(0, first, row - 1, false)
    local cur = ctx.line:sub(1, ctx.cursor[2])
    return table.concat(prev, " ") .. " " .. cur
end

local function attr_is(tag_text, attr, value)
    local name = attr:gsub("%-", "%%-")
    local pat = "%f[%w%-]" .. name .. "%s*=%s*[\"']" .. vim.pesc(value) .. "[\"']"
    return tag_text:lower():find(pat) ~= nil
end

local function values_for(tag, attr, tag_text)
    if tag == "meta" and attr == "content" then
        for _, rule in ipairs(META_CONTENT) do
            if attr_is(tag_text, rule[1], rule[2]) then
                return rule[3]
            end
        end
        return nil
    end
    local specific = BY_TAG[tag] and BY_TAG[tag][attr]
    return specific or GLOBAL[attr]
end

function source:get_completions(ctx, callback)
    local before = text_before(ctx)
    local tag_text = before:match "(<[%w%-]+[^<>]*)$"
    local tag = tag_text and tag_text:match "^<([%w%-]+)"
    local attr = before:match "([%w%-:@.]+)%s*=%s*[\"'][^\"']*$"
    local items = {}

    if tag and attr then
        local seen = {}
        for i, v in ipairs(values_for(tag:lower(), attr:lower(), tag_text) or {}) do
            if not seen[v] then
                seen[v] = true
                items[#items + 1] = {
                    label = v,
                    kind = 12, -- Value
                    insertText = v,
                    sortText = string.format("%04d", i),
                    labelDetails = { description = attr },
                }
            end
        end
    end

    callback { items = items, is_incomplete_backward = false, is_incomplete_forward = false }
    return function() end
end

return source
