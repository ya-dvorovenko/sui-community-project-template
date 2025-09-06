module hero::battleplace;

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

public struct BattlePlace has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

public struct ListHero has key, store {
    id: UID,
    nft: Hero,
    price: u64,
    seller: address,
}

public struct HeroMetadata has key, store {
    id: UID,
    timestamp: u64,
}

// ========= CAPABILITIES =========

public struct AdminCap has key, store {
    id: UID,
}

// ========= EVENTS =========

public struct BattlePlaceCreated has copy, drop {
    id: ID,
    timestamp: u64,
}

public struct BattlePlaceCompleted has copy, drop {
    winner: ID,
    loser: ID,
    timestamp: u64,
}

public struct HeroListed has copy, drop {
    id: ID,
    price: u64,
    seller: address,
    timestamp: u64,
}

public struct HeroBought has copy, drop {
    id: ID,
    price: u64,
    buyer: address,
    seller: address,
    timestamp: u64,
}

// ========= FUNCTIONS =========

fun init(ctx: &mut TxContext) {
    // TODO: Initialize the module by creating AdminCap
    // Hints:
    // - Create AdminCap id with object::new(ctx)
    // - Transfer it to the module publisher (ctx.sender())
    // - This runs once when the module is published
}

#[allow(lint(self_transfer))]
public fun create_hero(name: String, image_url: String, power: u64, ctx: &mut TxContext) {
    // TODO: Create a new Hero struct with the given parameters
    // Hints:
    // - Use object::new(ctx) to create a unique ID
    // - Set name, image_url, and power fields
    // - Transfer the hero to the transaction sender
    // 
    // Also create HeroMetadata and freeze it for tracking
    // - Use ctx.epoch_timestamp_ms() for timestamp
    // - Use transfer::freeze_object() to make metadata immutable
}

public fun create_battle_place(hero: Hero, ctx: &mut TxContext) {
    // TODO: Create a BattlePlace struct
    // Hints:
    // - Use object::new(ctx) for unique ID
    // - Set warrior field to the hero parameter
    // - Set owner to ctx.sender()
    // - Emit BattlePlaceCreated event with ID and timestamp
    // - Use transfer::share_object() to make it publicly accessible
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, battle_place: BattlePlace, ctx: &mut TxContext) {
    // TODO: Implement battle logic
    // Hints:
    // - Destructure battle_place to get id, warrior, and owner
    // - Compare hero.power with warrior.power
    // - If hero wins: both heroes go to ctx.sender()
    // - If warrior wins: both heroes go to battle place owner
    // - Emit BattlePlaceCompleted event with winner/loser IDs (Don't forget to use object::to_inner(winner.id) or object::to_inner(loser.id) )
    // - Don't forget to delete the battle place ID at the end
}

public fun list_hero(nft: Hero, price: u64, ctx: &mut TxContext) {
    // TODO: Create a ListHero struct for marketplace
    // Hints:
    // - Use object::new(ctx) for unique ID
    // - Set nft, price, and seller (ctx.sender()) fields
    // - Emit HeroListed event with listing details
    // - Use transfer::share_object() to make it publicly tradeable
}

#[allow(lint(self_transfer))]
public fun buy_hero(list_hero: ListHero, coin: Coin<SUI>, ctx: &mut TxContext) {
    // TODO: Implement hero purchase logic
    // Hints:
    // - Destructure list_hero to get id, nft, price, and seller
    // - Use assert! to verify coin value equals listing price
    // - Transfer coin to seller
    // - Transfer hero NFT to buyer (ctx.sender())
    // - Emit HeroBought event with transaction details
    // - Delete the listing ID
}

// ========= ADMIN FUNCTIONS =========

public fun delist(list_hero: ListHero, _: &AdminCap) {
    // TODO: Implement admin delist functionality
    // Hints:
    // - Destructure list_hero (ignore price with _)
    // - Transfer NFT back to original seller
    // - Delete the listing ID
    // - The AdminCap parameter ensures only admin can call this
}

public fun change_the_price(list_hero: &mut ListHero, new_price: u64, _: &AdminCap) {
    // TODO: Update the listing price
    // Hints:
    // - Access the price field of list_hero and update it
    // - Use mutable reference (&mut) to modify the object
    // - The AdminCap parameter ensures only admin can call this
}

// ========= GETTER FUNCTIONS =========

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

#[test_only]
public fun hero_price(list_hero: &ListHero): u64 {
    list_hero.price
}

// ========= TEST ONLY FUNCTIONS =========

#[test_only]
public fun test_init(ctx: &mut TxContext) {
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    transfer::transfer(admin_cap, ctx.sender());
}
