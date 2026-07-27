---@meta

---@class HL.Dispatcher
local Dispatcher = {}

---@class HL.Keybind
---@field set_enabled fun(self: HL.Keybind, enabled: boolean)
local Keybind = {}

---@class HL.EventSubscription
---@field remove fun(self: HL.EventSubscription)
local EventSubscription = {}

---@class HL.DspWindow
---@field close fun(): HL.Dispatcher
---@field cycle_next fun(): HL.Dispatcher
---@field drag fun(): HL.Dispatcher
---@field float fun(options: table): HL.Dispatcher
---@field move fun(options: table): HL.Dispatcher
---@field pseudo fun(): HL.Dispatcher
---@field resize fun(): HL.Dispatcher
local DspWindow = {}

---@class HL.DspWorkspace
---@field toggle_special fun(name: string): HL.Dispatcher
local DspWorkspace = {}

---@class HL.Dsp
---@field exec_cmd fun(command: string): HL.Dispatcher
---@field focus fun(options: table): HL.Dispatcher
---@field window HL.DspWindow
---@field workspace HL.DspWorkspace
local Dsp = {}

---@class HL.API
---@field animation fun(options: table)
---@field bind fun(keys: string, dispatcher: HL.Dispatcher, options?: table): HL.Keybind
---@field config fun(config: table)
---@field curve fun(name: string, options: table)
---@field device fun(spec: table)
---@field env fun(name: string, value: string)
---@field exec_cmd fun(command: string)
---@field gesture fun(spec: table)
---@field monitor fun(spec: table)
---@field on fun(event: string, callback: fun()): HL.EventSubscription
---@field window_rule fun(spec: table)
---@field dsp HL.Dsp

---@type HL.API
hl = {}
