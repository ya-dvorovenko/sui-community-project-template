module challenge_1::arena;

use challenge_1::hero::Hero;
use std::string::String;
use sui::coin::{Self, Coin};
use sui::event;
use sui::sui::SUI;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner: ID,
    loser: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {}

