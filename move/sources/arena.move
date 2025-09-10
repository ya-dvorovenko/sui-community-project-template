module challenge::arena;

use challenge::hero::Hero;
use sui::event;

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

public fun create_arena(hero: Hero, ctx: &mut TxContext) {
    // TODO: Create a Arena struct
    // Hints:
    // - Use object::new(ctx) for unique ID
    // - Set warrior field to the hero parameter
    // - Set owner to ctx.sender()
    // - Emit ArenaCreated event with ID and timestamp
    // - Use transfer::share_object() to make it publicly accessible
}

#[allow(lint(self_transfer))]
public fun battle(hero: Hero, arena: Arena, ctx: &mut TxContext) {
    // TODO: Implement battle logic
    // Hints:
    // - Destructure arena to get id, warrior, and owner
    // - Compare hero.power with warrior.power
    // - If hero wins: both heroes go to ctx.sender()
    // - If warrior wins: both heroes go to battle place owner
    // - Emit BattlePlaceCompleted event with winner/loser IDs (Don't forget to use object::to_inner(winner.id) or object::to_inner(loser.id) )
    // - Don't forget to delete the battle place ID at the end
}

