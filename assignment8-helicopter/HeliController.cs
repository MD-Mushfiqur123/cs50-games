using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

/// <summary>
/// CS50 Games - Assignment 8: Helicopter Game 3D
/// HeliController: Handles 3D helicopter physics, altitude lift, forward velocity,
/// coin collection, gem pickups, and crash collision detection.
/// </summary>
[RequireComponent(typeof(Rigidbody))]
public class HeliController : MonoBehaviour
{
    [Header("Helicopter Physics")]
    public float liftForce = 1200f;
    public float forwardSpeed = 25f;
    public float maxTiltAngle = 35f;

    [Header("Rotor Components")]
    public Transform mainRotor;
    public Transform tailRotor;
    public float rotorSpinSpeed = 1500f;

    [Header("Audio & Effects")]
    public AudioSource engineAudio;
    public AudioSource pickupAudio;
    public ParticleSystem explosionParticles;

    [Header("UI Reference")]
    public Text scoreText;
    public Text distanceText;
    public GameObject gameOverPanel;

    private Rigidbody rb;
    private int score = 0;
    private float distanceTraveled = 0f;
    private bool isGameOver = false;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        rb.freezeRotation = true; // Prevent uncontrolled tumbling
    }

    void Start()
    {
        if (gameOverPanel != null)
            gameOverPanel.SetActive(false);
        UpdateUI();
    }

    void Update()
    {
        if (isGameOver)
        {
            if (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.R))
            {
                SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
            }
            return;
        }

        // Spin rotors
        if (mainRotor != null)
            mainRotor.Rotate(Vector3.up, rotorSpinSpeed * Time.deltaTime);
        if (tailRotor != null)
            tailRotor.Rotate(Vector3.right, rotorSpinSpeed * Time.deltaTime);

        // Distance tracker
        distanceTraveled += forwardSpeed * Time.deltaTime;
        UpdateUI();
    }

    void FixedUpdate()
    {
        if (isGameOver) return;

        // Constant forward velocity
        Vector3 vel = rb.velocity;
        vel.z = forwardSpeed;

        // Lift control: Spacebar / Left Click applies upward propulsion
        if (Input.GetKey(KeyCode.Space) || Input.GetMouseButton(0) || Input.GetKey(KeyCode.UpArrow) || Input.GetKey(KeyCode.W))
        {
            rb.AddForce(Vector3.up * liftForce * Time.fixedDeltaTime, ForceMode.Acceleration);
        }

        rb.velocity = vel;

        // Dynamic visual tilt pitch
        float pitchAngle = Mathf.Clamp(-rb.velocity.y * 1.5f, -maxTiltAngle, maxTiltAngle);
        transform.rotation = Quaternion.Euler(pitchAngle, 0, 0);
    }

    void OnTriggerEnter(Collider other)
    {
        if (isGameOver) return;

        // CS50 Requirement: Coin pickup (+100 pts) and Gem pickup (+500 pts)
        if (other.CompareTag("Coin"))
        {
            score += 100;
            if (pickupAudio != null) pickupAudio.Play();
            Destroy(other.gameObject);
            UpdateUI();
        }
        else if (other.CompareTag("Gem"))
        {
            score += 500;
            if (pickupAudio != null) pickupAudio.Play();
            Destroy(other.gameObject);
            UpdateUI();
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (isGameOver) return;

        // Colliding with building obstacles, ceiling, or ground results in crash
        if (collision.gameObject.CompareTag("Obstacle") || collision.gameObject.CompareTag("Terrain"))
        {
            TriggerCrash();
        }
    }

    void TriggerCrash()
    {
        isGameOver = true;
        if (engineAudio != null) engineAudio.Stop();
        if (explosionParticles != null) explosionParticles.Play();
        if (gameOverPanel != null) gameOverPanel.SetActive(true);

        rb.velocity = Vector3.zero;
        rb.isKinematic = true;
    }

    void UpdateUI()
    {
        if (scoreText != null)
            scoreText.text = "Score: " + score;
        if (distanceText != null)
            distanceText.text = "Distance: " + Mathf.FloorToInt(distanceTraveled) + "m";
    }
}
