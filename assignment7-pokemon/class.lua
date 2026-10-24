--
-- Class library for Lua
--
local function include_helper(to, from, seen)
    if from == nil then
        return to
    elseif type(from) ~= 'table' then
        return from
    elseif seen and seen[from] then
        return seen[from]
    end

    seen = seen or {}
    seen[from] = to

    for k, v in pairs(from) do
        if k ~= '__index' then
            if type(v) == 'table' then
                to[k] = include_helper({}, v, seen)
            else
                to[k] = v
            end
        end
    end

    return to
end

local function class(base)
    local c = {}
    if type(base) == 'table' then
        for k, v in pairs(base) do
            c[k] = v
        end
        c._base = base
    end

    c.__index = c

    local mt = {}
    mt.__call = function(class_tbl, ...)
        local obj = {}
        setmetatable(obj, c)
        if class_tbl.init then
            class_tbl.init(obj, ...)
        else
            if base and base.init then
                base.init(obj, ...)
            end
        end
        return obj
    end

    c.include = function(self, include)
        assert(type(include) == 'table', "include must be a table")
        return include_helper(self, include)
    end

    setmetatable(c, mt)
    return c
end

return class
