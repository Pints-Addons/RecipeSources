-- Pints Recipe Sources: WoW Forever's Engineering recipes that the Classic data doesn't have, with where each comes from
-- (trainer, vendor and zone, drop or quest), what it makes and what it costs. From Wowhead's WoW Forever database
-- (recipe and pattern pages, November 2026). Open a vendor and Recipe Sources notes exactly where they stand ("seen").
-- rows: { spell, learnedAt, recipeItem, { madeItem, { {reagent, count}, ... } }, trainingCost, vendorPrice, { sources } }
--   source {"x", kind, name, zone, text, faction (0 both / 1 Horde / 2 Alliance), limited}
if type(issecretvalue) ~= "function" then return end      -- (WoW Forever only)
local D = RecipeSourcesData
if not (D and D.recipes and D.make and D.cost and D.price) then return end
local ADD = {
{12716,205,0,{10577,{{10559,2},{3860,4},{10505,5},{10558,1},{7068,1}}},1500,0,{{"t",8126},{"t",8738}}},
{19825,290,16053,{16008,{{10500,1},{12364,2},{12810,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Doomforge Arcanasmith (Blackrock Depths)"}}},
{23079,275,18655,{18637,{{16000,2},{18631,1},{14047,2}}},0,0,{{"x","zonedrop",nil,nil,"Found: Gordok Tribute (Dire Maul)"}}},
{26011,320,0,{21277,{{15407,1},{15994,4},{7079,2},{18631,2},{10558,1}}},0,0,{{"x","quest",nil,nil,"Quest reward"}}},
{28327,275,22729,{22728,{{15994,2},{10561,1},{10558,1}}},0,0,{{"x","vendor","Gelvas Grimegate (40 Darkmoon Prize Tickets)","Elwynn Forest",nil,0,nil},{"x","quest","40 Tickets - Schematic: Steam Tonk Controller"}}},
{435956,200,215429,{213383,{{6037,1},{213381,5}}},0,25000,{{"x","vendor","Ziri \"The Wrench\" Littlesprocket","Gnomeregan",nil,0,nil}}},
{435964,225,215431,{215127,{{10505,1},{215430,1},{3860,2}}},0,50000,{{"x","vendor","Ziri \"The Wrench\" Littlesprocket","Gnomeregan",nil,0,nil}}},
{435966,225,215432,{215168,{{10505,2},{215430,1},{3860,2}}},0,50000,{{"x","vendor","Ziri \"The Wrench\" Littlesprocket","Gnomeregan",nil,0,nil}}},
{1230656,20,0,{279950,{{4359,1},{4361,1}}},105,0,{{"t",1702},{"t",2857},{"t",3290},{"t",3412},{"t",3494},{"t",4586},{"t",5174},{"t",5518},{"t",8736},{"t",10993},{"t",11017},{"t",11025},{"t",11026},{"t",11028},{"t",11029},{"t",11031},{"t",11037},{"x","quest",nil,nil,"Quest reward"}}},
{1249634,120,0,{249432,{{249425,2},{2996,1}}},500,0,{{"t",1676},{"t",3412},{"t",5174},{"t",5518},{"t",8736},{"t",11017},{"t",11029},{"t",11031}}},
{1263034,140,273092,{279949,{{4375,2},{4371,1},{4234,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Sneed (The Deadmines)"}}},
{1263083,300,273117,{279989,{{273129,1},{15994,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Ezra Grimm (Stratholme)"}}},
{1266893,25,264201,{260784,{{2570,1},{249409,1}}},0,0,{{"x","vendor","Fizzlefuse (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266905,25,264202,{260792,{{4357,2},{2589,1}}},0,0,{{"x","vendor","Fizzlefuse (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266906,55,264203,{260793,{{2840,1},{4359,1},{4357,2},{2570,1},{260784,2}}},0,0,{{"x","vendor","Fizzlefuse (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266907,100,264204,{260794,{{2592,1},{249410,1}}},0,0,{{"x","vendor","Fizzlefuse (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266908,130,264205,{260795,{{2840,3},{4364,4},{4404,1},{260794,1}}},0,0,{{"x","vendor","Fizzlefuse (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266909,145,264206,{260796,{{4234,1},{249430,1}}},0,0,{{"x","vendor","Fizzlefuse (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266910,145,264207,{260797,{{4364,4},{2841,2},{4404,1},{2592,1},{260796,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Scarlet Scout (Tirisfal Glades)"}}},
{1266911,150,264208,{260798,{{4377,2},{2592,1},{260796,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Dark Iron Demolitionist (Wetlands), Dragonmaw Saboteur"}}},
{1266912,175,264209,{260799,{{2841,2},{249432,1}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266913,175,264210,{260800,{{4382,1},{4375,1},{4377,2},{2592,2},{260799,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Venture Co. Miner (Stranglethorn Vale)"}}},
{1266914,190,264211,{260801,{{4404,1},{249428,1}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266915,190,264212,{260802,{{4371,4},{4387,1},{4377,4},{2319,4},{260801,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Boulderfist Shaman (Arathi Highlands)"}}},
{1266916,200,264213,{260803,{{3575,1},{4377,1},{4306,1},{260801,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Shadowforge Geologist (Uldaman)"}}},
{1266917,215,264214,{260804,{{10561,1},{4234,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Dark Iron Geologist (Searing Gorge)"}}},
{1266918,215,264215,{260805,{{3575,3},{4377,3},{4404,1},{260804,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Wastewander Thief (Tanaris)"}}},
{1266919,225,264216,{260806,{{4397,1},{260804,1}}},0,0,{{"x","vendor","Fizzlefuse (270 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (270 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266920,225,264217,{260807,{{4234,10},{10559,10},{11175,2},{10558,1}}},0,0,{{"x","vendor","Fizzlefuse (270 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (270 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266921,240,264218,{260808,{{6037,1},{249431,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Jade Ooze (The Hinterlands)"}}},
{1266922,240,264219,{260809,{{10561,1},{10560,1},{10505,1},{260808,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Dunemaul Brute (Tanaris)"}}},
{1266923,250,264220,{260810,{{10518,1},{260804,1}}},0,0,{{"x","vendor","Fizzlefuse (270 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (270 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266924,250,264221,{260811,{{10561,1},{10558,1},{15994,2}}},0,0,{{"x","vendor","Fizzlefuse (270 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (270 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266925,275,264222,{260812,{{12359,5},{16203,5}}},0,0,{{"x","vendor","Fizzlefuse (270 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (270 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266927,275,264224,{260814,{{15992,2},{14047,3},{260813,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Firegut Ogre (Burning Steppes)"}}},
{1266931,300,264228,{260818,{{16006,1},{12359,3},{14047,1},{260815,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Jaedenar Legionnaire (Felwood)"}}},
{1266935,300,264232,{260822,{{249410,2},{249426,1},{249431,1},{12359,3},{3860,1},{248822,1}}},0,0,{{"x","vendor","Fizzlefuse (360 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (360 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266936,300,0,{260823,{{3860,10},{18631,1},{7075,4},{7082,4},{251290,2}}},0,0,{{"x","quest",nil,nil,"Quest reward"}}},
{1266937,300,264234,{260824,{{16204,10},{14344,2},{249726,2},{251290,2}}},0,0,{{"x","vendor","Fizzlefuse (360 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (360 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266938,300,264235,{260825,{{249431,2},{249726,2},{249429,8},{12359,8}}},0,0,{{"x","vendor","Fizzlefuse (360 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (360 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1266940,300,264237,{260827,{{7082,6},{16204,6},{248820,2},{251290,2},{248823,4}}},0,0,{{"x","vendor","Fizzlefuse (360 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (360 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1286792,190,269901,{269900,{{4387,6},{4389,2},{10558,4},{4234,30}}},0,0,{{"x","vendor","Gorhak (15 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","vendor","Molkar (60 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","quest","Gizmo for Warug"}}},
{1286796,140,269903,{269902,{{4387,3},{4382,2},{4389,1},{10558,1},{4234,4}}},0,0,{{"x","vendor","Gorhak (15 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","vendor","Molkar (60 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","quest","Gizmo for Warug"}}},
{1293088,125,274049,{274048,{{249409,1},{249391,1},{3575,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Crowd Pummeler 9-60 (Gnomeregan)"}}},
{1302161,65,277470,{277132,{{255007,4},{4363,2},{4405,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Decrepit Harvester (Tirisfal Glades)"},{"x","quest","Harvesting the Harvesters"}}},
{1308178,175,280321,{280306,{{4382,2},{4375,1},{4305,2}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1308179,175,280322,{280307,{{4375,2},{4382,1},{2319,4}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1308180,175,280323,{280308,{{4371,2},{4363,1},{2319,4}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1308183,200,280325,{280310,{{5507,1},{4389,1},{4339,4}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1308184,200,280326,{280311,{{5507,1},{4389,1},{4234,8}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1308185,200,280327,{280312,{{5507,1},{4389,1},{4234,8}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1308186,200,280328,{280313,{{5507,1},{4389,1},{3860,2}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1317270,260,284870,{284869,{{18631,1},{12655,2},{15992,3},{14047,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Crushridge Warmonger (Alterac Mountains)"}}},
{1317958,85,285285,{285275,{{4360,20},{2318,6},{4359,4}}},0,0,{{"x","vendor","Fizzlefuse (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1317959,165,285286,{285276,{{4380,20},{2319,6},{4375,1}}},0,0,{{"x","vendor","Fizzlefuse (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1317960,230,285287,{285277,{{4394,20},{4304,6},{4389,1}}},0,0,{{"x","vendor","Fizzlefuse (270 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (270 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1317961,285,285288,{285278,{{16005,20},{8170,6},{10560,1}}},0,0,{{"x","vendor","Fizzlefuse (270 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Fritz Fizzle (270 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
}
for _, r in ipairs(ADD) do
	local id, lvl, item, make, train, price, src = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
	if not D.recipes[id] then
		D.recipes[id] = { 202, lvl, item, 0, src }
		if make then D.make[id] = make end
		if train > 0 then D.cost[id] = train end
		if price > 0 and item > 0 and not D.price[item] then D.price[item] = price end
	end
end
