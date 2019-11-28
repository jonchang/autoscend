script "auto_pre_adv.ash";
import<autoscend.ash>

void handlePreAdventure()
{
	handlePreAdventure(my_location());
}

void handlePreAdventure(location place)
{
	if((equipped_item($slot[familiar]) == $item[none]) && (my_familiar() != $familiar[none]) && (auto_my_path() == "Heavy Rains"))
	{
		abort("Familiar has no equipment, WTF");
	}

	if(get_property("customCombatScript") != "autoscend_null")
	{
		abort("customCombatScript is set to unrecognized '" + get_property("customCombatScript") + "', should be 'autoscend_null'");
	}

	if(get_property("auto_disableAdventureHandling").to_boolean())
	{
		auto_log_info("Preadventure skipped by standard adventure handler.", "green");
		return;
	}

	if(last_monster().random_modifiers["clingy"])
	{
		auto_log_info("Preadventure skipped by clingy modifier.", "green");
		return;
	}

	if(place == $location[The Lower Chambers])
	{
		auto_log_info("Preadventure skipped by Ed the Undying!", "green");
		return;
	}

	auto_log_info("Starting preadventure script...", "green");
	auto_log_debug("Adventuring at " + place.to_string(), "green");

	familiar famChoice = to_familiar(get_property("auto_familiarChoice"));
	if(auto_my_path() == "Pocket Familiars")
	{
		famChoice = $familiar[none];
	}

	if((famChoice != $familiar[none]) && !is100FamiliarRun() && (internalQuestStatus("questL13Final") < 13))
	{
		if((famChoice != my_familiar()) && !get_property("kingLiberated").to_boolean())
		{
#			auto_log_error("FAMILIAR DIRECTIVE ERROR: Selected " + famChoice + " but have " + my_familiar(), "red");
			use_familiar(famChoice);
		}
	}

	if(auto_have_familiar($familiar[cat burglar]))
	{
		item[monster] heistDesires = catBurglarHeistDesires();
		boolean wannaHeist = false;
		foreach mon, it in heistDesires
		{
			foreach i, mmon in get_monsters(place)
			{
				if(mmon == mon)
				{
					auto_log_debug("Using cat burglar because we want to burgle a " + it + " from " + mon);
					wannaHeist = true;
				}
			}
		}
		if(wannaHeist && (famChoice != $familiar[none]) && !is100FamiliarRun())
		{
			use_familiar($familiar[cat burglar]);
		}
	}

	if((place == $location[The Deep Machine Tunnels]) && (my_familiar() != $familiar[Machine Elf]))
	{
		if(!auto_have_familiar($familiar[Machine Elf]))
		{
			auto_log_critical("Massive failure, we don't use snowglobes.");
			abort("Massive failure, we don't use snowglobes.");
		}
		auto_log_error("Somehow we are going to the DMT without a Machine Elf...", "red");
		use_familiar($familiar[Machine Elf]);
	}

	if(my_familiar() == $familiar[Trick-Or-Treating Tot])
	{
		if($locations[A-Boo Peak, The Haunted Kitchen] contains place)
		{
			if(equipped_item($slot[Familiar]) != $item[Li\'l Candy Corn Costume])
			{
				if(item_amount($item[Li\'l Candy Corn Costume]) > 0)
				{
					equip($slot[Familiar], $item[Li\'l Candy Corn Costume]);
				}
			}
		}
	}

	preAdvXiblaxian(place);

	if(get_floundry_locations() contains place)
	{
		buffMaintain($effect[Baited Hook], 0, 1, 1);
	}

	if((my_mp() < 30) && ((my_mp()+20) < my_maxmp()) && (item_amount($item[Psychokinetic Energy Blob]) > 0))
	{
		use(1, $item[Psychokinetic Energy Blob]);
	}

	if((get_property("_bittycar") == "") && (item_amount($item[Bittycar Meatcar]) > 0))
	{
		use(1, $item[Bittycar Meatcar]);
	}

	if((have_effect($effect[Coated in Slime]) > 0) && (place != $location[The Slime Tube]))
	{
		visit_url("clan_slimetube.php?action=chamois&pwd");
	}

	if((place == $location[The Broodling Grounds]) && (my_class() == $class[Seal Clubber]))
	{
		uneffect($effect[Spiky Shell]);
		uneffect($effect[Scarysauce]);
	}

	if($locations[Next to that Barrel with something Burning In It, Near an Abandoned Refrigerator, Over where the Old Tires Are, Out by that Rusted-Out Car] contains place)
	{
		uneffect($effect[Spiky Shell]);
		uneffect($effect[Scarysauce]);
	}

	if(my_path() == $class[Avatar of Boris])
	{
		if((have_effect($effect[Song of Solitude]) == 0) && (have_effect($effect[Song of Battle]) == 0))
		{
			//When do we consider Song of Cockiness?
			buffMaintain($effect[Song of Fortune], 10, 1, 1);
			if(have_effect($effect[Song of Fortune]) == 0)
			{
				buffMaintain($effect[Song of Accompaniment], 10, 1, 1);
			}
		}
		else if((place.turns_spent > 1) && (place != get_property("auto_priorLocation").to_location()))
		{
			//When do we consider Song of Cockiness?
			buffMaintain($effect[Song of Fortune], 10, 1, 1);
			if(have_effect($effect[Song of Fortune]) == 0)
			{
				buffMaintain($effect[Song of Accompaniment], 10, 1, 1);
			}
		}
	}

	if (isActuallyEd())
	{
		// make sure we have enough MP to cast our most expensive spells
		// Wrath of Ra (yellow ray) is 40 MP, Curse of Stench (sniff) is 35 MP & Curse of Vacation (banish) is 30 MP.
		acquireMP(40, 1000);
		// ensure we can cast at least Fist of the Mummy or Storm of the Scarab.
		// so we don't waste adventures when we can't actually kill a monster.
		acquireMP(8, 0);

		if (my_hp() == 0)
		{
			// the game doesn't let you adventure if you have no HP even though Ed
			// gets a full heal when he goes to the underworld
			// only necessary if a non-combat puts you on 0 HP.
			acquireHP(1);
		}
	}

	if(in_tcrs())
	{
		if(my_class() == $class[Sauceror] && my_sign() == "Blender")
		{
			if (0 == have_effect($effect[Uncucumbered]))
			{
				buyUpTo(1, $item[hair spray]);
				use(1, $item[hair spray]);
			}
			if (0 == have_effect($effect[Minerva\'s Zen]))
			{
				buyUpTo(1, $item[glittery mascara]);
				use(1, $item[glittery mascara]);
			}
		}
	}

	if(!get_property("kingLiberated").to_boolean())
	{
		if(($locations[Barrrney\'s Barrr, The Black Forest, The F\'c\'le, Monorail Work Site] contains place))
		{
			acquireCombatMods(zone_combatMod(place)._int, true);
		}
		if(place == $location[Sonofa Beach] && !auto_voteMonster())
		{
			acquireCombatMods(zone_combatMod(place)._int, true);
		}

		if($locations[Whitey\'s Grove] contains place)
		{
			acquireCombatMods(zone_combatMod(place)._int, true);
		}

		if($locations[A Maze of Sewer Tunnels, The Castle in the Clouds in the Sky (Basement), The Castle in the Clouds in the Sky (Ground Floor), The Castle in the Clouds in the Sky (Top Floor), The Dark Elbow of the Woods, The Dark Heart of the Woods, The Dark Neck of the Woods, The Defiled Alcove, The Defiled Cranny, The Extreme Slope, The Haunted Ballroom, The Haunted Bathroom, The Haunted Billiards Room, The Haunted Gallery, The Hidden Hospital, The Hidden Park, The Ice Hotel, Inside the Palindome, The Obligatory Pirate\'s Cove, The Penultimate Fantasy Airship, The Poop Deck, The Spooky Forest, Super Villain\'s Lair, Twin Peak, The Upper Chamber, Wartime Hippy Camp, Wartime Hippy Camp (Frat Disguise)] contains place)
		{
			acquireCombatMods(zone_combatMod(place)._int, true);
		}
	}
	else
	{
		if((get_property("questL11Spare") == "finished") && (place == $location[The Hidden Bowling Alley]) && (item_amount($item[Bowling Ball]) > 0))
		{
			put_closet(item_amount($item[Bowling Ball]), $item[Bowling Ball]);
		}
	}

	if(monster_level_adjustment() > 120)
	{
		acquireHP(80.0);
	}

	if(in_hardcore() && (my_class() == $class[Sauceror]) && (my_mp() < 32) && (my_maxmp() >= 32))
	{
		acquireMP(32, 2500);
	}

	foreach i,mon in get_monsters(place)
	{
		if(auto_wantToYellowRay(mon, place))
		{
			adjustForYellowRayIfPossible(mon);
		}

		if(auto_wantToBanish(mon, place))
		{
			adjustForBanishIfPossible(mon, place);
		}
	}

	// Latte may conflict with certain quests. Ignore latte drops for the greater good.
	boolean[location] IgnoreLatteDrop = $locations[The Haunted Boiler Room];
	if((auto_latteDropWanted(place)) && (!(IgnoreLatteDrop contains place)))
	{
		auto_log_info('We want to get the "' + auto_latteDropName(place) + '" ingredient for our latte from ' + place + ", so we're bringing it along.", "blue");
		autoEquip($item[latte lovers member\'s mug]);
	}

	equipOverrides();

	if((place == $location[8-Bit Realm]) && (my_turncount() != 0))
	{
		if(!possessEquipment($item[Continuum Transfunctioner]))
		{
			abort("Tried to be retro but lacking the Continuum Transfunctioner.");
		}
		autoEquip($slot[acc3], $item[Continuum Transfunctioner]);
	}

	if((place == $location[Inside The Palindome]) && (my_turncount() != 0))
	{
		if(!possessEquipment($item[Talisman O\' Namsilat]))
		{
			abort("Tried to go to The Palindome but don't have the Namsilat");
		}
		autoEquip($slot[acc3], $item[Talisman O\' Namsilat]);
	}

	if((place == $location[The Haunted Boiler Room]) && (my_turncount() != 0) && (get_property("auto_winebomb") == "partial"))
	{
		if(!possessEquipment($item[Unstable Fulminate]))
		{
			abort("Tried to charge a WineBomb but don't have one.");
		}
		autoEquip($slot[off-hand], $item[Unstable Fulminate]);
	}

	if(place == $location[The Black Forest])
	{
		autoEquip($slot[acc3], $item[Blackberry Galoshes]);
	}

	bat_formPreAdventure();
	horsePreAdventure();

	generic_t itemNeed = zone_needItem(place);
	if(itemNeed._boolean)
	{
		float itemDrop;
		if(useMaximizeToEquip())
		{
			addToMaximize("50item " + ceil(itemNeed._float) + "max");
			simMaximize();
			itemDrop = simValue("Item Drop");
		}
		else
		{
			itemDrop = numeric_modifier("Item Drop");
		}
		if(itemDrop < itemNeed._float)
		{
			if (buffMaintain($effect[Fat Leon\'s Phat Loot Lyric], 20, 1, 10))
			{
				itemDrop += 20.0;
			}
			if (buffMaintain($effect[Singer\'s Faithful Ocelot], 35, 1, 10))
			{
				itemDrop += 10.0;
			}
		}
		if(itemDrop < itemNeed._float && !haveAsdonBuff())
		{
			asdonAutoFeed(37);
			if(asdonBuff($effect[Driving Observantly]))
			{
				itemDrop += 50.0;
			}
		}
		if(itemDrop < itemNeed._float)
		{
			auto_log_debug("We can't cap this drop bear!", "purple");
		}
	}


	// Only cast Paul's pop song if we expect it to more than pay for its own casting.
	//	Casting before ML variation ensures that this, the more important buff, is cast before ML.
	if(auto_predictAccordionTurns() >= 8)
	{
		buffMaintain($effect[Paul\'s Passionate Pop Song], 0, 1, 1);
	}

	// ML adjustment zone section
	boolean doML = true;
	boolean removeML = false;
		// removeML MUST be true for purgeML to be used. This is only used for -ML locations like Smut Orc, and you must have 5+ SGEAs to use.
		boolean purgeML = false;

	boolean[location] highMLZones = $locations[Oil Peak, The Typical Tavern Cellar, The Haunted Boiler Room, The Defiled Cranny];
	boolean[location] lowMLZones = $locations[The Smut Orc Logging Camp];

	// Generic Conditions
	if(get_property("kingLiberated").to_boolean())
	{
		doML = false;
		removeML=false;
		purgeML=false;
	}

		// NOTE: If we aren't quits before we pass L13, let us gain stats.
	if(((get_property("flyeredML").to_int() > 9999) || get_property("auto_hippyInstead").to_boolean() || (get_property("auto_war") == "finished") || (get_property("sidequestArenaCompleted") != "none")) && ((my_level() == 13)))
	{
		doML = false;
		removeML = true;
		purgeML=false;
	}

	// Allow user settable option to override the above settings to not slack off ML
	if (get_property("auto_disregardInstantKarma").to_boolean())
	{
		doML = true;
		removeML = false;
		purgeML=false;
	}

	// Item specific Conditions
	if((equipped_amount($item[Space Trip Safety Headphones]) > 0) || (equipped_amount($item[Red Badge]) > 0))
	{
		doML = false;
		removeML = true;
		purgeML=false;
	}

	// Location Specific Conditions
	if(lowMLZones contains place)
	{
		doML = false;
		removeML = true;
		purgeML = true;
	}
	if(highMLZones contains place)
	{
		doML = true;
		removeML = false;
		purgeML=false;
	}

	// Act on ML settings
	if(doML)
	{
		// Catch when we leave lowMLZone, allow for being "side tracked" by delay burning
		if((have_effect($effect[Driving Intimidatingly]) > 0) && (get_property("auto_debuffAsdonDelay") >= 2))
		{
			auto_log_debug("No Reason to delay Asdon Usage");
			uneffect($effect[Driving Intimidatingly]);
			set_property("auto_debuffAsdonDelay", 0);
		}
		else if((have_effect($effect[Driving Intimidatingly]).to_int() == 0)  && (get_property("auto_debuffAsdonDelay") >= 0))
		{
			set_property("auto_debuffAsdonDelay", 0);
		}
		else
		{
			set_property("auto_debuffAsdonDelay", get_property("auto_debuffAsdonDelay").to_int() + 1);
			auto_log_debug("Delaying debuffing Asdon: " + get_property("auto_debuffAsdonDelay"));
		}

		auto_MaxMLToCap(auto_convertDesiredML(150), false);
	}

	// If we are in some state where we do not want +ML (Level 13 or Smut Orc) make sure ML is removed
	if(removeML)
	{
		auto_change_mcd(0);

		uneffect($effect[Driving Recklessly]);
		uneffect($effect[Ur-Kel\'s Aria of Annoyance]);

		if((purgeML) && item_amount($item[soft green echo eyedrop antidote]) > 5)
		{
			uneffect($effect[Drescher\'s Annoying Noise]);
			uneffect($effect[Pride of the Puffin]);
			uneffect($effect[Ceaseless Snarling]);
		}
	}

	// Here we enforce our ML restrictions if +/-ML is not specifically called in the current maximizer string
	enforceMLInPreAdv();

// EQUIP MAXIMIZED GEAR
	equipMaximizedGear();
	if(useMaximizeToEquip())
	{
		cli_execute("checkpoint clear");
	}

	// Last minute debug logging and a final MCD tweak just in case Maximizer did silly stuff
	if(lowMLZones contains place)
	{
		auto_log_debug("Going into a LOW ML ZONE with ML: " + monster_level_adjustment());
	}
	else
	{
		// Last minute MCD alterations if Limit set, otherwise trust maximizer
		if(get_property("auto_MLSafetyLimit") != "")
		{
			auto_change_mcd(0);
			auto_setMCDToCap();
		}

		auto_log_debug("Going into High or Standard ML Zone with ML: " + monster_level_adjustment());
	}	

	executeFlavour();

	// After maximizing equipment, we might not be at full HP
	if ($locations[Tower Level 1, The Invader] contains place)
	{
		useCocoon();
	}

	int wasted_mp = my_mp() + mp_regen() - my_maxmp();
	if(wasted_mp > 0 && my_mp() > 400)
	{
		auto_log_info("Burning " + wasted_mp + " MP...");
		cli_execute("burn " + wasted_mp);
	}

	if(in_hardcore() && (my_class() == $class[Sauceror]) && (my_mp() < 32))
	{
		auto_log_warning("We don't have a lot of MP but we are chugging along anyway", "red");
	}
	groundhogAbort(place);
	if(my_inebriety() > inebriety_limit()) abort("You are overdrunk. Stop it.");
	set_property("auto_priorLocation", place);
	auto_log_info("Pre Adventure at " + place + " done, beep.", "blue");
}

void main()
{
	handlePreAdventure();
}
