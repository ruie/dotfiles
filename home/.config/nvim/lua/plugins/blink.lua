-- After a trigger character (`.`, `:`, `/` ...) show only what the language
-- server offers — e.g. `Layer.` lists Layer's exports, not buffer words or
-- snippets. Those still show up when typing a plain word or on manual
-- <C-Space>. Same idea as IMax153's snippets rule, applied to buffer too.
local function not_after_trigger_char(ctx)
  return ctx.trigger.initial_kind ~= "trigger_character"
end

return {
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          -- tsgo's first completion in a freshly opened file takes 1-5s on the
          -- monorepo (project + auto-import index build); blink's default 2s
          -- cutoff then drops it and `HttpRouter.` shows nothing. Later
          -- requests take ~30ms, so only the first one hits this.
          lsp = { timeout_ms = 10000 },
          buffer = { should_show_items = not_after_trigger_char },
          snippets = { should_show_items = not_after_trigger_char },
        },
      },
    },
  },
}
