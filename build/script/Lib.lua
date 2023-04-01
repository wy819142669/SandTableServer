-- table 是否为{}
function table.is_empty(t)
	return _G.next(t) == nil
end
-- table 是否包含对应的key
function table.contain_key(tb, key)
	if not tb or not key then return false end
	for k, _ in pairs(tb) do
		if k == key then return true end
	end
	return false
end
-- table 是否包含一个 value
function table.contain_value(tb, value)
	if not tb or not value then return false end
	for i, v in pairs(tb) do
		if v == value then return true, i end
	end
	return false
end

Lib = Lib or {}
--Table的拷贝
function Lib.copyTab(st)
	local tab = {}
	for k, v in pairs(st or {}) do
		if type(v) ~= "table" then
			tab[k] = v
		else
			tab[k] = Lib.copyTab(v)
		end
	end
	return tab
end