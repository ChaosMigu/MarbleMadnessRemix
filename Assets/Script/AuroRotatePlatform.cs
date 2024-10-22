using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AuroRotatePlatform : MonoBehaviour
{
    // Cantidad de rotación en cada eje (X, Y, Z)
    public Vector3 rotationAmount;
    public float rotationDuration = 2f; // Duración de la rotación
    public float returnDuration = 1f;   // Duración de la vuelta a la rotación original
    public float waitTime = 2f;         // Tiempo de espera entre cada ciclo

    private Quaternion originalRotation; // Para guardar la rotación original

    void Start()
    {
        // Guardar la rotación original de la plataforma
        originalRotation = transform.rotation;

        // Iniciar el ciclo de rotación al comenzar
        StartRotationLoop();
    }

    void StartRotationLoop()
    {
        // Rotar la plataforma según el vector rotationAmount
        transform.DORotate(rotationAmount, rotationDuration, RotateMode.WorldAxisAdd)
                 .OnComplete(() => StartReturnToOriginalRotation()); // Cuando termine de rotar, comienza a volver
    }

    void StartReturnToOriginalRotation()
    {
        // Esperar un tiempo antes de volver a la rotación original
        DOVirtual.DelayedCall(waitTime, () =>
        {
            // Volver a la rotación original
            transform.DORotateQuaternion(originalRotation, returnDuration)
                     .OnComplete(() => RestartRotationLoop()); // Cuando vuelva al original, reinicia el ciclo
        });
    }

    void RestartRotationLoop()
    {
        // Esperar antes de comenzar nuevamente la rotación
        DOVirtual.DelayedCall(waitTime, () =>
        {
            StartRotationLoop(); // Iniciar la rotación de nuevo
        });
    }
}