-- Pints Recipe Sources: WoW Forever's Mining recipes that the Classic data doesn't have, with where each comes from
-- (trainer, vendor and zone, drop or quest), what it makes and what it costs. From Wowhead's WoW Forever database
-- (recipe and pattern pages, November 2026). Open a vendor and Recipe Sources notes exactly where they stand ("seen").
-- rows: { spell, learnedAt, recipeItem, { madeItem, { {reagent, count}, ... } }, trainingCost, vendorPrice, { sources } }
--   source {"x", kind, name, zone, text, faction (0 both / 1 Horde / 2 Alliance), limited}
if type(issecretvalue) ~= "function" then return end      -- (WoW Forever only)
local D = RecipeSourcesData
if not (D and D.recipes and D.make and D.cost and D.price) then return end
local ADD = {
{1230161,20,0,{279960,{{2835,1},{2840,1}}},105,0,{{"t",1681},{"t",1701},{"t",3001},{"t",3137},{"t",3175},{"t",3357},{"t",3555},{"t",4254},{"t",4598},{"t",5392},{"t",5513},{"t",6297},{"t",8128},{"x","quest",nil,nil,"Quest reward"}}},
{1249637,275,0,{249726,{{249426,2},{3857,1}}},52631,0,{{"t",1681},{"t",1701},{"t",3001},{"t",3137},{"t",3175},{"t",3357},{"t",3555},{"t",4254},{"t",4598},{"t",5392},{"t",5513},{"t",6297},{"t",8128}}},
{1262975,140,0,{279948,{{2838,2},{2772,1},{2842,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Relic Guardian (Excavation Site: Wetlands)"}}},
{1263071,300,0,{279952,{{12359,5},{12365,2},{6037,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Ambassador Flamelash (Blackrock Depths)"}}},
{1306126,300,0,{251291,{{248815,1}}},52631,0,{{"t",1681},{"t",1701},{"t",3001},{"t",3137},{"t",3175},{"t",3357},{"t",3555},{"t",4254},{"t",4598},{"t",5392},{"t",5513},{"t",6297},{"t",8128}}},
}
for _, r in ipairs(ADD) do
	local id, lvl, item, make, train, price, src = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
	if not D.recipes[id] then
		D.recipes[id] = { 186, lvl, item, 0, src }
		if make then D.make[id] = make end
		if train > 0 then D.cost[id] = train end
		if price > 0 and item > 0 and not D.price[item] then D.price[item] = price end
	end
end
