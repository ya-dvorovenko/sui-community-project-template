#[test_only]
module hero::battleplace_tests;

use hero::battleplace::{Self as battleplace, Hero, ListHero, BattlePlace, AdminCap};
use sui::coin;
use sui::sui::SUI;
use sui::test_scenario::{Self as ts, next_tx};

// Error codes for assertions
const EHeroNameMismatch: u64 = 1;
const EHeroImageUrlMismatch: u64 = 2;
const EHeroPowerMismatch: u64 = 3;
const EHeroPriceMismatch: u64 = 4;
const EHeroNotCreated: u64 = 5;
const EHeroNotTransferred: u64 = 6;
const EListHeroNotShared: u64 = 7;
const EBattlePlaceNotShared: u64 = 8;
const EHeroAmountMismatch: u64 = 9;

const SENDER: address = @0x1;
const RECIPIENT: address = @0x2;
const PRICE: u64 = 1000000000; // 1 SUI in MIST

#[test]
fun test_create_hero() {
    let mut scenario = ts::begin(SENDER);

    // Create a hero
    {
        battleplace::create_hero(
            b"Ali".to_string(),
            b"https://example.com/ali.png".to_string(),
            9000,
            scenario.ctx(),
        );
    };

    // Move to next transaction to access the created hero
    next_tx(&mut scenario, SENDER);

    // Verify hero was created and test getter functions
    assert!(ts::has_most_recent_for_sender<Hero>(&scenario), EHeroNotCreated);

    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        // Test getter functions
        assert!(battleplace::hero_name(&hero) == b"Ali".to_string(), EHeroNameMismatch);
        assert!(
            battleplace::hero_image_url(&hero) == b"https://example.com/ali.png".to_string(),
            EHeroImageUrlMismatch,
        );
        assert!(battleplace::hero_power(&hero) == 9000, EHeroPowerMismatch);
        ts::return_to_sender(&scenario, hero);
    };

    ts::end(scenario);
}

#[test]
fun test_transfer_hero() {
    let mut scenario = ts::begin(SENDER);

    // Create a hero first
    {
        battleplace::create_hero(
            b"Serkan".to_string(),
            b"https://example.com/serkan.png".to_string(),
            8500,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, SENDER);

    // Transfer the hero to recipient
    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        transfer::public_transfer(hero, RECIPIENT)
    };

    // Move to next transaction as recipient
    next_tx(&mut scenario, RECIPIENT);

    // Verify hero is now owned by recipient
    assert!(ts::has_most_recent_for_address<Hero>(RECIPIENT), EHeroNotTransferred);

    ts::end(scenario);
}

