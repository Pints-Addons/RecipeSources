-- Pints Recipe Sources: where the recipes Classic also has come from on WoW Forever, where that differs from the Classic data -
-- vendors that sell them now (and ones that stopped), drops and quest rewards - from Wowhead's WoW Forever recipe pages
-- (November 20, 2026). Trainers are kept as they were (checked separately). [spellID] = { sources } (see RecipeData.lua).
if type(issecretvalue) ~= "function" then return end      -- (WoW Forever only)
local D = RecipeSourcesData
if not (D and D.recipes) then return end
for id, src in pairs({
[4508]={{"x","quest","Wild Eyes"},{"x","quest","My First Real Potion"}},
[6413]={{"v",3881},{"x","vendor","Naluk","Riverglades",nil,1,nil}},
[6624]={{"v",3348,1},{"v",4226,1},{"v",5178,1},{"v",12245,1}},
[6618]={{"v",3335,1},{"v",4226,1},{"v",12245}},
[6688]={{"v",777,1},{"v",1454,1},{"v",1474,1},{"v",3005,1},{"v",3364,1},{"d",450,2.56},{"d",2264,1.8}},
[7149]={{"v",2810,1},{"v",2821,1},{"v",3958,1},{"v",4877,1},{"v",12245}},
[3449]={{"v",2481,1},{"v",4878,1},{"v",12245}},
[7630]={{"v",66,1},{"v",3364,1},{"v",3485,1},{"v",3522,1},{"v",4189,1}},
[7639]={{"v",843,1},{"v",1347,1},{"v",2394,1},{"v",3364,1},{"v",5944,1}},
[7643]={{"v",1454,1},{"v",1474,1},{"v",2669,1},{"v",3499,1},{"v",4168,1}},
[7751]={{"v",66},{"v",1684},{"v",3029},{"v",3550},{"v",4265}},
[7753]={{"v",66},{"v",1684},{"v",3027},{"v",4265},{"v",4574}},
[7755]={{"v",2383},{"v",2397},{"v",3027},{"v",3029},{"v",3497}},
[7443]={{"v",1318,1},{"v",3012,1},{"v",3346,1},{"v",4228,1},{"v",4617,1},{"d",15811,1.0},{"d",2186,0.07},{"w",7,20},{"o",2039},{"o",2847},{"o",106319}},
[7776]={},
[7827]={{"v",3178},{"v",3333},{"v",3497},{"v",4305},{"v",4307}},
[7828]={{"v",2383},{"v",2664},{"v",3178},{"v",3333},{"v",4307}},
[3870]={{"v",2394,1},{"v",2669,1},{"v",12246}},
[8789]={{"v",2670,1},{"v",12246,1},{"x","vendor","Norvin Alderman","Alterac Mountains",nil,2,nil}},
[8802]={{"v",6568,1},{"x","vendor","Stitch Pinwizzle","Riverglades",nil,0,nil}},
[8786]={{"v",6574,1},{"v",6576,1},{"x","vendor","Norvin Alderman","Alterac Mountains",nil,2,nil}},
[9202]={{"v",4225,1},{"v",4589,1},{"v",7852,1},{"v",7854,1},{"v",12245}},
[9273]={{"v",3134,1},{"v",3537,1},{"v",4086,1},{"v",12246}},
[3772]={{"v",2679,1},{"v",2698,1},{"v",12245}},
[10544]={{"q",2849},{"q",2856},{"x","quest","Wild Leather Vest"},{"x","quest","Wild Leather Vest"}},
[15855]={{"v",734},{"v",1148},{"v",2810},{"v",2821},{"v",4879}},
[16660]={{"v",10856},{"v",10857},{"v",11536},{"d",14887,0},{"d",10184,0},{"d",14888,0},{"d",14889,0},{"d",14890,0},{"d",12397,0},{"o",179697}},
[16659]={{"o",179697},{"o",153453},{"o",153454},{"x","zonedrop",nil,nil,"Drop: Azuregos (Azshara), Ysondre (Duskwood) +more"}},
[16724]={{"o",179697},{"o",153453},{"o",153454},{"x","zonedrop",nil,nil,"Drop: Lethon (Duskwood)"}},
[3957]={{"v",2684},{"v",12246}},
[3979]={{"v",2685,1},{"v",12246,1}},
[17573]={{"o",179697},{"o",153453},{"o",153454},{"x","zonedrop",nil,nil,"Drop: Azuregos (Azshara)"}},
[17634]={{"x","vendor","Pix Xizzix","Stranglethorn Vale",nil,0,nil},{"o",179697},{"o",153453},{"o",153454},{"x","zonedrop",nil,nil,"Drop: Azuregos (Azshara), Emeriss (Duskwood)"}},
[17635]={{"x","vendor","Pix Xizzix","Stranglethorn Vale",nil,0,nil},{"d",10363,3.0}},
[17636]={{"x","vendor","Pix Xizzix","Stranglethorn Vale",nil,0,nil},{"x","zonedrop",nil,nil,"Drop: Grand Crusader Dathrohan (Stratholme)"}},
[17637]={{"x","vendor","Pix Xizzix","Stranglethorn Vale",nil,0,nil},{"d",10508,4.0}},
[17638]={{"x","vendor","Pix Xizzix","Stranglethorn Vale",nil,0,nil},{"d",10339,3.0}},
[18440]={{"o",179697},{"o",153453},{"o",153454},{"x","zonedrop",nil,nil,"Drop: Azuregos (Azshara), Taerar (Duskwood)"}},
[18448]={{"o",179697},{"o",153454},{"o",181798},{"x","zonedrop",nil,nil,"Drop: Azuregos (Azshara), Lethon (Duskwood)"}},
[18453]={{"o",153454},{"o",181798},{"o",160845},{"x","zonedrop",nil,nil,"Drop: Gruff (Un'Goro Crater)"}},
[18456]={{"x","zonedrop",nil,nil,"Drop: Grand Crusader Dathrohan (Stratholme)"}},
[3857]={{"v",2670,1},{"v",12246,1}},
[3778]={{"v",2699,1},{"v",12245,1}},
[3952]={{"v",2682,1},{"v",2683,1},{"x","vendor","Namdo Bizzfizzle",nil,nil,2,true}},
[19814]={{"v",11185,1},{"x","vendor","Kor'gar","Riverglades",nil,0,nil}},
[19795]={{"v",11185,1},{"x","vendor","Kor'gar","Riverglades",nil,0,nil}},
[19831]={{"o",179697},{"o",153453},{"o",153454},{"x","zonedrop",nil,nil,"Drop: Azuregos (Azshara)"}},
[20031]={{"x","zonedrop",nil,nil,"Drop: Spirestone Warlord (Blackrock Spire)"}},
[20011]={{"o",179697},{"o",153453},{"o",153454},{"x","zonedrop",nil,nil,"Drop: Flesh Golem (Western Plaguelands), Rockwing Screecher (Stratholme) +more"}},
[20025]={{"x","zonedrop",nil,nil,"Drop: Azuregos (Azshara)"}},
[20626]={{"v",8139,1},{"x","vendor","Grizzek","Riverglades",nil,0,nil}},
[20916]={{"v",2383},{"v",2664},{"v",3178},{"v",3333},{"v",4307}},
[22480]={{"v",4782},{"v",7733},{"v",8125},{"x","vendor","Innkeeper Zizplink","Riverglades",nil,0,nil}},
[23069]={{"v",8131,1},{"x","vendor","Fizzix Boomshot","Riverglades",nil,0,nil}},
[25125]={{"v",1318},{"v",3012},{"v",3346},{"v",4228},{"v",4617}},
[25126]={{"v",1318},{"v",3012},{"v",3346},{"v",4228},{"v",4617}},
[25127]={{"v",12944},{"v",15419}},
[25128]={{"v",12944},{"v",15419}},
[25124]={{"v",1318},{"v",3012},{"v",3346},{"v",4228},{"v",4617}},
[25704]={{"v",2381},{"v",2397},{"v",2664},{"v",3027},{"v",3085}},
[25954]={{"v",2381},{"v",2397},{"v",2664},{"v",3027},{"v",3085}},
[26085]={{"v",6568},{"x","vendor","Stitch Pinwizzle","Riverglades",nil,0,nil}},
[27658]={{"v",1318},{"v",3012},{"v",3346},{"v",4228},{"v",4617}},
[27659]={{"v",12944},{"v",15419}},
[27829]={{"o",179697},{"x","zonedrop",nil,nil,"Drop: Taerar (Duskwood), Ysondre (Duskwood)"}},
}) do local r = D.recipes[id]; if r then r[5] = src end end
-- Classic recipes WoW Forever's recipe lists don't have (Wowhead, November 20, 2026): Heavy Shot and the Ironvine
-- Breastplate, Gloves and Belt. Hidden from Learnable Recipes until they're confirmed; /rsrc classic shows them.
D.unconfirmed = {}
for _, id in ipairs({ 3964, 28461, 28462, 28463 }) do
	if D.recipes[id] then D.unconfirmed[id] = D.recipes[id]; D.recipes[id] = nil end
end
local qf = CreateFrame("Frame")
qf:RegisterEvent("ADDON_LOADED")
qf:SetScript("OnEvent", function(self, _, name)
	if name ~= "RecipeSources" then return end
	self:UnregisterEvent("ADDON_LOADED")
	if RecipeSourcesDB and RecipeSourcesDB.showUnconfirmed then
		for id, r in pairs(D.unconfirmed) do D.recipes[id] = r end
	end
end)
