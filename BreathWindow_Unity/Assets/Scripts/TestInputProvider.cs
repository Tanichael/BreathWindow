using UnityEngine;

public class TestInputProvider : IInputProvider
{
    public Vector3 GetBreathPosition(Camera camera)
    {
        return camera.ScreenToWorldPoint(Input.mousePosition);
    }

    public bool GetIsBreathing()
    {
        return Input.GetKey(KeyCode.Space);
    }
    
    public Vector3 GetHeadDirection()
    {
        return new Vector3(0, 0, 1);
    }
}
