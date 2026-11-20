-- Pints Recipe Sources: WoW Forever's First Aid recipes that the Classic data doesn't have, with where each comes from
-- (trainer, vendor and zone, drop or quest), what it makes and what it costs. From Wowhead's WoW Forever database
-- (recipe and pattern pages, November 2026). Open a vendor and Recipe Sources notes exactly where they stand ("seen").
-- rows: { spell, learnedAt, recipeItem, { madeItem, { {reagent, count}, ... } }, trainingCost, vendorPrice, { sources } }
--   source {"x", kind, name, zone, text, faction (0 both / 1 Horde / 2 Alliance), limited}
if type(issecretvalue) ~= "function" then return end      -- (WoW Forever only)
local D = RecipeSourcesData
if not (D and D.recipes and D.make and D.cost and D.price) then return end
local ADD = {
{1230117,20,0,{279968,{{1251,3},{159,1}}},105,0,{{"t",2326},{"t",2327},{"t",2329},{"t",2798},{"t",3181},{"t",3373},{"t",4211},{"t",4591},{"t",5150},{"t",5759},{"t",5939},{"t",5943},{"t",6094},{"x","quest",nil,nil,"Quest reward"}}},
{1244431,1,0,{118,{{3371,1},{2678,1},{2447,1}}},105,0,{{"t",2326},{"t",2327},{"t",2329},{"t",2798},{"t",3181},{"t",3373},{"t",4211},{"t",4591},{"t",5150},{"t",5759},{"t",5939},{"t",5943},{"t",6094}}},
{1244432,55,0,{858,{{3371,1},{2678,2},{2450,1}}},157,0,{{"t",2326},{"t",2327},{"t",2329},{"t",2798},{"t",3181},{"t",3373},{"t",4211},{"t",4591},{"t",5150},{"t",5759},{"t",5939},{"t",5943},{"t",6094}}},
{1244433,110,0,{929,{{3372,1},{2692,1},{2453,1}}},842,0,{{"t",2326},{"t",2327},{"t",2329},{"t",2798},{"t",3181},{"t",3373},{"t",4211},{"t",4591},{"t",5150},{"t",5759},{"t",5939},{"t",5943},{"t",6094}}},
{1244434,175,255723,{1710,{{3372,1},{2692,3},{3357,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Syndicate Mercenary (Arathi Highlands)"}}},
{1244435,230,255725,{3928,{{8925,1},{3713,1},{8838,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Gordunni Shaman (Feralas)"}}},
{1244436,290,255729,{13446,{{8925,1},{3713,3},{13464,1}}},0,0,{{"x","vendor","Pexmit","Mount Hyjal",nil,0,nil},{"x","quest","A Rest Without Pain"}}},
{1259341,230,255728,{255715,{{255645,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Lost One Muckdweller (Swamp of Sorrows)"}}},
{1259342,90,0,{255716,{{3174,1},{2678,1},{2723,1}}},263,0,{{"t",2326},{"t",2327},{"t",2329},{"t",2798},{"t",3181},{"t",3373},{"t",4211},{"t",4591},{"t",5150},{"t",5759},{"t",5939},{"t",5943},{"t",6094}}},
{1259343,160,255724,{255717,{{1468,1},{3713,1},{2686,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Defias Enchanter (Duskwood)"}}},
{1259344,225,255727,{255718,{{7070,1},{2692,1},{2596,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Syndicate Sentry (Alterac Mountains)"}}},
{1259345,295,255731,{255719,{{7080,1},{2692,1},{2594,1}}},0,0,{{"x","quest","Transmuted Tincture"}}},
{1259347,120,0,{255720,{{2592,2},{2321,2}}},1263,0,{{"t",2326},{"t",2327},{"t",2329},{"t",2798},{"t",3181},{"t",3373},{"t",4211},{"t",4591},{"t",5150},{"t",5759},{"t",5939},{"t",5943},{"t",6094}}},
{1259348,220,255726,{255721,{{4304,2},{4291,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Shadowforge Tunneler (Badlands)"}}},
{1259349,280,255730,{255722,{{8170,2},{14047,2},{8343,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Scarlet Trainee (Scarlet Monastery)"}}},
{1262996,140,0,{279940,{{6452,1},{8544,2},{4470,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Commander Springvale (Shadowfang Keep)"}}},
{1263001,300,0,{279951,{{4470,2},{6453,2},{14530,5}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Doctor Theolen Krastinov (Scholomance)"}}},
}
for _, r in ipairs(ADD) do
	local id, lvl, item, make, train, price, src = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
	if not D.recipes[id] then
		D.recipes[id] = { 129, lvl, item, 0, src }
		if make then D.make[id] = make end
		if train > 0 then D.cost[id] = train end
		if price > 0 and item > 0 and not D.price[item] then D.price[item] = price end
	end
end
