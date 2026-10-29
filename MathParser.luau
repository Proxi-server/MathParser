-- made by ZOMBLER
local MathParser = {}

local function Convert(x, y, istable)
	if not x then x = 0 end
	if not y then
		y = 0 
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		else
			if math.abs(x) >= 10 then
				y = math.floor(math.log10(x))
				x = x / 10^y
			end
			if math.abs(x) < 1 then
				local exp = math.floor(-math.log10(math.abs(x))) + 1
				y -= exp
				x = x * 10^exp
			end
		end
	end
	if math.abs(x) >= 10 then
		local old = y
		y = math.floor(math.log10(x))
		x = x / 10^y
		y += old
	end
	if math.abs(x) < 1 then
		local exp = math.floor(-math.log10(math.abs(x))) + 1
		y -= exp
		x = x * 10^exp
	end
	if istable then 
		return {x, y}
	end
	return x, y
end

local function splitNumber(num)
	if num == 0 then return 0, 0 end
	local power = math.floor(math.log10(math.abs(num)))
	local coefficient = num / (10 ^ power)
	return coefficient, power
end

function MathParser.PerfomOperation(x, y, z, w, sign, scientific)
	if not sign then
		local old = y
		x, y = Convert(x, nil, false)
		sign = z
		scientific = w
		z, w = Convert(old, nil, false)
	end
	if typeof(x) == "table" then 
		local old = y
		y = x[2]
		x = x[1] 
		sign = z
		scientific = w
		z = old[1]
		w = old[2]
	end
	if sign == "+" then
		if math.abs(x * 10^y) ~= math.huge and math.abs(z * 10^w) ~= math.huge and math.abs((x * 10^y) + (z * 10^w)) ~= math.huge then
			if scientific then
				return splitNumber(x * 10^y + z * 10^w)
			end
			return x * 10^y + z * 10^w
		elseif math.max(y, w) - math.min(y, w) < 3 then
			return x, y
		elseif math.max(y, w) - math.min(y, w) > 3 then
			return z, w
		else
			return Convert(x, y)
		end
	elseif sign == "*" then
		if math.abs(x * 10^y) ~= math.huge and math.abs(z * 10^w) ~= math.huge and math.abs((x * 10^y) * (z * 10^w)) ~= math.huge then
			if scientific then
				return splitNumber((x * 10^y) * (z * 10^w))
			end
			return (x * 10^y) * (z * 10^w)
		else
			local new = x * z
			y += w
			return Convert(new, y)
		end
	elseif sign == "-" then
		if math.abs(x * 10^y) ~= math.huge and math.abs(z * 10^w) ~= math.huge and math.abs((x * 10^y) - (z * 10^w)) ~= math.huge then
			if scientific then
				return splitNumber(x * 10^y - z * 10^w)
			end
			return x * 10^y - z * 10^w
		elseif math.max(y, w) - math.min(y, w) > 8 then
			return x, y
		else
			return Convert(x, y)
		end
	elseif sign == "/" then
		if z == 0 then
			warn("You broke the golden rule")
			return 1/0
		end
		if math.abs(x * 10^y) ~= math.huge and math.abs(z * 10^w) ~= math.huge and math.abs((x * 10^y) / (z * 10^w)) ~= math.huge then
			if scientific then
				return splitNumber((x * 10^y) / (z * 10^w))
			end
			return (x * 10^y) / (z * 10^w)
		else
			local new = x / z
			y -= w
			return Convert(new, y)
		end
	elseif sign == "^" then
		if math.abs(z * 10^w) ~= math.huge then
			if scientific then
				local log_base = math.log10(x) + y
				local power
				if w > 300 then
					local log_power = math.log10(z) + w
					local ful = log_base * (10 ^ log_power)
					return 1.0, math.floor(ful)
				else
					power = z * (10 ^ w)
				end
				local ful = log_base * power
				if ful == math.huge or ful ~= ful then
					warn("[MathParser.PerfomOperation]: too huge dawg here is your variables" .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z) .. ", " .. tostring(w))
					return 1.0, 0
				end
				local new_y = math.floor(ful)
				local new_x = 10 ^ if ful - new_y < 0 then 0 else ful - new_y
				if new_x >= 10 then
					new_x = new_x / 10
					new_y = new_y + 1
				elseif new_x < 1 then
					new_x = new_x * 10
					if new_y > -math.huge then new_y = new_y - 1 end
				end
				return new_x, new_y
			end
			return x^(z * 10^w) * 10 ^ (y *(z * 10^w))
		else
			local ful = (math.log10(x) + y)*(z * 10^w)^10
			return ful - math.floor(ful), math.floor(ful)
		end
	end
end 

