using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// CS50 Games - Assignment 10: Portal
/// PortalGun: Raycasts from camera center and fires Blue (Left-Click)
/// or Orange (Right-Click) portals onto valid portalable surfaces.
/// </summary>
public class PortalGun : MonoBehaviour
{
    [Header("Portal Prefabs")]
    public GameObject bluePortalPrefab;
    public GameObject orangePortalPrefab;

    [Header("Raycast Settings")]
    public Camera playerCamera;
    public LayerMask portalableLayer;
    public float maxRange = 100f;

    private Portal bluePortal;
    private Portal orangePortal;

    void Start()
    {
        if (playerCamera == null)
            playerCamera = Camera.main;
    }

    void Update()
    {
        // Left-Click: Blue Portal
        if (Input.GetMouseButtonDown(0))
        {
            FirePortal(true);
        }
        // Right-Click: Orange Portal
        else if (Input.GetMouseButtonDown(1))
        {
            FirePortal(false);
        }
    }

    void FirePortal(bool isBlue)
    {
        Ray ray = playerCamera.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0));
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, maxRange, portalableLayer))
        {
            Quaternion portalRotation = Quaternion.LookRotation(hit.normal);

            if (isBlue)
            {
                if (bluePortal == null)
                {
                    GameObject go = Instantiate(bluePortalPrefab, hit.point + hit.normal * 0.05f, portalRotation);
                    bluePortal = go.GetComponent<Portal>();
                }
                else
                {
                    bluePortal.transform.position = hit.point + hit.normal * 0.05f;
                    bluePortal.transform.rotation = portalRotation;
                }
            }
            else
            {
                if (orangePortal == null)
                {
                    GameObject go = Instantiate(orangePortalPrefab, hit.point + hit.normal * 0.05f, portalRotation);
                    orangePortal = go.GetComponent<Portal>();
                }
                else
                {
                    orangePortal.transform.position = hit.point + hit.normal * 0.05f;
                    orangePortal.transform.rotation = portalRotation;
                }
            }

            // Link portals together
            if (bluePortal != null && orangePortal != null)
            {
                bluePortal.linkedPortal = orangePortal;
                orangePortal.linkedPortal = bluePortal;
            }
        }
    }
}
