-- [[ WORKFLOW ORCHESTRATOR ]]
-- Domain: External Tools, Sessions, & Environment
--
-- PHILOSOPHY: The "Mise-en-Place" Principle
-- Everything required for the job must be present, validated, and
-- ready for use without manual intervention.

local M = {}
local utils = require 'core.utils'

local modules = {
  'workflow.toggleterm', -- Terminal Command Center
  'workflow.persistence', -- Automatic Session Management
  'workflow.overseer', -- Task Runner & Background Jobs
  'workflow.typst-preview', -- What it sounds like
  'workflow.test-runner', -- Language-aware test dispatch (Rust/Zig/Python/C/C++)
  'workflow.vim-be-good', -- Ghost command motion trainer
}

for _, mod in ipairs(modules) do
  local module_path = 'plugins.' .. mod
  local ok, mod_or_err = pcall(require, module_path)
  if ok and type(mod_or_err) == 'table' and type(mod_or_err.setup) == 'function' then
    local setup_ok, setup_err = pcall(mod_or_err.setup)
    if not setup_ok then
      utils.soft_notify(string.format('DOMAIN SETUP FAILURE: [%s]\n%s', module_path, setup_err), vim.log.levels.ERROR)
    end
  elseif not ok then
    local err = mod_or_err
    utils.soft_notify(string.format('WORKFLOW DOMAIN FAILURE: [%s]\n%s', module_path, err), vim.log.levels.ERROR)
  end
end

return M
