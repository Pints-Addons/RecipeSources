-- Recipe Sources: unknown recipes for the open profession and where to get them.
-- Standalone: all recipe, source and cost data is bundled in RecipeData.lua (built from the CMaNGOS Classic database).
-- Skill-up colors are learned from your own profession windows as your characters level.

local ADDON = ...
local ev = CreateFrame("Frame")
local DB, CDB

local SKILL = {
	["Alchemy"]=171, ["Blacksmithing"]=164, ["Enchanting"]=333, ["Engineering"]=202,
	["Leatherworking"]=165, ["Tailoring"]=197, ["Cooking"]=185, ["First Aid"]=129,
	["Fishing"]=356, ["Mining"]=186, ["Smelting"]=186,
}
-- specialization skill -> parent profession
local SPEC = { [9788]=164,[9787]=164,[17039]=164,[17040]=164,[17041]=164,
	[10656]=165,[10658]=165,[10660]=165,[20219]=202,[20222]=202 }
local ROOTS = { [-732]="zone", [-75]="instance", [-698]="world", [-734]="event", [-36]="event", [-303]="pvp" }
local ORDER = { trainer=1, vendor=2, quest=3, drop=4, object=5, zonedrop=6, world=7, event=8, other=9 }
local CAT = { trainer="trainer", vendor="vendor", drop="drop", zonedrop="drop", world="drop",
	quest="other", object="other", event="other", other="other" }
local KINDNAME = { trainer="Trainer", vendor="Vendor", quest="Quest", drop="Drop", object="Container",
	zonedrop="Zone drop", world="World drop", event="World event", other="Other" }

local cache = {}      -- skillID -> entries
local scanning = {}   -- skillID -> true
local active          -- "trade" | "craft"
local panel, rows = nil, {}
local tabs = {}

local function SpellName(id)
	if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
	return (GetSpellInfo(id))
end

local function MapName(mapID)
	local info = mapID and C_Map.GetMapInfo(mapID)
	return info and info.name
end

local D = RecipeSourcesData

local function NPCName(id)
	local n = D.npc[id]
	return (n and n[1]) or ("NPC #" .. id)
end

local function MyFaction()
	local f = UnitFactionGroup("player")
	return (f == "Horde" and 1) or (f == "Alliance" and 2) or 0
end

---------------------------------------------------------------- world position -> zone + map coordinates
local INSTANCE = { [33]="Shadowfang Keep", [34]="The Stockade", [36]="The Deadmines", [43]="Wailing Caverns",
	[47]="Razorfen Kraul", [48]="Blackfathom Deeps", [70]="Uldaman", [90]="Gnomeregan", [109]="Sunken Temple",
	[129]="Razorfen Downs", [189]="Scarlet Monastery", [209]="Zul'Farrak", [229]="Blackrock Spire",
	[230]="Blackrock Depths", [249]="Onyxia's Lair", [289]="Scholomance", [309]="Zul'Gurub", [329]="Stratholme",
	[349]="Maraudon", [389]="Ragefire Chasm", [409]="Molten Core", [429]="Dire Maul", [469]="Blackwing Lair",
	[509]="Ruins of Ahn'Qiraj", [531]="Temple of Ahn'Qiraj", [533]="Naxxramas", [30]="Alterac Valley",
	[489]="Warsong Gulch", [529]="Arathi Basin" }
local CONTINENT = { [0] = 1415, [1] = 1414 }     -- Eastern Kingdoms, Kalimdor
local zoneLists, swapXY, locCache = {}, nil, {}

