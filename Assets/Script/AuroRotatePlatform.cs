using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AuroRotatePlatform : MonoBehaviour
{
    // Cantidad de rotaci�n en cada eje (X, Y, Z)
    public Vector3 rotationAmount;
    public float rotationDuration = 2f; // Duraci�n de la rotaci�n
    public float returnDuration = 1f;   // Duraci�n de la vuelta a la rotaci�n original
    public float waitTime = 2f;         // Tiempo de espera entre cada ciclo

    private Quaternion originalRotation; // Para guardar la rotaci�n original

    void Start()
    {
        // Guardar la rotaci�n original de la plataforma
        originalRotation = transform.rotation;

        // Iniciar el ciclo de rotaci�n al comenzar
        StartRotationLoop();
    }

    void StartRotationLoop()
    {
        // Rotar la plataforma seg�n el vector rotationAmount
        transform.DORotate(rotationAmount, rotationDuration, RotateMode.WorldAxisAdd)
                 .OnComplete(() => StartReturnToOriginalRotation()); // Cuando termine de rotar, comienza a volver
    }

    void StartReturnToOriginalRotation()
    {
        // Esperar un tiempo antes de volver a la rotaci�n original
        DOVirtual.DelayedCall(waitTime, () =>
        {
            // Volver a la rotaci�n original
            transform.DORotateQuaternion(originalRotation, returnDuration)
                     .OnComplete(() => RestartRotationLoop()); // Cuando vuelva al original, reinicia el ciclo
        });
    }

    void RestartRotationLoop()
    {
        // Esperar antes de comenzar nuevamente la rotaci�n
        DOVirtual.DelayedCall(waitTime, () =>
        {
            StartRotationLoop(); // Iniciar la rotaci�n de nuevo
        });
    }
}