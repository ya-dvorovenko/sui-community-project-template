import { Transaction } from "@mysten/sui/transactions";

export const createBattlePlace = (packageId: string, heroId: string) => {
  const tx = new Transaction();
  
  // TODO: Add moveCall to create a battle place
  // Function: `${packageId}::battleplace::create_battle_place`
  // Arguments: heroId (object)
  // Hints:
  // - Use tx.object() for the hero object
  // - This creates a shared object that others can battle against
  
  return tx;
};