local function compare(x, y)
	if typeof(x) == "table" then
		if x[2] > y[2] then
			return true
		elseif x[2] < y[2] then
			return false
		elseif x[1] > y[1] then
			return true
		else
			return nil
		end
	elseif typeof(y) == "table" then
		y = y[1] * 10 ^ y[2]
		if x == y then return nil end
		return x > y
	else
		if x == y then return nil end
		return x > y
	end
end

local function getmod(y, am)
	local result = 1
	local base = 10 % am
	local b = math.floor(y)
	while b > 0 do
		if b % 2 == 1 then
			result = (result * base) % am
		end
		base = (base * base) % am
		b = math.floor(b / 2)
	end
	return result
end

local MathFuncs = {}
MathFuncs = {
	["math.abs"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			if x[1] < 0 then
				return {-x[1], x[2]}
			else
				return {x[1], x[2]}
			end
		elseif x < 0 then
			return -x, y
		else
			return x, y
		end
	end,
	["math.ceil"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			return {math.ceil(x[1]), x[2]}
		else
			return math.ceil(x), y
		end
	end,
	["math.clamp"] = function(args)
		local x, y = 0, 0
		local min_x, min_y, max_x, max_y = -math.huge, -math.huge, math.huge, math.huge
		if typeof(args[1]) == "table" then
			x = args[1][1]
			y = args[1][2]
		else
			x = args[1] or 0
			y = args[2] or 0
		end
		if typeof(args[3]) == "table" then
			min_x = args[3][1]
			min_y = args[3][2]
		else
			min_x = args[3] or -math.huge
			min_y = args[4] or -math.huge
		end
		if typeof(args[5]) == "table" then
			max_x = args[5][1]
			max_y = args[5][2]
		else
			max_x = args[5] or math.huge
			max_y = args[6] or math.huge
		end
		if compare( {x, y}, {min_x, min_y} ) == false then
			x, y = min_x, min_y
		elseif compare( {x, y}, {max_x, max_y} ) == true then
			x, y = max_x, max_y
		end
		return {x, y}
	end,
	["math.cos"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return math.cos((x * getmod(y, 2 * math.pi)) % (2 * math.pi))
	end,
	["math.sin"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return math.sin((x * getmod(y, 2 * math.pi)) % (2 * math.pi))
	end,
	["math.deg"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return MathParser.PerfomOperation(x, y, 180 / math.pi, 0, "*", true)
	end,
	["math.floor"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return math.floor(x), y
	end,
	["math.log"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		local b = args[3] or math.e
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return splitNumber((math.log(x, math.e) + y * math.log(10, math.e)) / math.log(b, math.e))
	end,
	["math.max"] = function(args)
		local x, y = 0, 0
		if typeof(args[1]) == "table" then
			x = args[1][1]
			y = args[1][2]
		else
			x = args[1] or 0
			y = args[2] or 0
		end
		local max_x = args[3] or math.huge
		local max_y = args[4] or math.huge
		return MathFuncs["math.clamp"]({ {x, y}, nil, {-math.huge, -math.huge}, nil, {max_x, max_y} })
	end,
	["math.min"] = function(args)
		local x, y = 0, 0
		if typeof(args[1]) == "table" then
			x = args[1][1]
			y = args[1][2]
		else
			x = args[1] or 0
			y = args[2] or 0
		end
		local min_x = args[3] or -math.huge
		local min_y = args[4] or -math.huge
		return MathFuncs["math.clamp"]({ {x, y}, nil, {min_x, min_y} })
	end,
	["math.rad"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return MathParser.PerfomOperation(x, y, math.pi / 180, 0, "*", true)
	end,
	["math.round"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return math.round(x), y
	end,
	["math.sign"] = function(args)
		local x = args[1]
		if typeof(x) == "table" then
			x = x[1]
		end
		if x > 0 then return 1 elseif x < 0 then return -1 else return 0 end
	end,	
	["math.sqrt"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return MathParser.PerfomOperation(x, y, 0.5, 0, "^", true)
	end,
	["math.tan"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return math.tan((x * getmod(y, math.pi)) % math.pi)
	end,
	["math.log10"] = function(args)
		local x = args[1]
		local y = args[2] or 0
		if typeof(x) == "table" then
			y = x[2]
			x = x[1]
		end
		return math.log10(x), y
	end,
}

local MathConsts = {
	["math.pi"] = math.pi,
	["math.huge"] = math.huge,
	["pi"] = math.pi,
	["e"] = 2.718281828459045,
}

local function formatNum(n, acc)
	acc = acc or 3
	if n ~= n then return "NaN" end
	if n == math.huge then return "inf" end
	if n == -math.huge then return "-inf" end
	if typeof(n) == "table" then
		if not n[1] then n[1] = 0 end
		if not n[2] then n[2] = 0 end
		return math.floor(tonumber(n[1]) * 10^acc) / 10^acc .. "e" .. math.floor(n[2])
	elseif string.find(tostring(n), "e") then
		return tostring(n)
	end
end

local T_NUM = 1
local T_OP = 2
local T_LPAR = 3
local T_RPAR = 4
local T_COMMA = 5
local T_FUNC = 6
local T_VAR = 7
local T_EOF = 8

local function tokenize(expr)
	local tokens = {}
	local len = string.len(expr)
	local i = 1
	while i <= len do
		local c = string.sub(expr, i, i)
		if c == " " or c == "\t" or c == "\n" or c == "\r" then
			i = i + 1
		elseif (string.find(c, "%d")) or (c == "." and i < len and string.find(string.sub(expr, i + 1, i + 1), "%d")) or (string.find(c, "{")) then
			local s = i
			local IsSpecial = false
			while i <= len and string.find(string.sub(expr, i, i), "%d") do
				i = i + 1
			end
			if i <= len and string.sub(expr, i, i) == "." then
				i = i + 1
				while i <= len and string.find(string.sub(expr, i, i), "%d") do
					i = i + 1
				end
			end
			if i <= len then
				local ec = string.sub(expr, i, i)
				if ec == "e" or ec == "E" then
					i = i + 1
					if i <= len then
						local sc = string.sub(expr, i, i)
						if sc == "+" or sc == "-" then
							i = i + 1
						end
					end
					while i <= len and string.find(string.sub(expr, i, i), "%d") do
						i = i + 1
					end
				end
			end
			while i <= len and c == "{" do
				i += 1
				if string.sub(expr, i, i) == "}" then
					i += 1
					tokens[#tokens + 1] = {T_NUM, string.split(string.gsub(string.gsub(string.gsub(string.sub(expr, s, i - 1), "{", ""), "}", ""), " ", ""), ",")}
					IsSpecial = true
					break
				end
			end
			if not IsSpecial then
				tokens[#tokens + 1] = {T_NUM, tonumber(string.sub(expr, s, i - 1))}
			end
		elseif string.find(c, "[%a_]") then
			local s = i
			while i <= len and string.find(string.sub(expr, i, i), "[%a%d_]") do
				i = i + 1
			end
			local ident = string.sub(expr, s, i - 1)
			if ident == "math" and i <= len and string.sub(expr, i, i) == "." then
				i = i + 1
				local fs = i
				while i <= len and string.find(string.sub(expr, i, i), "[%a%d_]") do
					i = i + 1
				end
				local full = "math." .. string.sub(expr, fs, i - 1)
				if MathFuncs[full] then
					tokens[#tokens + 1] = {T_FUNC, full}
				elseif MathConsts[full] then
					tokens[#tokens + 1] = {T_NUM, MathConsts[full]}
				else
					error("[MathParser] Unknown: '" .. full .. "'")
				end
			elseif MathConsts[ident] then
				tokens[#tokens + 1] = {T_NUM, MathConsts[ident]}
			else
				tokens[#tokens + 1] = {T_VAR, ident}
			end
		elseif c == "(" then tokens[#tokens + 1] = {T_LPAR}; i = i + 1
		elseif c == ")" then tokens[#tokens + 1] = {T_RPAR}; i = i + 1
		elseif c == "," then tokens[#tokens + 1] = {T_COMMA}; i = i + 1
		elseif c == "+" or c == "-" or c == "*" or c == "/" or c == "^" or c == "%" then
			tokens[#tokens + 1] = {T_OP, c}
			i = i + 1
		else
			error("3 [MathParser] Bad char '" .. c .. "' at " .. i)
		end
	end
	tokens[#tokens + 1] = {T_EOF}
	return tokens
end

local function parse(tokens)
	local pos = 1
	local function peek() return tokens[pos] end
	local function advance()
		local t = tokens[pos]
		pos = pos + 1
		return t
	end
	local function expect(tt)
		local t = peek()
		if t[1] ~= tt then
			warn("[MathParser] Expected token " .. tt .. " got '" .. tostring(t[2] or "EOF") .. "'")
		end
		return advance()
	end
	local parseExpr
	local function parsePrimary()
		local t = peek()
		if t[1] == T_NUM then
			advance()
			return {1, t[2]}
		elseif t[1] == T_VAR then
			advance()
			return {2, t[2]}
		elseif t[1] == T_LPAR then
			advance()
			local node = parseExpr()
			expect(T_RPAR)
			return node
		else
			error("[MathParser] Unexpected '" .. tostring(t[2] or "EOF") .. "'")
		end
	end
	local function parseCall()
		local t = peek()
		if t[1] == T_FUNC then
			local name = t[2]
			advance()
			expect(T_LPAR)
			local args = {}
			if peek()[1] ~= T_RPAR then
				args[#args + 1] = parseExpr()
				while peek()[1] == T_COMMA do
					advance()
					args[#args + 1] = parseExpr()
				end
			end
			expect(T_RPAR)
			return {5, name, args}
		end
		return parsePrimary()
	end
	local function parseUnary()
		local t = peek()
		if t[1] == T_OP and (t[2] == "-" or t[2] == "+") then
			local op = t[2]
			advance()
			local operand = parseUnary()
			if op == "+" then return operand end
			return {4, op, operand}
		end
		local base = parseCall()
		if peek()[1] == T_OP and peek()[2] == "^" then
			advance()
			local exp = parseUnary()
			return {3, "^", base, exp}
		end
		return base
	end
	local function parseMul()
		local left = parseUnary()
		while true do
			local t = peek()
			if t[1] == T_OP and (t[2] == "*" or t[2] == "/" or t[2] == "%") then
				local op = t[2]
				advance()
				local right = parseUnary()
				left = {3, op, left, right}
			else
				break
			end
		end
		return left
	end
	local function parseAdd()
		local left = parseMul()
		while true do
			local t = peek()
			if t[1] == T_OP and (t[2] == "+" or t[2] == "-") then
				local op = t[2]
				advance()
				local right = parseMul()
				left = {3, op, left, right}
			else
				break
			end
		end
		return left
	end
	parseExpr = parseAdd
	local ast = parseExpr()
	if peek()[1] ~= T_EOF then
		error("[MathParser] Extra tokens after expression")
	end
	return ast
end

local function createEval(trace, settings)
	local run
	run = function(node)
		local ntype = node[1]
		if ntype == 1 then
			return node[2]
		elseif ntype == 2 then
			local name = node[2]
			local val = settings["variables"][name]
			if val == nil then
				local keys = {}
				for k, v in pairs(settings["variables"]) do
					keys[#keys + 1] = tostring(k) .. "=" .. tostring(v)
				end
				local avail = #keys > 0 and table.concat(keys, ", ") or "(empty)"
				warn("[MathParser.createEval] Undefined variable: '" .. name .. "' | Available: {" .. avail .. "}")
			end
			return val
		elseif ntype == 3 then
			local op = node[2]
			local left = run(node[3])
			local right = run(node[4])
			local x, y = MathParser.PerfomOperation(left, right, op, true)
			local step = formatNum(left) .. " " .. op .. " " .. formatNum(right) .. " = " .. formatNum({x, y})
			trace[#trace + 1] = step
			return {x, y}
		elseif ntype == 4 then	
			local operand = run(node[3])
			local result
			if typeof(operand) == "table" then
				result = {-operand[1], operand[2]}
			else
				result = -operand
			end
			local step = "-(" .. formatNum(operand) .. ") = " .. formatNum(result)
			trace[#trace + 1] = step
			return result
		elseif ntype == 5 then
			local fname = node[2]
			local argNodes = node[3]
			local args = {}
			for idx = 1, #argNodes do
				args[idx] = run(argNodes[idx])
			end
			local func = MathFuncs[fname]
			if not func then
				warn("[MathParser.createEval] Unknown function: '" .. fname .. "'")
				return 0
			end
			local result = func(args)
			local argStrs = {}
			for i = 1, #args do
				table.insert(argStrs, formatNum(args[i]))
			end
			local step = fname .. "(" .. table.concat(argStrs, ", ") .. ") = " .. if result ~= nil then formatNum(result) else "NIL"
			trace[#trace + 1] = step
			return result
		end
		warn("[MathParser.createEval] Bad node")
	end
	return run
end

function MathParser.evaluate(expression, settings)
	settings = settings or {}
	local ast = parse(tokenize(expression))
	local trace = {}
	local run = createEval(trace, settings or {})
	local result = run(ast)
	if not settings["table"] then
		if typeof(result) == "table" then
			if not math.isinf(result[1] * 10^result[2]) and settings["scientific"] == false then
				result = result[1] * 10^result[2]
			else
				result = result[1] .. "e" .. result[2]
			end
		end
	end
	if settings["accuracy"] then
		if string.find(tostring(result), "e") then
			local Data = string.split(tostring(result), "e")
			result = math.round(tonumber(Data[1]) * 10^settings["accuracy"]) / 10^settings["accuracy"] .. "e" .. math.round(tonumber(Data[2]) * 10^settings["accuracy"]) / 10^settings["accuracy"]
		else
			result = math.round(result * 10^settings["accuracy"]) / 10^settings["accuracy"]
		end
	end
	return result, trace
end

function MathParser.compile(expression)
	local tokens = tokenize(expression)
	local ast = parse(tokens)
	return function()
		local settings = {}
		local trace = {}
		local run = createEval(trace, settings)
		local result = run(ast)
		return result, trace
	end
end

return MathParser
