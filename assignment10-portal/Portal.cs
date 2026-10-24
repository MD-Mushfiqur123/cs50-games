using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// CS50 Games - Assignment 10: Portal
/// Portal: Teleports entering physics objects (player, cubes, balls)
/// to the linked portal with relative velocity & rotation transformation.
/// </summary>
public class Portal : MonoBehaviour
{
    public Portal linkedPortal;
    public Transform portalExitPoint;

    private List<Collider> trackedColliders = new List<Collider>();

    void OnTriggerEnter(Collider other)
    {
        if (linkedPortal == null || trackedColliders.Contains(other)) return;

        Rigidbody rb = other.GetComponent<Rigidbody>();
        if (rb != null)
        {
            TeleportObject(other, rb);
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (trackedColliders.Contains(other))
        {
            trackedColliders.Remove(other);
        }
    }

    void TeleportObject(Collider col, Rigidbody rb)
    {
        // Add to exit portal's tracking list to prevent instant infinite back-and-forth ping-pong
        linkedPortal.trackedColliders.Add(col);

        // Position transformation
        Vector3 relativePos = transform.InverseTransformPoint(col.transform.position);
        relativePos = Quaternion.Euler(0, 180, 0) * relativePos;
        col.transform.position = linkedPortal.transform.TransformPoint(relativePos);

        // Rotation transformation
        Quaternion relativeRot = Quaternion.Inverse(transform.rotation) * col.transform.rotation;
        relativeRot = Quaternion.Euler(0, 180, 0) * relativeRot;
        col.transform.rotation = linkedPortal.transform.rotation * relativeRot;

        // Velocity transformation (Conservation of momentum)
        Vector3 relativeVel = transform.InverseTransformDirection(rb.velocity);
        relativeVel = Quaternion.Euler(0, 180, 0) * relativeVel;
        rb.velocity = linkedPortal.transform.TransformDirection(relativeVel);
    }
}
