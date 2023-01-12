using UnityEngine;

public class QuestInputProvider : IInputProvider
{
    public Vector3 GetBreathPosition()
    {
        return RootCameraRigManager.Instance.Head.transform.position;
    }

    public bool GetIsBreathing()
    {
        return OVRInput.Get(OVRInput.RawButton.RIndexTrigger);
    }
    
    public Vector3 GetHeadDirection()
    {
        return RootCameraRigManager.Instance.Head.transform.forward;
    }
}