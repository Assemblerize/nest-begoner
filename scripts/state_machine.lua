local M = {}


local Functions = {
    ["screen off"]        = function(arg) end,
    ["low energy screen"] = function(arg) end,
    ["working screen"]    = function(arg) end,

    ["red light"]         = function(arg) end,
    ["yellow light"]      = function(arg) end,
    ["green light"]       = function(arg) end,

    ["anim speed 0"]       = function(arg) end,
    ["anim speed max"]     = function(arg) end,

    ["charging anim on"]  = function(arg) end,
    ["charging anim off"] = function(arg) end,
}

local transitions = {
    [0] = {
        [1] = { "low energy screen", "red light", "anim speed 0" },
        [2] = { "low energy screen", "yellow light", "anim speed max" },
        [3] = { "working screen", "green light", "anim speed max" },
        [4] = { "low energy screen", "yellow light", "anim speed max", "charging anim on" },
        [5] = { "screen off", "red light", "anim speed 0" },
    },
    [1] = {
        [2] = { "yellow light", "anim speed max" },
        [3] = { "working screen", "green light", "anim speed max" },
        [4] = { "yellow light", "anim speed max", "charging anim on" },
        [5] = { "screen off", "red light" },
    },
    [2] = {
        [1] = { "red light", "anim speed 0" },
        [3] = { "working screen", "green light" },
        [4] = { "charging anim on" },
        [5] = { "screen off", "red light", "anim speed 0" },
    },
    [3] = {
        [1] = { "low energy screen", "red light", "anim speed 0" },
        [2] = { "low energy screen", "yellow light" },
        [4] = { "low energy screen", "yellow light", "charging anim on" },
        [5] = { "screen off", "red light", "anim speed 0" },
    },
    [4] = {
        [1] = { "red light", "anim speed 0", "charging anim off" },
        [2] = { "charging anim off" },
        [3] = { "working screen", "green light", "charging anim off" },
        [5] = { "screen off", "red light", "anim speed 0", "charging anim off" },
    },
    [5] = {
        [1] = { "screen off" },
        [2] = { "low energy screen", "yellow light", "anim speed max" },
        [3] = { "working screen", "green light", "anim speed max" },
        [4] = { "low energy screen", "yellow light", "anim speed max", "charging anim on" },
    },
}


function M.transition(arg, from, to)
    -- trim similar states
    if to > 5 then to = 5 end
    if from > 5 then from = 5 end

    local row = transitions[from]
    local actions = row and row[to]
    if not actions then
        return false
    end
    for i = 1, #actions do
        Functions[actions[i]](arg)
    end
    return true
end

function M.setHandler(name, fn)
    assert(Functions[name] ~= nil, "unknown function name: " .. tostring(name))
    Functions[name] = fn
end

-- M.Functions = Functions
-- M.transitions = transitions

return M