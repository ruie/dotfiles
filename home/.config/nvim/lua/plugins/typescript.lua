-- TypeScript LSP: LazyVim's `lang.typescript.tsc` extra (tsgo / TS 7 `tsc --lsp`).
-- lspconfig prefers the project's node_modules/.bin/tsc (effect-tsgo patched,
-- gives Effect diagnostics) and falls back to Mason's upstream tsc.
-- Found 2026-09-21 on the effect-digital-shelf monorepo:
--   * @effect/tsgo 0.43.0's `tsc --lsp` leaked ~2GB every 15s until WSL ran out
--     of memory; 0.45.0 sits flat at ~2.5GB like upstream. Keep projects >= 0.45.
--   * blink.cmp forwards completion trigger characters from every attached
--     server; tailwind's `:`/`-`/`(` make typescript-go panic ("Unknown
--     trigger character") and the request fails. Trim tailwind's list to what
--     TypeScript accepts; tailwind completions still open on keyword typing.
local ts_trigger_chars = { ".", '"', "'", "`", "/", "@", "<", "#", " " }

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          on_init = function(client)
            local provider = client.server_capabilities.completionProvider
            if provider and provider.triggerCharacters then
              provider.triggerCharacters = vim.tbl_filter(function(c)
                return vim.tbl_contains(ts_trigger_chars, c)
              end, provider.triggerCharacters)
            end
          end,
        },
      },
    },
  },
}