local function ZoneList(cont)
	if zoneLists[cont] then return zoneLists[cont] end
	local list = {}
	local ok, kids = pcall(C_Map.GetMapChildrenInfo, CONTINENT[cont], nil, true)
	for _, info in ipairs(ok and kids or {}) do
		if info.mapType == 3 then   -- zones (cities included)
			local _, a = C_Map.GetWorldPosFromMapPos(info.mapID, CreateVector2D(0, 0))
			local _, b = C_Map.GetWorldPosFromMapPos(info.mapID, CreateVector2D(1, 1))
			if a and b then
				local ax, ay = a:GetXY()
				local bx, by = b:GetXY()
				if ax ~= bx and ay ~= by then
					list[#list + 1] = { id = info.mapID, ax = ax, ay = ay, bx = bx, by = by, area = math.abs((bx - ax) * (by - ay)) }
				end
			end
		end
	end
	table.sort(list, function(p, q) return p.area < q.area end)   -- cities before the zones around them
	zoneLists[cont] = list
	return list
end

local function UV(z, wx, wy, swap)
	if swap then return (wx - z.ax) / (z.bx - z.ax), (wy - z.ay) / (z.by - z.ay) end
	return (wy - z.ay) / (z.by - z.ay), (wx - z.ax) / (z.bx - z.ax)
end

-- Work out once which way round the client's world coordinates are, using a trainer we know is in Stormwind.
local function Calibrate()
	if swapXY ~= nil then return end
	swapXY = false
	local n = D.npc[1346]   -- Georgio Bolero, Stormwind tailoring trainer
	local z
	for _, zz in ipairs(ZoneList(0)) do if zz.id == 1453 then z = zz end end
	if n and n[2] == 0 and z then
		local u, v = UV(z, n[3], n[4], false)
		if not (u >= 0 and u <= 1 and v >= 0 and v <= 1) then swapXY = true end
	end
end

-- returns zoneName, uiMapID, x, y (0-100) or the instance name
local function Locate(map, wx, wy)
	if not map then return end
	local key = map .. ":" .. tostring(wx) .. ":" .. tostring(wy)
	local c = locCache[key]
	if c then return c[1], c[2], c[3], c[4] end
	local res = { INSTANCE[map] }
	if CONTINENT[map] and wx then
		Calibrate()
		for _, z in ipairs(ZoneList(map)) do
			local u, v = UV(z, wx, wy, swapXY)
			if u >= 0 and u <= 1 and v >= 0 and v <= 1 then
				res = { MapName(z.id), z.id, u * 100, v * 100 }
				break
			end
		end
	end
	locCache[key] = res
	return res[1], res[2], res[3], res[4]
end

local function NPCPlace(id, s)
	local n = D.npc[id]
	if n and n[2] then s.zone, s.map, s.x, s.y = Locate(n[2], n[3], n[4]) end
	s.cont = n and n[2]
end

---------------------------------------------------------------- recipe list for a profession
-- source rows: {'t',npc} {'v',npc,limited} {'d',npc,chance} {'w',lo,hi} {'q',quest} {'o',object}
-- the other faction's vendors and quests can still be shown for recipes that are items (they can be traded or sold on
-- the neutral auction house); trainers can't - nobody can learn from the other side's trainer
local FACNAME = { [1] = "Horde", [2] = "Alliance" }
local function MakeSource(row, fac, isItem)
	local k = row[1]
	local other
	if k == "t" or k == "v" then
		local n = D.npc[row[2]]
		if n and n[5] ~= 0 and n[5] ~= fac then
			if k == "t" or not (isItem and DB.otherFaction) then return end
			other = FACNAME[n[5]]
		end
		local s = { kind = (k == "t") and "trainer" or "vendor", npc = row[2], limited = row[3] == 1, other = other }
		NPCPlace(row[2], s)
		return s
	elseif k == "d" then
		local s = { kind = "drop", mobs = { row[2] }, chance = row[3] }
		NPCPlace(row[2], s)
		return s
	elseif k == "w" then
		return { kind = "world", lo = row[2], hi = row[3] }
	elseif k == "q" then
		local q = D.quest[row[2]]
		if q and q[2] ~= 0 and q[2] ~= fac then
			if not (isItem and DB.otherFaction) then return end
			other = FACNAME[q[2]]
		end
		local s = { kind = "quest", name = q and q[1] or ("Quest #" .. row[2]), other = other }
		if q and q[3] ~= 0 then NPCPlace(q[3], s); s.giver = q[3] end
		return s
	elseif k == "o" then
		local o = D.object[row[2]]
		local s = { kind = "object", name = o and o[1] or "Container" }
		if o and o[2] then s.zone, s.map, s.x, s.y = Locate(o[2], o[3], o[4]) end
		return s
	end
end

