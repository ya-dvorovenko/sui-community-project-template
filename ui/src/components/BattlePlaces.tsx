import { useCurrentAccount, useSuiClientQuery, useSignAndExecuteTransaction, useSuiClient } from "@mysten/dapp-kit";
import { Flex, Heading, Text, Card, Grid, Button, Badge } from "@radix-ui/themes";
import { useState } from "react";
import { useNetworkVariable } from "../networkConfig";
import { Hero, BattlePlace } from "../types/hero";
import { battle } from "../utility/battle/battle";
import { RefreshProps } from "../types/props";

export default function BattlePlaces({ refreshKey, setRefreshKey }: RefreshProps) {
  const account = useCurrentAccount();
  const packageId = useNetworkVariable("packageId");
  const suiClient = useSuiClient();
  const [isBattling, setIsBattling] = useState<{ [key: string]: boolean }>({});
  const { mutate: signAndExecute } = useSignAndExecuteTransaction();

  // Get user's heroes for battle
  const { data: userHeroes } = useSuiClientQuery(
    "getOwnedObjects",
    {
      owner: account?.address as string,
      filter: {
        StructType: `${packageId}::battleplace::Hero`
      },
      options: {
        showContent: true,
        showType: true
      }
    },
    {
      enabled: !!account && !!packageId,
      queryKey: ["getOwnedObjects", "Heroes", account?.address, packageId, refreshKey],
    }
  );

  // Get BattlePlace created events to find active battle places
  const { data: battleEvents, isPending: eventsLoading } = useSuiClientQuery(
    "queryEvents",
    {
      query: {
        MoveEventType: `${packageId}::battleplace::BattlePlaceCreated`
      },
      limit: 50,
      order: "descending"
    },
    {
      enabled: !!packageId,
      queryKey: ["queryEvents", packageId, "BattlePlaceCreated", refreshKey],
    }
  );

  const { data, isPending, error } = useSuiClientQuery(
    "multiGetObjects",
    {
      ids: battleEvents?.data?.map(event => (event.parsedJson as any).id) || [],
      options: {
        showContent: true,
        showType: true
      }
    },
    {
      enabled: !!packageId && !!battleEvents?.data?.length,
      queryKey: ["multiGetObjects", "BattlePlaces", battleEvents?.data?.map(event => (event.parsedJson as any).id), refreshKey],
    }
  );

  const handleBattle = (battlePlaceId: string, heroId: string) => {
    if (!account || !packageId) return;
    
    setIsBattling(prev => ({ ...prev, [`${battlePlaceId}_${heroId}`]: true }));
    
    const tx = battle(packageId, heroId, battlePlaceId);
    signAndExecute(
      { transaction: tx },
      {
        onSuccess: async ({ digest }) => {
          await suiClient.waitForTransaction({
            digest,
            options: {
              showEffects: true,
              showObjectChanges: true,
            },
          });
          
          setRefreshKey(refreshKey + 1);
          setIsBattling(prev => ({ ...prev, [`${battlePlaceId}_${heroId}`]: false }));
        },
        onError: () => {
          setIsBattling(prev => ({ ...prev, [`${battlePlaceId}_${heroId}`]: false }));
        }
      }
    );
  };

  if (error) {
    return (
      <Card>
        <Text color="red">Error loading battle places: {error.message}</Text>
      </Card>
    );
  }

  if (eventsLoading || isPending) {
    return (
      <Card>
        <Text>Loading battle places...</Text>
      </Card>
    );
  }

  if (!battleEvents?.data?.length) {
    return (
      <Flex direction="column" gap="4">
        <Heading size="6">Battle Arena (0)</Heading>
        <Card>
          <Text>No battle places are currently available</Text>
        </Card>
      </Flex>
    );
  }

  const activeBattlePlaces = data?.filter(obj => obj.data?.content && 'fields' in obj.data.content) || [];
  const availableHeroes = userHeroes?.data?.filter(obj => obj.data?.content && 'fields' in obj.data.content) || [];

  return (
    <Flex direction="column" gap="4">
      <Heading size="6">Battle Arena ({activeBattlePlaces.length})</Heading>
      
      {!account && (
        <Card>
          <Text>Please connect your wallet to participate in battles</Text>
        </Card>
      )}
      
      {account && availableHeroes.length === 0 && (
        <Card>
          <Text color="orange">You need heroes to participate in battles. Create some heroes first!</Text>
        </Card>
      )}
      
      {activeBattlePlaces.length === 0 ? (
        <Card>
          <Text>No active battle places found</Text>
        </Card>
      ) : (
        <Grid columns="3" gap="4">
          {activeBattlePlaces.map((obj) => {
            const battlePlace = obj.data?.content as any;
            const battlePlaceId = obj.data?.objectId!;
            const fields = battlePlace.fields as BattlePlace;
            const warriorFields = fields.warrior.fields as Hero;

            return (
              <Card key={battlePlaceId} style={{ padding: "16px" }}>
                <Flex direction="column" gap="3">
                  {/* Warrior Image */}
                  <img 
                    src={warriorFields.image_url} 
                    alt={warriorFields.name}
                    style={{ 
                      width: "100%", 
                      height: "200px", 
                      objectFit: "cover", 
                      borderRadius: "8px",
                      border: "2px solid orange"
                    }}
                    onError={(e) => {
                      e.currentTarget.style.display = 'none';
                    }}
                  />
                  
                  {/* Battle Place Info */}
                  <Flex direction="column" gap="2">
                    <Flex align="center" gap="2">
                      <Text size="5" weight="bold">{warriorFields.name}</Text>
                      <Badge color="orange" size="2">⚔️ Battle Ready</Badge>
                    </Flex>
                    <Badge color="blue" size="2">Power: {warriorFields.power}</Badge>
                    
                    <Text size="3" color="gray">
                      Owner: {fields.owner.slice(0, 6)}...{fields.owner.slice(-4)}
                    </Text>
                  </Flex>

                  {/* Battle Options */}
                  {account && availableHeroes.length > 0 && (
                    <Flex direction="column" gap="2">
                      <Text size="2" weight="bold">Challenge with your hero:</Text>
                      {availableHeroes.slice(0, 3).map((heroObj) => {
                        const heroContent = heroObj.data?.content as any;
                        const heroId = heroObj.data?.objectId!;
                        const heroFields = heroContent.fields as Hero;
                        const battleKey = `${battlePlaceId}_${heroId}`;
                        const isMyBattlePlace = fields.owner === account.address;
                        
                        return (
                          <Flex key={heroId} align="center" gap="2">
                            <Text size="2" style={{ flex: 1 }}>
                              {heroFields.name} (Power: {heroFields.power})
                            </Text>
                            <Button 
                              onClick={() => handleBattle(battlePlaceId, heroId)}
                              disabled={isBattling[battleKey]}
                              loading={isBattling[battleKey]}
                              color={isMyBattlePlace ? "gray" : "orange"}
                              size="2"
                            >
                              {isBattling[battleKey]
                                  ? "Battling..."
                                  : "Battle!"
                              }
                            </Button>
                          </Flex>
                        );
                      })}
                    </Flex>
                  )}
                </Flex>
              </Card>
            );
          })}
        </Grid>
      )}
    </Flex>
  );
}
