using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ChangePostproValue : MonoBehaviour
{
    public Volume volume;
    public float bloomValue;
    public float chromaticValue;

    private void OnValidate()
    {
        ChangeValues();
    }

    private void Update()
    {
        ChangeValues();
    }

    private void ChangeValues()
    {
        foreach (var profileComponent in volume.profile.components)
        {
            if (profileComponent is Bloom bloom)
                bloom.intensity.value = bloomValue;
            else if (profileComponent is ChromaticAberration chromaticAberration)
                chromaticAberration.intensity.value = chromaticValue;
        }
    }
}
