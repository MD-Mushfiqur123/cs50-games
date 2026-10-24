using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

/// <summary>
/// CS50 Games - Assignment 9: Dreadhalls
/// DungeonGenerator: Procedural random maze generator (DFS Backtracking / Prim's)
/// Spawns floor tiles, walls, atmospheric lighting, and key exit door.
/// </summary>
public class DungeonGenerator : MonoBehaviour
{
    public int width = 15;
    public int height = 15;
    public float cellSize = 4f;

    [Header("Prefabs")]
    public GameObject floorPrefab;
    public GameObject wallPrefab;
    public GameObject ceilingPrefab;
    public GameObject torchLightPrefab;
    public GameObject exitDoorPrefab;
    public Transform playerTransform;

    private int[,] grid; // 0: Empty/Path, 1: Wall

    void Start()
    {
        GenerateMaze();
        BuildDungeonGeometry();
    }

    void GenerateMaze()
    {
        grid = new int[width, height];

        // Initialize with solid walls
        for (int x = 0; x < width; x++)
        {
            for (int y = 0; y < height; y++)
            {
                grid[x, y] = 1;
            }
        }

        // DFS Backtracker maze carving
        Stack<Vector2Int> stack = new Stack<Vector2Int>();
        Vector2Int start = new Vector2Int(1, 1);
        grid[start.x, start.y] = 0;
        stack.Push(start);

        Vector2Int[] directions = {
            new Vector2Int(0, 2),
            new Vector2Int(0, -2),
            new Vector2Int(2, 0),
            new Vector2Int(-2, 0)
        };

        while (stack.Count > 0)
        {
            Vector2Int current = stack.Peek();
            List<Vector2Int> neighbors = new List<Vector2Int>();

            foreach (var dir in directions)
            {
                Vector2Int next = current + dir;
                if (next.x > 0 && next.x < width - 1 && next.y > 0 && next.y < height - 1)
                {
                    if (grid[next.x, next.y] == 1)
                    {
                        neighbors.Add(dir);
                    }
                }
            }

            if (neighbors.Count > 0)
            {
                Vector2Int chosenDir = neighbors[Random.Range(0, neighbors.Count)];
                Vector2Int wallBetween = current + chosenDir / 2;
                Vector2Int targetCell = current + chosenDir;

                grid[wallBetween.x, wallBetween.y] = 0;
                grid[targetCell.x, targetCell.y] = 0;

                stack.Push(targetCell);
            }
            else
            {
                stack.Pop();
            }
        }
    }

    void BuildDungeonGeometry()
    {
        for (int x = 0; x < width; x++)
        {
            for (int z = 0; z < height; z++)
            {
                Vector3 pos = new Vector3(x * cellSize, 0, z * cellSize);

                // Floor & Ceiling
                if (floorPrefab != null)
                    Instantiate(floorPrefab, pos, Quaternion.identity, transform);
                if (ceilingPrefab != null)
                    Instantiate(ceilingPrefab, pos + Vector3.up * 3.5f, Quaternion.identity, transform);

                if (grid[x, z] == 1)
                {
                    // Wall
                    if (wallPrefab != null)
                        Instantiate(wallPrefab, pos + Vector3.up * 1.75f, Quaternion.identity, transform);
                }
                else
                {
                    // Occasional flickering atmospheric torch light
                    if (Random.value < 0.08f && torchLightPrefab != null)
                    {
                        Instantiate(torchLightPrefab, pos + Vector3.up * 2.2f, Quaternion.identity, transform);
                    }
                }
            }
        }

        // Position player at entrance (1, 1)
        if (playerTransform != null)
        {
            playerTransform.position = new Vector3(1 * cellSize, 1f, 1 * cellSize);
        }

        // Spawn exit door at far corner
        if (exitDoorPrefab != null)
        {
            Vector3 exitPos = new Vector3((width - 2) * cellSize, 1f, (height - 2) * cellSize);
            Instantiate(exitDoorPrefab, exitPos, Quaternion.identity);
        }
    }
}
