using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// CS50 Games - Assignment 9: Dreadhalls
/// FlashlightController: First-person camera flashlight with battery drain,
/// flickering simulation, and recharge mechanics.
/// </summary>
public class FlashlightController : MonoBehaviour
{
    public Light flashlight;
    public float maxBattery = 100f;
    public float batteryDrainRate = 2.5f;
    public float flickerChance = 0.05f;

    private float currentBattery;
    private bool isOn = true;

    void Start()
    {
        currentBattery = maxBattery;
        if (flashlight == null)
            flashlight = GetComponent<Light>();
    }

    void Update()
    {
        // Toggle Flashlight
        if (Input.GetKeyDown(KeyCode.F))
        {
            isOn = !isOn;
            flashlight.enabled = isOn;
        }

        if (isOn && currentBattery > 0)
        {
            currentBattery -= batteryDrainRate * Time.deltaTime;

            // Low battery flickering
            if (currentBattery < 25f && Random.value < flickerChance)
            {
                flashlight.intensity = Random.Range(0.2f, 1.5f);
            }
            else
            {
                flashlight.intensity = Mathf.Lerp(0.5f, 2.0f, currentBattery / maxBattery);
            }

            if (currentBattery <= 0)
            {
                currentBattery = 0;
                flashlight.enabled = false;
            }
        }
    }

    public void Recharge(float amount)
    {
        currentBattery = Mathf.Min(maxBattery, currentBattery + amount);
        if (isOn) flashlight.enabled = true;
    }
}
