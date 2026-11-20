-- Pints Recipe Sources: WoW Forever's Cooking recipes that the Classic data doesn't have, with where each comes from
-- (trainer, vendor and zone, drop or quest), what it makes and what it costs. From Wowhead's WoW Forever database
-- (recipe and pattern pages, November 2026). Open a vendor and Recipe Sources notes exactly where they stand ("seen").
-- rows: { spell, learnedAt, recipeItem, { madeItem, { {reagent, count}, ... } }, trainingCost, vendorPrice, { sources } }
--   source {"x", kind, name, zone, text, faction (0 both / 1 Horde / 2 Alliance), limited}
if type(issecretvalue) ~= "function" then return end      -- (WoW Forever only)
local D = RecipeSourcesData
if not (D and D.recipes and D.make and D.cost and D.price) then return end
local ADD = {
{24801,325,0,{20452,{{20424,1},{3713,1}}},0,0,{{"x","quest",nil,nil,"Quest reward"}}},
{1229737,20,0,{279981,{{4470,1}}},105,0,{{"t",1355},{"t",1382},{"t",1430},{"t",1699},{"t",3026},{"t",3067},{"t",3087},{"t",3399},{"t",4210},{"t",4552},{"t",5159},{"t",5482},{"t",6286},{"t",8306}}},
{1249957,25,249879,{249865,{{159,1},{2447,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Frostmane Seer"}}},
{1249958,100,249880,{249866,{{1179,1},{785,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Windshear Geomancer (Stonetalon Mountains)"}}},
{1249959,125,249881,{249867,{{1205,1},{3357,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Torn Fin Oracle (Hillsbrad Foothills)"}}},
{1249960,180,249882,{249868,{{1708,1},{3818,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Woodpaw Mystic (Feralas)"}}},
{1249961,200,249883,{249869,{{1645,1},{8838,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Marsh Oracle (Swamp of Sorrows)"}}},
{1249962,250,249884,{249870,{{8766,1},{13465,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Deadwind Ogre Mage"}}},
{1250142,225,250173,{250065,{{5471,2},{2692,3}}},0,0,{{"x","vendor","Qia","Winterspring",nil,0,nil}}},
{1250144,275,250175,{250067,{{12223,3},{3713,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Monstrous Plaguebat (Eastern Plaguelands)"}}},
{1250145,275,250176,{250068,{{3712,3},{3713,3}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Child of Tortolla (Mount Hyjal)"}}},
{1250146,275,250177,{250069,{{12203,3},{3713,3}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Ghostfang Alpha (Mount Hyjal)"}}},
{1250147,275,250178,{250070,{{3730,3},{3713,3}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Rabid Shardtooth (Winterspring)"}}},
{1250148,275,250179,{250071,{{5471,3},{3713,4}}},0,0,{{"x","quest",nil,nil,"Quest reward"}}},
{1250149,275,250180,{250072,{{12202,3},{3713,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Frostsaber Pride Watcher (Winterspring)"}}},
{1250150,180,250181,{250073,{{12184,2},{2692,3}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Venomhide Ravasaur (Un'Goro Crater)"}}},
{1250151,175,250182,{250074,{{3730,2},{2692,3}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Ashenvale Bear"}}},
{1250152,275,250183,{250075,{{12184,3},{3713,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Ravasaur Hunter, Ravasaur Matriarch +3 more"}}},
{1250153,225,250184,{250076,{{12184,2},{2692,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Bloodfen Lashtail (Dustwallow Marsh)"}}},
{1250154,75,250185,{250077,{{12184,1},{2678,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Young Stranglethorn Raptor (Stranglethorn Vale)"},{"x","quest","Changing Tastes"}}},
{1250155,175,250186,{250078,{{12207,2},{2692,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Lost One Cook (Swamp of Sorrows)"}}},
{1250156,25,250187,{250079,{{3685,1},{2678,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Mottled Raptor (Wetlands), Sunscale Screecher (The Barrens)"}}},
{1250157,75,250188,{250080,{{6889,1},{2678,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Dire Condor (Redridge Mountains)"}}},
{1250158,275,250189,{250081,{{7974,3},{3713,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Spitelash Enchantress (Azshara)"}}},
{1252566,85,251526,{251525,{{251524,1},{2678,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Murloc Flesheater, Redridge Poacher (Redridge Mountains) +more"}}},
{1262978,140,0,{279957,{{12037,2},{12204,1},{3713,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Cookie (The Deadmines)"}}},
{1263067,300,0,{279982,{{10284,10},{159,5},{3713,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Quartermaster Zigris (Lower Blackrock Spire)"}}},
{1270633,25,263511,{263509,{{6889,2},{10284,1}}},0,0,{{"x","quest","Restocking the Larders"}}},
{1270635,35,263513,{263512,{{2675,1},{10284,1}}},0,0,{{"x","quest","Crab Season"}}},
{1283400,90,0,{279961,{{11291,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Lord Serpentis (Wailing Caverns)"}}},
{1291341,200,0,{279974,{{272941,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Slavecrusher Grox (Krol'dok Stronghold)"}}},
{1294014,275,274415,{267341,{{249796,3},{3713,1}}},0,0,{{"x","vendor","Dala Fairmaw","Mount Hyjal",nil,0,nil}}},
{1295805,200,274972,{274971,{{730,2},{12206,1},{2692,1}}},0,0,{{"x","vendor","Fimbo Greasemitz",nil,nil,0,nil},{"x","quest","A Taste of the Sea"}}},
{1295834,185,274977,{274976,{{769,2},{2678,1}}},0,0,{{"x","quest","Paletusk Harvesting"}}},
{1319313,225,286153,{286152,{{13890,1},{3713,1}}},0,0,{{"x","zonedrop",nil,nil,"Found: Recipe: Raw Plated Armorfish (Deadwind Pass)"}}},
}
for _, r in ipairs(ADD) do
	local id, lvl, item, make, train, price, src = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
	if not D.recipes[id] then
		D.recipes[id] = { 185, lvl, item, 0, src }
		if make then D.make[id] = make end
		if train > 0 then D.cost[id] = train end
		if price > 0 and item > 0 and not D.price[item] then D.price[item] = price end
	end
end