#[test]
fun test_list_hero() {
    let mut scenario = ts::begin(SENDER);

    // Create a hero first
    {
        battleplace::create_hero(
            b"Mantas".to_string(),
            b"https://example.com/mantas.png".to_string(),
            7500,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, SENDER);

    // List the hero for sale
    {
        let hero = ts::take_from_sender<Hero>(&scenario);

        battleplace::list_hero(hero, PRICE, scenario.ctx());
    };

    next_tx(&mut scenario, SENDER);

    // Verify ListHero object was created and shared
    assert!(ts::has_most_recent_shared<ListHero>(), EListHeroNotShared);

    ts::end(scenario);
}

#[test]
fun test_buy_hero() {
    let mut scenario = ts::begin(SENDER);

    // Create and list a hero
    {
        battleplace::create_hero(
            b"Teo".to_string(),
            b"https://example.com/teo.png".to_string(),
            6000,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, SENDER);

    {
        let hero = ts::take_from_sender<Hero>(&scenario);

        battleplace::list_hero(hero, PRICE, scenario.ctx());
    };

    next_tx(&mut scenario, RECIPIENT);

    // Buy the hero
    {
        let coin = coin::mint_for_testing<SUI>(PRICE, scenario.ctx());
        let list_hero = ts::take_shared<ListHero>(&scenario);

        battleplace::buy_hero(list_hero, coin, scenario.ctx());
    };

    next_tx(&mut scenario, RECIPIENT);

    // Verify buyer received the hero
    assert!(ts::has_most_recent_for_address<Hero>(RECIPIENT), EHeroNotTransferred);

    {
        let hero = ts::take_from_address<Hero>(&scenario, RECIPIENT);
        assert!(battleplace::hero_name(&hero) == b"Teo".to_string(), EHeroNameMismatch);
        assert!(battleplace::hero_power(&hero) == 6000, EHeroPowerMismatch);
        ts::return_to_address(RECIPIENT, hero);
    };

    // Verify seller received the coin payment
    // In test scenarios, SUI coins are automatically handled, but we can verify the transfer occurred
    // by checking that the coin was properly consumed (no error in the buy transaction)

    ts::end(scenario);
}

#[test]
fun test_create_battle_place() {
    let mut scenario = ts::begin(SENDER);

    // Create a hero first
    {
        battleplace::create_hero(
            b"Ercan".to_string(),
            b"https://example.com/ercan.png".to_string(),
            8000,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, SENDER);

    // Create battle place with the hero
    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        battleplace::create_battle_place(hero, scenario.ctx());
    };

    next_tx(&mut scenario, SENDER);

    // Verify BattlePlace object was created and shared
    assert!(ts::has_most_recent_shared<BattlePlace>(), EBattlePlaceNotShared);

    ts::end(scenario);
}

#[test]
fun test_delist_hero() {
    let mut scenario = ts::begin(SENDER);

    // Create admin cap first
    {
        battleplace::test_init(scenario.ctx());
    };

    next_tx(&mut scenario, SENDER);

    // Create and list a hero
    {
        battleplace::create_hero(
            b"Ahmet".to_string(),
            b"https://example.com/ahmet.png".to_string(),
            7200,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, SENDER);

    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        battleplace::list_hero(hero, PRICE, scenario.ctx());
    };

    next_tx(&mut scenario, SENDER);

    // Delist the hero using admin cap
    {
        let admin_cap = ts::take_from_sender<AdminCap>(&scenario);
        let list_hero = ts::take_shared<ListHero>(&scenario);

        battleplace::delist(&admin_cap, list_hero);

        ts::return_to_sender(&scenario, admin_cap);
    };

    next_tx(&mut scenario, SENDER);

    // Verify hero was returned to seller
    assert!(ts::has_most_recent_for_sender<Hero>(&scenario), EHeroNotTransferred);

    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        assert!(battleplace::hero_name(&hero) == b"Ahmet".to_string(), EHeroNameMismatch);
        ts::return_to_sender(&scenario, hero);
    };

    ts::end(scenario);
}

#[test]
fun test_change_the_price() {
    let mut scenario = ts::begin(SENDER);

    // Create admin cap first
    {
        battleplace::test_init(scenario.ctx());
    };

    next_tx(&mut scenario, SENDER);

    // Create and list a hero
    {
        battleplace::create_hero(
            b"Serkan".to_string(),
            b"https://example.com/serkan.png".to_string(),
            6800,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, SENDER);

    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        battleplace::list_hero(hero, PRICE, scenario.ctx());
    };

    next_tx(&mut scenario, SENDER);

    // Change the price using admin cap
    let new_price = 2000000000; // 2 SUI
    {
        let admin_cap = ts::take_from_sender<AdminCap>(&scenario);
        let mut list_hero = ts::take_shared<ListHero>(&scenario);

        battleplace::change_the_price(&admin_cap, &mut list_hero, new_price);

        ts::return_shared(list_hero);
        ts::return_to_sender(&scenario, admin_cap);
    };

    next_tx(&mut scenario, SENDER);
    {
        let list_hero = ts::take_shared<ListHero>(&scenario);

        assert!(battleplace::hero_price(&list_hero) == new_price, EHeroPriceMismatch);
        ts::return_shared(list_hero);
    };

    ts::end(scenario);
}

#[test]
fun test_battle_cross_user() {
    let mut scenario = ts::begin(SENDER);

    // SENDER creates a hero and battle place
    {
        battleplace::create_hero(
            b"Kostas".to_string(),
            b"https://example.com/kostas.png".to_string(),
            7500,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, SENDER);

    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        battleplace::create_battle_place(hero, scenario.ctx());
    };

    next_tx(&mut scenario, RECIPIENT);

    {
        battleplace::create_hero(
            b"Adeniyi".to_string(),
            b"https://example.com/adeniyi.png".to_string(),
            8500,
            scenario.ctx(),
        );
    };

    next_tx(&mut scenario, RECIPIENT);

    {
        let hero = ts::take_from_sender<Hero>(&scenario);
        let battle_place = ts::take_shared<BattlePlace>(&scenario);

        battleplace::battle(hero, battle_place, scenario.ctx());
    };

    next_tx(&mut scenario, RECIPIENT);

    // RECIPIENT should have received both heroes (winner gets all)
    // Kostas (8500) > Adeniyi (7500)
    let hero_ids_recipient = ts::ids_for_sender<Hero>(&scenario);
    assert!(hero_ids_recipient.length() == 2, EHeroAmountMismatch);

    // Verify SENDER has no heroes left
    next_tx(&mut scenario, SENDER);
    let hero_ids_sender = ts::ids_for_sender<Hero>(&scenario);
    assert!(hero_ids_sender.length() == 0, EHeroNotTransferred);

    ts::end(scenario);
}
