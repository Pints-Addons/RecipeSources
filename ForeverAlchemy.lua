-- Pints Recipe Sources: WoW Forever's Alchemy recipes that the Classic data doesn't have, with where each comes from
-- (trainer, vendor and zone, drop or quest), what it makes and what it costs. From Wowhead's WoW Forever database
-- (recipe and pattern pages, November 2026). Open a vendor and Recipe Sources notes exactly where they stand ("seen").
-- rows: { spell, learnedAt, recipeItem, { madeItem, { {reagent, count}, ... } }, trainingCost, vendorPrice, { sources } }
--   source {"x", kind, name, zone, text, faction (0 both / 1 Horde / 2 Alliance), limited}
if type(issecretvalue) ~= "function" then return end      -- (WoW Forever only)
local D = RecipeSourcesData
if not (D and D.recipes and D.make and D.cost and D.price) then return end
local ADD = {
{2329,15,0,{2454,{{2449,1},{765,1},{3371,1}}},52,0,{{"t",1215},{"t",1246},{"t",1386},{"t",1470},{"t",2132},{"t",2391},{"t",2837},{"t",3184},{"t",3347},{"t",3603},{"t",3964},{"t",4160},{"t",4609},{"t",4611},{"t",4900},{"t",5177},{"t",5499},{"t",5500},{"t",7948},{"t",11041},{"t",11042},{"t",11044},{"t",11046},{"t",11047}}},
{17557,275,13481,{13453,{{8846,2},{13466,2},{8925,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop (where from isn't known yet)"}}},
{17632,300,13517,{13503,{{7078,8},{7076,8},{7082,8},{7080,8},{12803,8},{9262,2},{13468,4}}},0,0,{{"x","vendor","Dala Fairmaw (10 Deadwood Tribal Beads)","Mount Hyjal",nil,0,nil}}},
{1230564,20,0,{279956,{{2447,1},{3371,1}}},105,0,{{"t",1215},{"t",1246},{"t",1386},{"t",1470},{"t",2132},{"t",2391},{"t",2837},{"t",3184},{"t",3347},{"t",3603},{"t",3964},{"t",4160},{"t",4609},{"t",4611},{"t",4900},{"t",5177},{"t",5499},{"t",5500},{"t",7948},{"t",11041},{"t",11042},{"t",11044},{"t",11046},{"t",11047},{"x","quest",nil,nil,"Quest reward"}}},
{1231583,250,241651,{241650,{{8925,1},{13466,1},{730,1}}},10000,0,{{"t",1386},{"t",7948}}},
{1244421,250,236754,{246948,{{3819,4},{8846,2},{3372,1}}},0,0,{{"x","quest","Running Firewater"}}},
{1244645,85,0,{247239,{{3371,1},{2450,1},{730,1}}},100,0,{{"t",1215},{"t",1246},{"t",1386},{"t",1470},{"t",2132},{"t",2391},{"t",2837},{"t",3184},{"t",3347},{"t",3603},{"t",3964},{"t",4160},{"t",4609},{"t",4611},{"t",4900},{"t",5177},{"t",5499},{"t",5500},{"t",7948},{"t",11041},{"t",11042},{"t",11044},{"t",11046},{"t",11047}}},
{1244646,135,0,{247240,{{3372,1},{2453,1},{730,1}}},500,0,{{"t",1215},{"t",1246},{"t",1386},{"t",1470},{"t",2132},{"t",2391},{"t",2837},{"t",3184},{"t",3347},{"t",3603},{"t",3964},{"t",4160},{"t",4609},{"t",4611},{"t",4900},{"t",5177},{"t",5499},{"t",5500},{"t",7948},{"t",11041},{"t",11042},{"t",11044},{"t",11046},{"t",11047}}},
{1244647,175,0,{247241,{{3372,1},{3356,1},{730,1}}},1500,0,{{"t",1386},{"t",4160},{"t",4611},{"t",7948}}},
{1244648,230,0,{247242,{{8925,1},{8838,1},{730,1}}},5000,0,{{"t",1386},{"t",7948}}},
{1249630,40,0,{249409,{{249399,2},{3371,1}}},157,0,{{"t",1215},{"t",1246},{"t",1386},{"t",1470},{"t",2132},{"t",2391},{"t",2837},{"t",3184},{"t",3347},{"t",3603},{"t",3964},{"t",4160},{"t",4609},{"t",4611},{"t",4900},{"t",5177},{"t",5499},{"t",5500},{"t",7948},{"t",11041},{"t",11042},{"t",11044},{"t",11046},{"t",11047}}},
{1249631,120,0,{249430,{{249424,2},{3372,1}}},1578,0,{{"t",1215},{"t",1246},{"t",1386},{"t",1470},{"t",2132},{"t",2391},{"t",2837},{"t",3184},{"t",3347},{"t",3603},{"t",3964},{"t",4160},{"t",4609},{"t",4611},{"t",4900},{"t",5177},{"t",5499},{"t",5500},{"t",7948},{"t",11041},{"t",11042},{"t",11044},{"t",11046},{"t",11047}}},
{1249632,215,0,{249431,{{249274,2},{8925,1}}},10000,0,{{"t",1386},{"t",7948}}},
{1249633,40,0,{249410,{{249391,2},{3371,1}}},157,0,{{"t",1215},{"t",1246},{"t",1386},{"t",1470},{"t",2132},{"t",2391},{"t",2837},{"t",3184},{"t",3347},{"t",3603},{"t",3964},{"t",4160},{"t",4609},{"t",4611},{"t",4900},{"t",5177},{"t",5499},{"t",5500},{"t",7948},{"t",11041},{"t",11042},{"t",11044},{"t",11046},{"t",11047}}},
{1250776,195,250363,{250327,{{3818,2},{3821,2},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Nether Sorceress (Desolace)"}}},
{1250777,275,250364,{250328,{{13463,3},{8846,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250778,250,250365,{250329,{{13464,2},{8838,4},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250779,45,250366,{250330,{{785,2},{2453,1},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Murloc Forager (Elwynn Forest), Vile Fin Muckdweller (Tirisfal Glades) +1 more"}}},
{1250780,95,250367,{250331,{{3356,2},{3357,2},{3372,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250781,145,250368,{250332,{{3819,2},{4625,2},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Xavian Hellcaller (Ashenvale)"}}},
{1250782,195,250369,{250333,{{8836,3},{8831,1},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (120 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (120 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250783,150,250370,{250334,{{3821,4},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Kolkar Centaur (Desolace)"}}},
{1250784,200,250371,{250335,{{8838,4},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (120 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (120 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250785,285,250372,{250336,{{13464,3},{13463,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250786,280,250373,{250337,{{13463,4},{13465,2},{18256,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250787,275,250374,{250338,{{13463,4},{13464,2},{18256,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250788,25,250375,{250339,{{785,2},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Young Wendigo, Venture Co. Hireling (Mulgore)"}}},
{1250789,75,250376,{250340,{{3356,3},{3371,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250790,175,250377,{250341,{{8839,3},{8836,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (120 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (120 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250791,120,250378,{250342,{{3356,4},{3372,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250792,285,250379,{250343,{{13464,4},{8838,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250793,15,250380,{250344,{{2449,2},{2447,1},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Gnarlpine Gardener, Kul Tiras Sailor (Durotar)"}}},
{1250794,65,250381,{250345,{{3355,2},{785,1},{3371,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250795,115,250382,{250346,{{3358,3},{3356,1},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Bloodfury Harpy (Stonetalon Mountains)"}}},
{1250796,165,250383,{250347,{{8836,3},{8831,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (120 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (120 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250797,275,250384,{250348,{{13463,3},{8846,1},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250798,150,250385,{250349,{{3355,3},{3821,1},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Shadethicket Oracle (Ashenvale)"}}},
{1250799,275,250386,{250350,{{8846,3},{8845,1},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250800,300,250387,{250351,{{8846,3},{8839,1},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (240 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (240 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250801,95,250388,{250353,{{3356,3},{3372,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1250802,135,250389,{250354,{{3358,3},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Galak Mauler (Thousand Needles)"}}},
{1251729,35,250976,{250932,{{765,1},{2447,1},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Kobold Geomancer (Elwynn Forest), Dustwind Harpy (Durotar)"}}},
{1251730,85,250977,{250933,{{785,1},{765,2},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Blackwood Totemic (Darkshore), Witchwing Windcaller (The Barrens)"}}},
{1251731,135,250978,{250934,{{3355,1},{3369,1},{3371,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251732,185,250979,{250935,{{3356,2},{3818,1},{3372,1}}},0,0,{{"x","vendor","Gorhak (15 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","vendor","Molkar (60 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","quest","A New Need for Shadow Protection"}}},
{1251733,235,250980,{250936,{{3819,2},{3358,2},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Spitelash Screamer (Azshara)"}}},
{1251734,285,250981,{250937,{{13463,2},{13465,1},{18256,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251735,40,250982,{250938,{{2449,1},{765,1},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Bloodfeather Harpy, Windfury Wind Witch (Mulgore) +2 more"}}},
{1251736,90,250983,{250939,{{2450,1},{2449,2},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Raging Rot Hide (Silverpine Forest)"}}},
{1251737,140,250984,{250940,{{3818,2},{2450,2},{3372,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251738,190,250985,{250941,{{4625,3},{3818,2},{3372,1}}},0,0,{{"x","vendor","Gorhak (15 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","vendor","Molkar (60 Carved Centaur Totem)","Desolace",nil,0,nil},{"x","quest","A New Need for Shadow Protection"}}},
{1251739,240,250986,{250942,{{8839,3},{4625,2},{8925,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Northspring Roguefeather (Feralas)"}}},
{1251740,290,250987,{250943,{{13466,3},{8839,2},{18256,1}}},0,0,{{"x","vendor","Apothecary Durelle (240 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (240 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251741,30,250988,{250944,{{785,2},{2453,1},{3371,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Tirisfal Farmer (Tirisfal Glades), Gnarlpine Mystic"}}},
{1251742,80,250989,{250945,{{3356,2},{3357,2},{3372,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Stormscale Siren (Darkshore), Theramore Preserver (The Barrens)"}}},
{1251743,130,250990,{250946,{{3819,2},{4625,2},{3372,1}}},0,0,{{"x","vendor","Apothecary Durelle (45 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (45 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251744,180,250991,{250947,{{8836,2},{8831,1},{8925,1}}},0,0,{{"x","quest",nil,nil,"Quest reward"}}},
{1251745,230,250992,{250948,{{8838,2},{8836,1},{8925,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Vilebranch Witch Doctor (The Hinterlands)"}}},
{1251747,280,250993,{250949,{{13463,3},{8838,1},{18256,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251748,275,250994,{250950,{{8846,3},{13466,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251749,265,250995,{250951,{{8845,2},{3369,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251751,245,250997,{250953,{{13465,2},{4625,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (120 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (120 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251752,280,250998,{250954,{{4625,2},{3819,2},{8925,1}}},0,0,{{"x","vendor","Apothecary Durelle (180 Merchant's Favor)","The Barrens",nil,1,nil},{"x","vendor","Nina Surefire (180 Merchant's Favor)","Redridge Mountains",nil,2,nil}}},
{1251753,280,250999,{250955,{{8846,2},{13466,2},{18256,1}}},0,10000,{{"x","vendor","Algernon","Undercity",nil,1,nil},{"x","quest","Gettin' Buzzed"},{"x","quest","Gettin' Buzzed"}}},
{1263005,140,273085,{279970,{{3372,1},{3356,1},{2452,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Rath'mael"}}},
{1263078,300,273112,{279990,{{273125,1},{8925,1},{13463,2}}},0,0,{{"x","zonedrop",nil,nil,"Drop: Ras Frostwhisper (Scholomance)"}}},
{1317279,275,0,{251290,{{251291,1},{248819,1}}},0,0,{{"x","zonedrop",nil,nil,"Drop (where from isn't known yet)"}}},
}
for _, r in ipairs(ADD) do
	local id, lvl, item, make, train, price, src = r[1], r[2], r[3], r[4], r[5], r[6], r[7]
	if not D.recipes[id] then
		D.recipes[id] = { 171, lvl, item, 0, src }
		if make then D.make[id] = make end
		if train > 0 then D.cost[id] = train end
		if price > 0 and item > 0 and not D.price[item] then D.price[item] = price end
	end
end