local function Scan(skillID, done)
	if cache[skillID] then return done(cache[skillID]) end
	if not D then return done(nil, "Recipe data file is missing.") end
	local fac, out = MyFaction(), {}
	local _, _, _, here = UnitPosition("player")
	for id, r in pairs(D.recipes) do
		local spec = r[4]
		if r[1] == skillID and (spec == 0 or IsPlayerSpell(spec)) then
			local e = { id = id, learnedAt = r[2], itemID = (r[3] > 0) and r[3] or nil, sources = {} }
			for _, row in ipairs(r[5]) do
				local s = MakeSource(row, fac, r[3] > 0)
				if s then e.sources[#e.sources + 1] = s end
			end
			if #e.sources > 0 then
				table.sort(e.sources, function(a, b)
					if (a.other ~= nil) ~= (b.other ~= nil) then return b.other ~= nil end    -- your own faction's sources first
					if ORDER[a.kind] ~= ORDER[b.kind] then return ORDER[a.kind] < ORDER[b.kind] end
					local ah, bh = a.cont == here, b.cont == here          -- this continent first
					if ah ~= bh then return ah end
					return (a.chance or 0) > (b.chance or 0)
				end)
				e.name = SpellName(id) or ("Recipe " .. id)
				-- profession rank-ups share the profession's own name ("Engineering"); show which rank it is
				local RANKS = { [50] = "Journeyman", [125] = "Expert", [200] = "Artisan" }
				if not e.itemID and RANKS[e.learnedAt] and not e.name:find(" ") and e.name:find("ing$") or (not e.itemID and RANKS[e.learnedAt] and (e.name == "First Aid")) then
					e.name = RANKS[e.learnedAt] .. " " .. e.name
					e.rankUp = true
				end
				out[#out + 1] = e
			end
		end
	end
	table.sort(out, function(a, b)
		if a.learnedAt ~= b.learnedAt then return a.learnedAt < b.learnedAt end
		return a.name < b.name
	end)
	cache[skillID] = out
	done(out)
end

---------------------------------------------------------------- known recipes
local function CurrentSkill()
	if active == "craft" and GetCraftDisplaySkillLine then
		local name, rank, maxRank = GetCraftDisplaySkillLine()
		return name, rank, maxRank
	elseif active == "trade" then
		local name, rank, maxRank = GetTradeSkillLine()
		return name, rank, maxRank
	end
end

local function RememberKnown(skillID)
	CDB.known[skillID] = CDB.known[skillID] or {}
	local k = CDB.known[skillID]
	local _, rank = CurrentSkill()
	local function seen(name, t)
		if not name or t == "header" then return end
		k[name] = true
		local c = ({ optimal = "o", medium = "y", easy = "g", trivial = "x" })[t]
		if not (c and rank) then return end
		DB.obs[name] = DB.obs[name] or {}
		local o = DB.obs[name]
		o[c .. "min"] = math.min(o[c .. "min"] or rank, rank)
		o[c .. "max"] = math.max(o[c .. "max"] or rank, rank)
	end
	if active == "trade" then
		for i = 1, (GetNumTradeSkills() or 0) do
			local name, t = GetTradeSkillInfo(i)
			seen(name, t)
		end
	elseif active == "craft" then
		for i = 1, (GetNumCrafts() or 0) do
			local name, _, t = GetCraftInfo(i)
			seen(name, t)
		end
	end
end

local function IsKnown(skillID, e)
	if IsPlayerSpell(e.id) then return true end
	local k = CDB.known[skillID]
	return k and k[e.name]
end

---------------------------------------------------------------- text helpers
local function Loc(s)
	local t = s.zone or ""
	if s.x and s.y then t = string.format("%s (%.0f, %.0f)", t, s.x, s.y) end
	return t
end

-- World drops have no mob list: in Classic they come from ordinary mobs near the recipe's item level.
local ZONES = {  -- name, min, max, faction (1 Horde, 2 Alliance, 0 contested)
	{"Elwynn Forest",1,10,2},{"Dun Morogh",1,10,2},{"Teldrassil",1,10,2},{"Durotar",1,10,1},{"Mulgore",1,10,1},
	{"Tirisfal Glades",1,10,1},{"Westfall",10,20,2},{"Loch Modan",10,20,2},{"Darkshore",10,20,2},
	{"The Barrens",10,25,1},{"Silverpine Forest",10,20,1},{"Redridge Mountains",15,25,2},{"Stonetalon Mountains",15,27,0},
	{"Ashenvale",18,30,0},{"Duskwood",18,30,2},{"Hillsbrad Foothills",20,30,0},{"Wetlands",20,30,2},
	{"Thousand Needles",25,35,0},{"Alterac Mountains",30,40,0},{"Arathi Highlands",30,40,0},{"Desolace",30,40,0},
	{"Stranglethorn Vale",30,45,0},{"Dustwallow Marsh",35,45,0},{"Badlands",35,45,0},{"Swamp of Sorrows",35,45,0},
	{"Feralas",40,50,0},{"The Hinterlands",40,50,0},{"Tanaris",40,50,0},{"Searing Gorge",43,50,0},
	{"Azshara",45,55,0},{"Blasted Lands",45,55,0},{"Un'Goro Crater",48,55,0},{"Felwood",48,55,0},
	{"Burning Steppes",50,58,0},{"Western Plaguelands",51,58,0},{"Eastern Plaguelands",53,60,0},
	{"Winterspring",55,60,0},{"Silithus",55,60,0},
}

local function WorldInfo(s)
	local lo, hi = s.lo or 1, s.hi or 60
	local fac, mid, list = MyFaction(), (lo + hi) / 2, {}
	for _, z in ipairs(ZONES) do
		if (z[4] == 0 or z[4] == fac) and z[2] <= hi and z[3] >= lo then list[#list+1] = z end
	end
	table.sort(list, function(a, b) return math.abs((a[2]+a[3])/2 - mid) < math.abs((b[2]+b[3])/2 - mid) end)
	local names = {}
	for i = 1, math.min(#list, 4) do names[i] = list[i][1] end
	return lo, hi, names
end

local function SourceLine(s)
	if s.kind == "world" then
		local lo, hi, names = WorldInfo(s)
		return string.format("World drop: mobs lvl %d-%d%s", lo, hi, names[1] and (" (" .. names[1] .. (names[2] and ", " .. names[2] or "") .. ")") or "")
	end
	if s.kind == "trainer" then return "Trainer" end
	local tag = s.other and ("|cffff5050[" .. s.other .. "]|r ") or ""
	if s.kind == "vendor" then return tag .. "Vendor: " .. NPCName(s.npc) .. (s.limited and " (limited)" or "") .. (s.zone and (" - " .. Loc(s)) or "") end
	if s.kind == "drop" then
		local m = NPCName(s.mobs[1])
		if s.chance and s.chance > 0 then m = m .. string.format(" (%s%%)", s.chance >= 1 and string.format("%.0f", s.chance) or string.format("%.2g", s.chance)) end
		return "Drop: " .. m .. (s.zone and (" - " .. s.zone) or "")
	end
	if s.kind == "quest" then return tag .. "Quest: " .. s.name .. (s.zone and (" - " .. s.zone) or "") end
	if s.kind == "object" then return "Container: " .. s.name .. (s.zone and (" - " .. s.zone) or "") end
	return KINDNAME[s.kind] .. (s.zone and (" - " .. s.zone) or "")
end

---------------------------------------------------------------- costs
-- Trainer costs are recorded when you open any profession trainer; vendor prices when you open a vendor.
-- Until then a vendor price is estimated from the item's sell value (vendors charge 4x sell price).
local function Money(c)
	return GetCoinTextureString and GetCoinTextureString(c) or (c .. "c")
end
-- recorded at a trainer (exact) or the built-in base price (estimate, before rep discounts)
local function TrainerCost(e)
	local c = DB.trainCost[e.name]
	if c then return c end
	c = D.cost[e.id]
	if c then return c, true end
end
local function VendorCost(e)
	if not e.itemID then return end
	if DB.vendCost[e.itemID] then return DB.vendCost[e.itemID] end
	if D.price[e.itemID] then return D.price[e.itemID] end
	local sell = select(11, GetItemInfo(e.itemID))
	if sell and sell > 0 then return sell * 4, true end
end
local function Afford(c, txt)
	if c > (GetMoney() or 0) then return "|cffff4040" .. txt .. "|r" end
	return "|cffffffff" .. txt .. "|r"
end
-- cost for the source shown on the row ("vendor" or "trainer")
local function RowCost(e)
	local first = e.sources[1].kind
	local wantVendor = DB.src == "vendor" or (DB.src ~= "trainer" and first == "vendor")
	local hasTrainer, hasVendor = false, false
	for _, s in ipairs(e.sources) do
		if s.kind == "trainer" then hasTrainer = true elseif s.kind == "vendor" then hasVendor = true end
	end
	if wantVendor and hasVendor then
		local c, est = VendorCost(e)
		if c then return Afford(c, (est and "~" or "") .. Money(c)) end
		return "|cff909090price ?|r"
	elseif hasTrainer and (DB.src == "all" or DB.src == "trainer") and first == "trainer" then
		local c, est = TrainerCost(e)
		if c then return Afford(c, (est and "~" or "") .. Money(c)) end
		return "|cff909090cost ? (visit a trainer)|r"
	end
end

local function ShortSources(e, cat)
	if cat and cat ~= "all" and cat ~= "trainer" then
		local m, n = nil, 0
		for _, s in ipairs(e.sources) do if CAT[s.kind] == cat then n = n + 1; m = m or s end end
		if m then
			local t = SourceLine(m)
			if #e.sources > 1 then t = t .. string.format(" (+%d more)", #e.sources - 1) end
			return t
		end
	end
	local first = e.sources[1]
	local txt = SourceLine(first)
	if first.kind == "trainer" then
		local others = 0
		for _, s in ipairs(e.sources) do if s.kind ~= "trainer" then others = others + 1 end end
		if others > 0 then txt = txt .. ", " .. SourceLine(e.sources[#e.sources - others + 1]) end
		if others > 1 then txt = txt .. string.format(" (+%d)", others - 1) end
	elseif #e.sources > 1 then
		txt = txt .. string.format(" (+%d more)", #e.sources - 1)
	end
	return txt
end

---------------------------------------------------------------- skill-up colors
local C_RED, C_ORANGE, C_YELLOW, C_GREEN, C_GREY = "|cffff2020", "|cffff8040", "|cffffff00", "|cff40bf40", "|cff808080"
-- Red until you can learn it. After that: the real skill-up color once any character on this account
-- has seen the recipe in a profession window (colors fill in as you level); green until then.
local function DiffColor(e, rank)
	if rank < e.learnedAt then return C_RED end
	local o = DB.obs[e.name]
	if not o then return C_GREEN end
	if o.xmin and rank >= o.xmin then return C_GREY end
	if o.gmin and rank >= o.gmin then return C_GREEN end
	if o.ymin and rank >= o.ymin then return C_YELLOW end
	if o.omax and rank <= o.omax then return C_ORANGE end
	if o.omin and not (o.ymin or o.gmin or o.xmin) then return C_ORANGE end
	return C_ORANGE
end

---------------------------------------------------------------- UI
local ROW_H, PANEL_W, PANEL_H = 30, 380, 440

local function ShowTooltip(row)
	local e = row.entry
	if not e then return end
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	if e.itemID then GameTooltip:SetItemByID(e.itemID) else GameTooltip:SetSpellByID(e.id) end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Requires skill " .. e.learnedAt, 1, 0.82, 0)
	local hasT, hasV
	for _, s in ipairs(e.sources) do if s.kind == "trainer" then hasT = true elseif s.kind == "vendor" then hasV = true end end
	if hasT then
		local c, est = TrainerCost(e)
		GameTooltip:AddLine("Training cost: " .. (c and (Afford(c, Money(c)) .. (est and "  (estimated - rep discounts may lower it)" or "")) or "unknown - open a trainer once to record it"), 1, 0.82, 0, true)
	end
	if hasV then
		local c, est = VendorCost(e)
		GameTooltip:AddLine("Vendor price: " .. (c and (Afford(c, Money(c)) .. (est and "  (estimated)" or "")) or "unknown"), 1, 0.82, 0)
	end
	local ob = DB.obs[e.name]
	if ob and (ob.ymin or ob.gmin or ob.xmin) then
		local p = {}
		if ob.ymin then p[#p + 1] = C_YELLOW .. "yellow by " .. ob.ymin .. "|r" end
		if ob.gmin then p[#p + 1] = C_GREEN .. "green by " .. ob.gmin .. "|r" end
		if ob.xmin then p[#p + 1] = C_GREY .. "grey by " .. ob.xmin .. "|r" end
		GameTooltip:AddLine("Skill-ups seen: " .. table.concat(p, ", "), 0.8, 0.8, 0.8, true)
	elseif not ob then
		GameTooltip:AddLine("Skill-up colors appear once a character on this account has this recipe.", 0.6, 0.6, 0.6, true)
	end
	local trainers, n = {}, 0
	for _, s in ipairs(e.sources) do
		if s.kind == "trainer" then
			if #trainers < 4 then trainers[#trainers+1] = NPCName(s.npc) .. (s.zone and (" (" .. s.zone .. ")") or "") end
			n = n + 1
		end
	end
	if n > 0 then
		GameTooltip:AddLine("Trainers:", 0.4, 1, 0.4)
		for _, t in ipairs(trainers) do GameTooltip:AddLine("  " .. t, 1, 1, 1) end
		if n > 4 then GameTooltip:AddLine(string.format("  ...and %d more", n - 4), 0.7, 0.7, 0.7) end
	end
	local shown = 0
	for _, s in ipairs(e.sources) do
		if s.kind ~= "trainer" then
			if shown == 0 then GameTooltip:AddLine("Other sources:", 0.4, 1, 0.4) end
			shown = shown + 1
			if shown <= 10 then
				if s.kind == "world" then
					local lo, hi, names = WorldInfo(s)
					GameTooltip:AddLine(string.format("  World drop - any mob about level %d-%d (approx.)", lo, hi), 1, 1, 1, true)
					GameTooltip:AddLine("  Mob type: not fixed; most often humanoids", 0.8, 0.8, 0.8, true)
					if names[1] then GameTooltip:AddLine("  Zones: " .. table.concat(names, ", "), 0.8, 0.8, 0.8, true) end
				elseif s.kind == "drop" and #s.mobs > 1 then
					local names = {}
					for i = 1, math.min(#s.mobs, 6) do names[#names+1] = NPCName(s.mobs[i]) end
					local more = #s.mobs > 6 and string.format(" +%d", #s.mobs - 6) or ""
					GameTooltip:AddLine("  Drop: " .. table.concat(names, ", ") .. more .. (s.zone and (" - " .. s.zone) or ""), 1, 1, 1, true)
				else
					GameTooltip:AddLine("  " .. SourceLine(s), 1, 1, 1, true)
				end
			end
		end
	end
	if shown > 10 then GameTooltip:AddLine(string.format("  ...and %d more", shown - 10), 0.7, 0.7, 0.7) end
	if TomTom and row.wp then GameTooltip:AddLine("Click: set TomTom waypoint", 0.5, 0.8, 1) end
	GameTooltip:Show()
end

local function RowClick(row)
	local s = row.wp
	if not (s and TomTom and TomTom.AddWaypoint) then return end
	local title = row.entry.name .. " - " .. SourceLine(s)
	pcall(TomTom.AddWaypoint, TomTom, s.map, s.x / 100, s.y / 100, { title = title })
	print("|cff66ccffRecipe Sources:|r waypoint set - " .. title)
end

local function GetRow(i)
	local r = rows[i]
	if r then return r end
	r = CreateFrame("Button", nil, panel.content)
	r:SetSize(PANEL_W - 44, ROW_H)
	r:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
	r.hl = r:CreateTexture(nil, "HIGHLIGHT")
	r.hl:SetAllPoints()
	r.hl:SetColorTexture(1, 1, 1, 0.08)
	r.l1 = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	r.l1:SetPoint("TOPLEFT", 4, -2); r.l1:SetPoint("RIGHT", -40, 0); r.l1:SetJustifyH("LEFT"); r.l1:SetWordWrap(false)
	r.lvl = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	r.lvl:SetPoint("TOPRIGHT", -2, -3)
	r.l2 = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	r.l2:SetPoint("TOPLEFT", r.l1, "BOTTOMLEFT", 8, -1); r.l2:SetPoint("RIGHT", -2, 0); r.l2:SetJustifyH("LEFT"); r.l2:SetWordWrap(false)
	r.l2:SetTextColor(0.75, 0.75, 0.75)
	r:SetScript("OnEnter", ShowTooltip)
	r:SetScript("OnLeave", function() GameTooltip:Hide() end)
	r:SetScript("OnClick", RowClick)
	rows[i] = r
	return r
end

local function SetHeader(r, text)
	r.entry, r.wp = nil, nil
	r.l1:SetText("|cffffd100" .. text .. "|r")
	r.l1:SetFontObject("GameFontNormalLarge")
	r.l2:SetText(""); r.lvl:SetText("")
	r:EnableMouse(false)
end

local function SetEntry(r, e, rank, known)
	r.entry = e
	r.wp = nil
	for _, s in ipairs(e.sources) do if s.map and s.x and s.kind ~= "trainer" then r.wp = s; break end end
	r.l1:SetFontObject("GameFontNormal")
	local col = DiffColor(e, rank)
	r.l1:SetText(col .. e.name .. "|r")
	r.lvl:SetText(e.learnedAt > 0 and (col .. e.learnedAt .. "|r") or "")
	local cost = (not known) and RowCost(e)
	r.l2:SetText(ShortSources(e, DB.src) .. (cost and ("   " .. cost) or ""))
	r:EnableMouse(true)
end

local function Render()
	if not (panel and panel:IsShown()) then return end
	local name, rank, maxRank = CurrentSkill()
	local skillID = name and SKILL[name]
	for _, r in ipairs(rows) do r:Hide() end
	if not skillID then
		panel.status:SetText((name or "This window") .. " isn't supported.")
		return
	end
	rank = rank or 0
	RememberKnown(skillID)
	local list = cache[skillID]
	if not list then
		panel.status:SetText("Loading " .. name .. " recipes...")
		Scan(skillID, function(res, err)
			if not res then panel.status:SetText(err or "No data.") return end
			Render()
		end)
		return
	end
	local status, src = DB.status, DB.src
	local function srcOK(e)
		if src == "all" then return true end
		for _, x in ipairs(e.sources) do if CAT[x.kind] == src then return true end end
	end
	local nowL, laterL, knownL = {}, {}, {}
	for _, e in ipairs(list) do
		if srcOK(e) then
			if IsKnown(skillID, e) then knownL[#knownL+1] = e
			elseif e.learnedAt <= rank then nowL[#nowL+1] = e
			else laterL[#laterL+1] = e end
		end
	end
	local i = 0
	local function add(fn, ...) i = i + 1; local r = GetRow(i); fn(r, ...); r:Show() end
	local function bracketed(L, known)
		local bracket
		for _, e in ipairs(L) do
			local b = math.floor(e.learnedAt / 25) * 25
			if b ~= bracket then
				bracket = b
				local cnt = 0
				for _, x in ipairs(L) do if math.floor(x.learnedAt / 25) * 25 == b then cnt = cnt + 1 end end
				add(SetHeader, string.format("Skill %d-%d (%d)", b, b + 24, cnt))
			end
			add(SetEntry, e, rank, known)
		end
	end
	panel.status2:SetText("")
	if status == "learned" then
		panel.status:SetText(string.format("%s %d/%d  -  %d learned recipes", name, rank, maxRank or 0, #knownL))
		bracketed(knownL, true)
	else
		local total, missing, anyEst = 0, 0, false
		for _, e in ipairs(nowL) do
			if e.sources[1].kind == "trainer" then
				local c, est = TrainerCost(e)
				if c then total = total + c; anyEst = anyEst or est else missing = missing + 1 end
			end
		end
		local train = total > 0 and ("Train all learnable now: " .. Afford(total, (anyEst and "~" or "") .. Money(total)) .. (missing > 0 and " +?" or "")) or ""
		panel.status:SetText(string.format("%s %d/%d  -  %d learnable now, %d unlearned", name, rank, maxRank or 0, #nowL, #nowL + #laterL))
		panel.status2:SetText(train)
		add(SetHeader, string.format("Learnable now (%d)", #nowL))
		for _, e in ipairs(nowL) do add(SetEntry, e, rank) end
		if status == "unlearned" then bracketed(laterL) end
	end
	panel.content:SetHeight(math.max(1, i * ROW_H))
end

local STATUS = { { "unlearned", "All unlearned" }, { "now", "Learnable now" }, { "learned", "Learned" } }
local SOURCES = { { "all", "All" }, { "trainer", "Trainer" }, { "vendor", "Vendor" }, { "drop", "Drop" }, { "other", "Quest/Other" } }

local function FilterRow(list, field, y, w)
	local prev, btns = nil, {}
	for _, f in ipairs(list) do
		local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		b:SetSize(w, 20)
		if prev then b:SetPoint("LEFT", prev, "RIGHT", 3, 0) else b:SetPoint("TOPLEFT", 10, y) end
		b:SetText(f[2])
		b:SetNormalFontObject("GameFontNormalSmall"); b:SetHighlightFontObject("GameFontHighlightSmall"); b:SetDisabledFontObject("GameFontDisableSmall")
		b.key = f[1]
		b:SetScript("OnClick", function(self)
			DB[field] = self.key
			for _, x in ipairs(btns) do x:SetEnabled(x.key ~= DB[field]) end
			Render()
		end)
		b:SetEnabled(b.key ~= DB[field])
		btns[#btns+1] = b
		prev = b
	end
end

local function CreatePanel()
	panel = CreateFrame("Frame", "RecipeSourcesPanel", UIParent, "BackdropTemplate")
	panel:SetSize(PANEL_W, PANEL_H)
	panel:SetFrameStrata("HIGH")
	panel:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 } })
	panel:SetBackdropColor(0, 0, 0, 0.92)
	panel:Hide()
	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 12, -10)
	title:SetText("Learnable Recipes")
	local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", 0, 0)
	close:SetScript("OnClick", function() DB.open = false; panel:Hide() end)
	panel.status = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.status:SetPoint("TOPLEFT", 12, -32); panel.status:SetPoint("RIGHT", -12, 0); panel.status:SetJustifyH("LEFT"); panel.status:SetWordWrap(false)
	panel.status2 = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.status2:SetPoint("TOPLEFT", 12, -46); panel.status2:SetPoint("RIGHT", -12, 0); panel.status2:SetJustifyH("LEFT"); panel.status2:SetWordWrap(false)

	FilterRow(STATUS, "status", -64, 116)
	-- other faction's vendor and quest recipes (they're items: trade them, or buy on the neutral auction house)
	local of = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
	of:SetSize(22, 22); of:SetPoint("TOPRIGHT", -150, -6)
	of.text = of:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); of.text:SetPoint("LEFT", of, "RIGHT", 0, 1); of.text:SetText("Other faction")
	of:SetChecked(DB.otherFaction and true or false)
	of:SetScript("OnClick", function(self) DB.otherFaction = self:GetChecked() and true or false; wipe(cache); Render() end)
	of:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:AddLine("Show the other faction's recipes")
		GameTooltip:AddLine("Adds recipes sold by the other faction's vendors or given by their quests, marked in red. They're items, so a friend on the other side, or the neutral auction house, can get them to you. Trainer recipes stay hidden - those can't cross over.", 1, 1, 1, true)
		GameTooltip:Show() end)
	of:SetScript("OnLeave", function() GameTooltip:Hide() end)
	FilterRow(SOURCES, "src", -88, 68)

	local sf = CreateFrame("ScrollFrame", "RecipeSourcesScroll", panel, "UIPanelScrollFrameTemplate")
	sf:SetPoint("TOPLEFT", 10, -114)
	sf:SetPoint("BOTTOMRIGHT", -30, 10)
	panel.content = CreateFrame("Frame", nil, sf)
	panel.content:SetSize(PANEL_W - 44, 1)
	sf:SetScrollChild(panel.content)
	panel:SetScript("OnShow", Render)
end

local trainerReported, trainerFiltersDone, trainerTotal = nil, nil, 0
local function ScanTrainer(final)
	if not (GetNumTrainerServices and GetTrainerServiceInfo and GetTrainerServiceCost) then return end
	-- once per visit: show every service type (incl. ones you can't learn yet) and open collapsed groups
	if not trainerFiltersDone and (GetNumTrainerServices() or 0) > 0 then
		trainerFiltersDone = true
		if GetTrainerServiceTypeFilter and SetTrainerServiceTypeFilter then
			for _, t in ipairs({ "available", "unavailable", "used" }) do
				if not GetTrainerServiceTypeFilter(t) then SetTrainerServiceTypeFilter(t, 1) end
			end
		end
		if ExpandTrainerSkillLine then pcall(ExpandTrainerSkillLine, 0) end
	end
	local n = 0
	for i = 1, (GetNumTrainerServices() or 0) do
		local name, _, cat = GetTrainerServiceInfo(i)
		if name and name ~= "" and cat ~= "header" then
			local c = GetTrainerServiceCost(i)
			if type(c) == "number" then
				n = n + 1
				DB.trainCost[name] = c
			end
		end
	end
	trainerTotal = math.max(trainerTotal, n)
	if n > 0 and not trainerReported then
		trainerReported = true
		print(("|cff66ccffRecipe Sources:|r recorded %d training costs from this trainer."):format(n))
	elseif final and not trainerReported and ev.trainerOpen then
		print(("|cff66ccffRecipe Sources:|r couldn't read this trainer's list (%d services seen)."):format(GetNumTrainerServices() or 0))
	end
	if panel and panel:IsShown() then Render() end
end

local function ScanMerchant()
	if not (GetMerchantNumItems and GetMerchantItemID) then return end
	local instant = (C_Item and C_Item.GetItemInfoInstant) or GetItemInfoInstant
	for i = 1, (GetMerchantNumItems() or 0) do
		local id = GetMerchantItemID(i)
		if id then
			local classID = select(6, instant(id))
			if classID == 9 then   -- Recipe
				local _, _, price, qty = GetMerchantItemInfo(i)
				if price and price > 0 then DB.vendCost[id] = math.floor(price / math.max(qty or 1, 1)) end
			end
		end
	end
end

local function ActiveFrame()
	if active == "craft" then return CraftFrame end
	return TradeSkillFrame
end

local function ShowPanel()
	local host = ActiveFrame()
	if not host then return end
	if not panel then CreatePanel() end
	panel:ClearAllPoints()
	panel:SetPoint("TOPLEFT", host, "TOPRIGHT", DB.px, DB.py)
	panel:Show()
	Render()
end

local function TogglePanel()
	if panel and panel:IsShown() then DB.open = false; panel:Hide()
	else DB.open = true; ShowPanel() end
end

local function MakeTab(host, which)
	if not host or tabs[which] then return end
	local b = CreateFrame("Button", nil, host, "UIPanelButtonTemplate")
	b:SetSize(100, 22)
	b:SetText("Learnable")
	b:SetPoint("TOPRIGHT", host, "BOTTOMRIGHT", DB.tx, DB.ty)
	b:SetScript("OnClick", function() active = which; TogglePanel() end)
	b:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Recipe Sources")
		GameTooltip:AddLine("Unknown recipes and where to learn them.", 1, 1, 1)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	host:HookScript("OnHide", function() if panel and active == which then panel:Hide() end end)
	tabs[which] = b
end

local function OnOpen(which)
	active = which
	MakeTab(which == "craft" and CraftFrame or TradeSkillFrame, which)
	local name = CurrentSkill()
	local supported = name and SKILL[name]
	if tabs[which] then tabs[which]:SetShown(supported and true or false) end
	if supported then
		Scan(SKILL[name], function() if panel and panel:IsShown() then Render() end end) -- warm cache
		if DB.open then ShowPanel() elseif panel then panel:Hide() end
	elseif panel then
		panel:Hide()
	end
end

ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("TRADE_SKILL_SHOW")
ev:RegisterEvent("TRADE_SKILL_UPDATE")
ev:RegisterEvent("CRAFT_SHOW")
ev:RegisterEvent("CRAFT_UPDATE")
ev:RegisterEvent("SKILL_LINES_CHANGED")
ev:RegisterEvent("GET_ITEM_INFO_RECEIVED")
ev:RegisterEvent("TRAINER_SHOW")
ev:RegisterEvent("TRAINER_UPDATE")
ev:RegisterEvent("TRAINER_CLOSED")
ev:RegisterEvent("TRADE_SKILL_CLOSE")
ev:RegisterEvent("CRAFT_CLOSE")
ev:RegisterEvent("MERCHANT_SHOW")
ev:RegisterEvent("PLAYER_MONEY")
ev:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == ADDON then
		RecipeSourcesDB = RecipeSourcesDB or {}
		RecipeSourcesCharDB = RecipeSourcesCharDB or {}
		DB, CDB = RecipeSourcesDB, RecipeSourcesCharDB
		DB.status = DB.status or "unlearned"
		DB.src = DB.src or "all"
		DB.tx = DB.tx or -40
		DB.ty = DB.ty or 76
		DB.px = DB.px or -34
		DB.py = DB.py or -12
		DB.trainCost = DB.trainCost or {}
		DB.vendCost = DB.vendCost or {}
		DB.obs = DB.obs or {}
		if DB.open == nil then DB.open = true end
		CDB.known = CDB.known or {}
	elseif event == "TRAINER_SHOW" then
		trainerReported, trainerFiltersDone, trainerTotal = nil, nil, 0
		ev.trainerOpen = true
		for _, d in ipairs({ 0.5, 1.5 }) do C_Timer.After(d, function() pcall(ScanTrainer) end) end
		C_Timer.After(3, function()
			local ok, err = pcall(ScanTrainer, true)
			if not ok then print("|cff66ccffRecipe Sources:|r couldn't read trainer - " .. tostring(err)) end
		end)
	elseif event == "TRAINER_UPDATE" then
		if not ev.trainPending then
			ev.trainPending = true
			C_Timer.After(0.3, function() ev.trainPending = nil; pcall(ScanTrainer) end)
		end
	elseif event == "TRAINER_CLOSED" then
		trainerReported = nil
		ev.trainerOpen = nil
	elseif event == "TRADE_SKILL_CLOSE" or event == "CRAFT_CLOSE" then
		if panel and ((event == "TRADE_SKILL_CLOSE" and active == "trade") or (event == "CRAFT_CLOSE" and active == "craft")) then panel:Hide() end
	elseif event == "MERCHANT_SHOW" then
		C_Timer.After(0.2, function() pcall(ScanMerchant) end)
	elseif event == "TRADE_SKILL_SHOW" then
		OnOpen("trade")
	elseif event == "CRAFT_SHOW" then
		OnOpen("craft")
	elseif (event == "TRADE_SKILL_UPDATE" and active == "trade") or (event == "CRAFT_UPDATE" and active == "craft") or event == "SKILL_LINES_CHANGED" or event == "GET_ITEM_INFO_RECEIVED" or event == "PLAYER_MONEY" then
		if panel and panel:IsShown() then
			if not ev.pending then
				ev.pending = true
				C_Timer.After(0.3, function() ev.pending = nil; Render() end)
			end
		end
	end
end)

SLASH_RECIPESOURCES1 = "/rsrc"
SlashCmdList.RECIPESOURCES = function(msg)
	local cmd, a, b = strsplit(" ", (msg or ""):lower())
	if cmd == "tab" and tonumber(a) and tonumber(b) then
		DB.tx, DB.ty = tonumber(a), tonumber(b)
		for which, t in pairs(tabs) do
			t:ClearAllPoints()
			t:SetPoint("TOPRIGHT", which == "craft" and CraftFrame or TradeSkillFrame, "BOTTOMRIGHT", DB.tx, DB.ty)
		end
		print("Recipe Sources: tab offset", DB.tx, DB.ty)
	elseif cmd == "panel" and tonumber(a) and tonumber(b) then
		DB.px, DB.py = tonumber(a), tonumber(b)
		if panel and panel:IsShown() then ShowPanel() end
		print("Recipe Sources: panel offset", DB.px, DB.py)
	elseif cmd == "rescan" then
		wipe(cache)
		print("Recipe Sources: cache cleared")
		if panel and panel:IsShown() then Render() end
	else
		print("|cff66ccffRecipe Sources|r - open a profession and click the Learnable tab.")
		print("  /rsrc tab <x> <y>   move the tab (default -40 76)")
		print("  /rsrc panel <x> <y> move the list (default -34 -12)")
		print("  /rsrc rescan        rebuild the recipe list")
	end
end
