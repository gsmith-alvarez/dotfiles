-- [[ CORE.QUOTES: Asynchronous Wisdom Engine ]]
-- Purpose: Provide dynamic, inspiring content to the dashboard without blocking boot.
-- Domain:  Background Tasks & UI Enrichment
-- Architecture: Async-First (Job-Proxy + File-Cache)
--
-- PHILOSOPHY: The "Async-First" Principle
-- Network calls must NEVER block the UI thread. We fetch quotes in a 
-- background system job and cache them to a local file. This is 
-- "Anti-Fragile": if the network is down, the UI remains snappy by 
-- reading the last successful cache.
--
-- MAINTENANCE TIPS:
-- 1. If quotes never update, check if `curl` is installed on your system.
-- 2. The cache is stored in `stdpath("state") .. "/fast_quotes.tmp"`.
-- 3. If the quote engine crashes, it defaults to a safe "Net Multiplier" mantra.

local M = {}
-- We store the cache in Neovim's standard state directory to keep the 
-- config folder clean and Git-agnostic.
local cache_path = vim.fn.stdpath("state") .. "/fast_quotes.tmp"

-- [[ THE ASYNC WORKER ]]
-- Fetches a fresh quote in the background and caches it for the next session.
-- Called on VimEnter so the current session's quote is already shown instantly
-- while the next session's quote is being prepared asynchronously.
M.refresh_quote = function()
  -- Using 'curl' ensures we don't need a heavy Lua socket library.
  local cmd = "curl -s https://zenquotes.io/api/random"
  
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data or #data == 0 or data[1] == "" then return end
      
      -- ZenQuotes returns an array of JSON objects.
      local ok, decoded = pcall(vim.json.decode, table.concat(data))
      if ok and decoded[1] and decoded[1].q then
        local quote = string.format('"%s" - %s', decoded[1].q, decoded[1].a)
        
        -- Write to disk for the next session's immediate load.
        local f = io.open(cache_path, "w")
        if f then
          f:write(quote)
          f:close()
        end
      end
    end,
  })
end

-- Refresh in the background on every startup so the cache stays current.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = M.refresh_quote,
})

-- [[ THE INSTANT ACCESSOR ]]
M.get_cached_quote = function()
  local f = io.open(cache_path, "r")
  if f then
    local content = f:read("*a")
    f:close()
    if content and content ~= "" then return content end
  end
  -- Safe Fallback: A classic "Net Multiplier" mantra.
  return "The only way to go fast is to go well. - Robert C. Martin"
end

return M