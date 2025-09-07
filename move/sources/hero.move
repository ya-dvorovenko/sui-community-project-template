module challenge_1::hero;

use std::string::String;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

// ========= STRUCTS =========
public struct Hero has key, store {
    id: UID,
    name: String,
    image_url: String,
    power: u64,
}

public struct HeroMetadata has key, store {
    id: UID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

#[allow(lint(self_transfer))]
public fun create_hero(name: String, image_url: String, power: u64, ctx: &mut TxContext) {}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun hero_name(hero: &Hero): String {
    hero.name
}

#[test_only]
public fun hero_image_url(hero: &Hero): String {
    hero.image_url
}

#[test_only]
public fun hero_power(hero: &Hero): u64 {
    hero.power
}

#[test_only]
public fun hero_id(hero: &Hero): ID {
    object::id(hero)
}

