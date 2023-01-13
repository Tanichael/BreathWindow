using UnityEngine;

public interface IInputProvider
{
    Vector3 GetBreathPosition(Camera camera);
    bool GetIsBreathing();
    Vector3 GetHeadDirection();
}
