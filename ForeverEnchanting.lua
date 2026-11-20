-- Pints Recipe Sources: WoW Forever's Enchanting recipes that the Classic data doesn't have, with where each comes from
-- (trainer, vendor and zone, drop or quest), what it makes and what it costs. From Wowhead's WoW Forever database
-- (recipe and pattern pages, November 2026). Open a vendor and Recipe Sources notes exactly where they stand ("seen").
-- rows: { spell, learnedAt, recipeItem, { madeItem, { {reagent, count}, ... } }, trainingCost, vendorPrice, { sources } }
--   source {"x", kind, name, zone, text, faction (0 both / 1 Horde / 2 Alliance), limited}
if type(issecretvalue) ~= "function" then return end      -- (WoW Forever only)
local D = RecipeSourcesData
if not (D and D.recipes and D.make and D.cost and D.price) then return end
local ADD = {
{1230643,20,0,{279976,{{4470,1},{10940,1}}},105,0,{{"t",3011},{"t",3345},{"t",4213},{"t",4616},{"t",5157},{"t",7949},{"x","quest",nil,nil,"Quest reward"}}},
{1248458,70,249474,{0,{{10938,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Vile Fin Tidehunter (Silverpine Forest), Coastal Frenzy (Darkshore)"}}},
{1248459,90,249475,{0,{{10938,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Dark Strand Cultist"}}},
{1248460,140,249486,{0,{{11134,1}}},0,0,{{"x","quest","Mysterious Mysticism"}}},
{1248461,185,249487,{249144,{{11174,1},{11176,1},{11291,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Boulderfist Magus (Arathi Highlands)"}}},
{1248497,190,249488,{0,{{11137,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Mage Hunter (Desolace)"}}},
{1248498,205,249489,{0,{{11134,2}}},0,0,{{"x","quest","Mysterious Mysticism"}}},
{1248500,240,249514,{0,{{11176,3},{11174,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Deadwood Gardener (Felwood)"}}},
{1248505,245,249515,{249232,{{16202,1},{11176,1},{11291,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Muculent Ooze (Un'Goro Crater)"}}},
{1248509,215,249512,{249234,{{11174,2},{11137,1},{11291,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Dustbelcher Ogre Mage"}}},
{1248510,210,249511,{0,{{11137,2},{11139,1},{11174,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Firemane Scout (Dustwallow Marsh)"}}},
{1248511,220,249513,{0,{{11137,1},{11139,1},{11174,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Hatecrest Sorceress (Feralas)"}}},
{1248528,250,249516,{0,{{11176,2},{15407,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Spitelash Myrmidon (Azshara)"}}},
{1248599,295,249524,{0,{{16204,3},{16203,3},{14344,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Thuzadin Acolyte (Stratholme)"}}},
{1248668,290,249523,{0,{{14344,8},{16203,10},{16204,8},{12363,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Spectral Tutor (Scholomance)"}}},
{1249112,265,249520,{249470,{{11382,1},{7076,1},{14343,3}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Pyroguard Emberseer (Blackrock Spire)"}}},
{1249114,265,249521,{249473,{{11382,1},{7080,1},{14343,3}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Mother Smolderweb (Blackrock Spire)"}}},
{1263056,140,0,{279985,{{11137,2},{11174,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Charlga Razorflank (Razorfen Kraul)"}}},
{1263082,300,0,{279987,{{273128,1},{14344,2},{16203,4}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Nanaya (Shaper's Terrace)"}}},
{1294054,295,274424,{0,{{248822,1},{14343,2},{16204,12},{16202,4}}},0,0,{{"x","vendor","Dala Fairmaw","Mount Hyjal",nil,0,nil}}},
}
for _, r in ipairs(ADD) do
	local id, lvl, item, make, train, price, src = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
	if not D.recipes[id] then
		D.recipes[id] = { 333, lvl, item, 0, src }
		if make then D.make[id] = make end
		if train > 0 then D.cost[id] = train end
		if price > 0 and item > 0 and not D.price[item] then D.price[item] = price end
	end
end
