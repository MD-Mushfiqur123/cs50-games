using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// CS50 Games - Assignment 8: Helicopter Game 3D
/// ObstacleSpawner: Spawns procedural skyscrapers, floating obstacles,
/// gold coins, and gems continuously ahead of the player helicopter.
/// </summary>
public class ObstacleSpawner : MonoBehaviour
{
    [Header("Prefabs")]
    public GameObject[] buildingPrefabs;
    public GameObject coinPrefab;
    public GameObject gemPrefab;

    [Header("Spawn Settings")]
    public Transform playerTransform;
    public float spawnDistanceAhead = 120f;
    public float spawnIntervalZ = 25f;
    public float minHeight = 5f;
    public float maxHeight = 25f;

    private float nextSpawnZ = 30f;
    private List<GameObject> activeObjects = new List<GameObject>();

    void Update()
    {
        if (playerTransform == null) return;

        // Check if we need to generate more chunks ahead
        if (playerTransform.position.z + spawnDistanceAhead > nextSpawnZ)
        {
            SpawnChunk(nextSpawnZ);
            nextSpawnZ += spawnIntervalZ;
        }

        // Clean up passed objects far behind player
        for (int i = activeObjects.Count - 1; i >= 0; i--)
        {
            if (activeObjects[i] == null)
            {
                activeObjects.RemoveAt(i);
            }
            else if (activeObjects[i].transform.position.z < playerTransform.position.z - 40f)
            {
                Destroy(activeObjects[i]);
                activeObjects.RemoveAt(i);
            }
        }
    }

    void SpawnChunk(float zPos)
    {
        // Randomize building gap & height
        float height = Random.Range(minHeight, maxHeight);
        float xPos = Random.Range(-12f, 12f);

        if (buildingPrefabs != null && buildingPrefabs.Length > 0)
        {
            GameObject prefab = buildingPrefabs[Random.Range(0, buildingPrefabs.Length)];
            GameObject building = Instantiate(prefab, new Vector3(xPos, height / 2f, zPos), Quaternion.identity);
            building.tag = "Obstacle";
            activeObjects.Add(building);
        }

        // Spawn Coin or Gem
        if (Random.value < 0.6f && coinPrefab != null)
        {
            float coinY = Random.Range(4f, 18f);
            float coinX = Random.Range(-8f, 8f);
            GameObject coin = Instantiate(coinPrefab, new Vector3(coinX, coinY, zPos + 10f), Quaternion.identity);
            coin.tag = "Coin";
            activeObjects.Add(coin);
        }
        else if (Random.value < 0.25f && gemPrefab != null)
        {
            // Rare high-value gem pickup
            float gemY = Random.Range(6f, 16f);
            float gemX = Random.Range(-6f, 6f);
            GameObject gem = Instantiate(gemPrefab, new Vector3(gemX, gemY, zPos + 12f), Quaternion.identity);
            gem.tag = "Gem";
            activeObjects.Add(gem);
        }
    }
}
