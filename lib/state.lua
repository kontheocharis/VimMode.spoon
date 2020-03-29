local machine = dofile(vimModeScriptPath .. 'lib/utils/statemachine.lua')
local Nvim = dofile(vimModeScriptPath .. "lib/nvim/index.lua")

local function createStateMachine(state)
  return machine.create({
    initial = 'insert-mode',
    events = {
      { name = 'disable', from = 'insert-mode', to = 'disabled' },
      { name = 'enable', from = 'enabled', to = 'insert-mode' },

      { name = 'enterNormal', from = 'insert-mode', to = 'normal-mode' },
      { name = 'enterNormal', from = 'visual-mode', to = 'normal-mode' },
      { name = 'enterNormal', from = 'firing', to = 'normal-mode' },
      { name = 'enterNormal', from = 'operator-pending', to = 'normal-mode' },

      { name = 'enterMotion', from = 'normal-mode', to = 'entered-motion' },
      { name = 'enterMotion', from = 'operator-pending', to = 'entered-motion' },
      { name = 'enterMotion', from = 'visual-mode', to = 'entered-motion' },

      { name = 'enterOperator', from = 'normal-mode', to = 'operator-pending' },
      { name = 'enterOperator', from = 'visual-mode', to = 'operator-pending' },

      { name = 'enterVisual', from = 'normal-mode', to = 'visual-mode' },
      { name = 'enterVisual', from = 'firing', to = 'visual-mode' },

      { name = 'fire', from = 'entered-motion', to = 'firing' },
      { name = 'fire', from = 'visual-mode', to = 'firing' },

      { name = 'enterInsert', from = 'firing', to = 'insert-mode' },
      { name = 'enterInsert', from = 'normal-mode', to = 'insert-mode' },
      { name = 'enterInsert', from = 'operator-pending', to = 'insert-mode' },
      { name = 'enterInsert', from = 'visual-mode', to = 'insert-mode' },
    },
    callbacks = {
      onenterNormal = function()
        state:setMode("normal")
        vimLogger.i("normal enter")
      end,
      onenterInsert = function()
        state:setMode("insert")
        vimLogger.i("insert enter")
      end,
      onenterVisual = function()
        state:setMode("visual")
        vimLogger.i("visual enter")
      end,
      onenterOperator = function(_, _, _, _, operator)
        vimLogger.i("operating pending enter")
      end,
      onenterMotion = function(self, _, _, _, motion)
        vimLogger.i("motion entered, should fire")
      end,
      onfire = function(self)
      end,
      onstatechange = function()
        -- vim:updateStateIndicator()
      end
    }
  })
end

local State = {}

function State:new()
  local state = {}

  setmetatable(state, self)
  self.__index = self

  state.editor = Nvim.Editor:new()
  state.machine = createStateMachine(state)
  state.mode = "insert"

  return state
end

function State:enterNormalMode()
  self.machine:enterNormal()
end

function State:isDisabled()
  return self.machine:is('disabled')
end

function State:getMode()
  return self.mode
end

function State:setMode(mode)
  self.mode = mode
  return self
end

function State:is(state)
  return self.machine:is(state)
end

return State
