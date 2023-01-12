using UnityEngine;

public interface IInputProvider
{
    Vector3 GetBreathPosition();
    bool GetIsBreathing();
    Vector3 GetHeadDirection();
}
