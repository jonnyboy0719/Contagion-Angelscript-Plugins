#include "perks/godmode.as"
#include "perks/lowgravity.as"
#include "perks/stronggravity.as"
#include "perks/drugged.as"
#include "perks/sacrifice.as"
#include "perks/mommyplease.as"
#include "perks/unlimited_ammo.as"
#include "perks/unlimited_stamina.as"
#include "perks/godbless.as"
#include "perks/explode.as"
#include "perks/turtles.as"
#include "perks/voices.as"
#include "perks/headshotonly.as"
#include "perks/unluckyspawn.as"
#include "perks/armor.as"
#include "perks/grapple.as"
#include "perks/blind.as"
#include "perks/lowhealth.as"
#include "perks/toyman.as"
#include "perks/reversegravity.as"
#include "perks/russianroulette.as"
#include "perks/doubledamage.as"
#include "perks/quaddamage.as"
#include "perks/emptymagazine.as"
#include "perks/rocket.as"
#include "perks/panic.as"

namespace RTD
{
	void RegisterPerks()
	{
		CPerkGodMode();
		CPerkLowGravity();
		CPerkStrongGravity();
		CPerkDrugged();
		CPerkSacrifice();
		CPerkMommyPlease();
		CPerkUnlimitedAmmo();
		CPerkUnlimitedStamina();
		CPerkGodBless();
		CPerkExplode();
		CPerkTurtles();
		CPerkVoices();
		CPerkHeadshotExpert();
		CPerkUnluckySpawn();
		CPerkArmor();
		CPerkGrapple();
		CPerkBlind();
		CPerkLowHP();
		CPerkToyMan();
		CPerkReverseGravity();
		CPerkRussianRoulette();
		CPerkDoubleDamage();
		CPerkQuadDamage();
		CPerkEmptyMagazine();
		CPerkRocket();
		CPerkPanic();
	}
}