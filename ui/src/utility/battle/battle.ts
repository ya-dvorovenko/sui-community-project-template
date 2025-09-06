import { Transaction } from "@mysten/sui/transactions";

export const battle = (packageId: string, heroId: string, battlePlaceId: string) => {
  const tx = new Transaction();
  
  // TODO: Add moveCall to start a battle
  // Function: `${packageId}::battleplace::battle`
  // Arguments: heroId (object), battlePlaceId (object)
  // Hints:
  // - Use tx.object() for both hero and battle place objects
  // - The battle winner is determined by hero power comparison
  // - Winner takes both heroes
  
  return tx;
};
