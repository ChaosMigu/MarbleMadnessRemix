using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Dreamteck;
using Dreamteck.Splines;

public class PlayerController : MonoBehaviour
{
    public Camera camera;
    public float moveSpeed = 10f;
    public float maxVelocity = 5f;
    private Rigidbody playerRigidbody;

    public SplineFollower splineFollower; public SplineComputer splinComputer;

    void Start()
    {
        playerRigidbody = GetComponent<Rigidbody>();
    }

    void Update()
    {
        // Obtener la dirección de la cámara
        Vector3 forward = camera.transform.forward;
        forward.y = 0; // Ignorar el eje Y
        forward.Normalize();

        Vector3 right = camera.transform.right;
        right.y = 0;
        right.Normalize();

        // Capturar las entradas
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

        // Combinar movimiento con la dirección de la cámara
        Vector3 movement = (forward * moveVertical) + (right * moveHorizontal);

        // Aplicar fuerza al Rigidbody del jugador
        if (playerRigidbody.velocity.magnitude < maxVelocity) // Limitar la velocidad máxima
        {
            playerRigidbody.AddForce(movement * moveSpeed);
        }
    }
}
