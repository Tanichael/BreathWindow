using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class RootCameraRigManager : MonoBehaviour
{
    [SerializeField] private GameObject _head;

    public GameObject Head => _head;

    public static RootCameraRigManager Instance;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
        }

        Instance = this;
    }
}
