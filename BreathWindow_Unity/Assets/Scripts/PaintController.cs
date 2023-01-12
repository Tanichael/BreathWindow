using System;
using UnityEngine;
using UnityEngine.TerrainTools;
using Zenject;

public class PaintController : MonoBehaviour
{
    [Inject] private IInputProvider _inputProvider;

    [SerializeField] private string _mainTextureName = "_MainTex";
    [SerializeField] private Camera _camera;
    [SerializeField] private int _rad;
    [SerializeField] private int _drawRad;
    [SerializeField] private int _frostRad;
    [SerializeField] private Material _drawMaterial;

    private Renderer _paintRenderer;
    private Material _material;
    private Texture2D _mainTexture;
    private RenderTexture _drawTexture;
    
    //シェーダープロパティ
    private int _mainTexturePropertyId;
    private int _frostRadPropertyId;
    private int _drawRadPropertyId;
    private int _frostUvPropertyId;
    private int _drawUvPropertyId;
    
    void Start ()
    {
        InitPropertyId();
        
        _paintRenderer = GetComponent<Renderer>();
        _material = _paintRenderer.material;
        _mainTexture = (Texture2D) _material.mainTexture;

        var mainTexture = _material.GetTexture(_mainTexturePropertyId);

        if (mainTexture == null)
        {
            Debug.LogWarning("テクスチャが設定されていません");
            Destroy(this);
            return;
        }
        else
        {
            _drawTexture = new RenderTexture(mainTexture.width, mainTexture.height, 0, RenderTextureFormat.ARGB32,
                RenderTextureReadWrite.Default);
            Graphics.Blit(mainTexture, _drawTexture);
            _material.SetTexture(_mainTexturePropertyId, _drawTexture);
        }
    }
    
    void Update () 
    {
        if (_inputProvider.GetIsBreathing())
        {
            Ray ray = new Ray(_inputProvider.GetBreathPosition(), _inputProvider.GetHeadDirection());
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit, 100.0f))
            {
                Frost(hit);
            }
        }

        //これはタッチしたときのイベントを処理する感じにする
        if (Input.GetKey(KeyCode.A))
        {
            Ray ray = new Ray(_inputProvider.GetBreathPosition(), _inputProvider.GetHeadDirection());
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit, 100.0f))
            {
                Draw(hit);
            }
        }
    }

    void InitPropertyId()
    {
        _mainTexturePropertyId = Shader.PropertyToID(_mainTextureName);
        
        _frostRadPropertyId = Shader.PropertyToID("_FrostRad");
        _drawRadPropertyId = Shader.PropertyToID("_DrawRad");
        _frostUvPropertyId = Shader.PropertyToID("_FrostUV");
        _drawUvPropertyId = Shader.PropertyToID("_DrawUV");
    }

    void Frost(RaycastHit hit)
    {
        var uv = hit.textureCoord;
        RenderTexture buf = RenderTexture.GetTemporary(_drawTexture.width, _drawTexture.height);
        
        //曇らせる処理
        //曇る速度を操作するパラメータを用意したい
        //実際は非同期にしたい
        Debug.Log("x, y = " + uv.x + ", " + uv.y);
        Debug.Log("Frosting");
        _drawMaterial.SetInt(_drawRadPropertyId, 0);
        _drawMaterial.SetInt(_frostRadPropertyId, _frostRad);
        _drawMaterial.SetVector(_frostUvPropertyId, uv);
        Graphics.Blit(_drawTexture, buf, _drawMaterial);
        Graphics.Blit(buf, _drawTexture);
        
        RenderTexture.ReleaseTemporary(buf);
    }
    
    void Draw(RaycastHit hit)
    {
        var uv = hit.textureCoord;
        RenderTexture buf = RenderTexture.GetTemporary(_drawTexture.width, _drawTexture.height);
        
        //描く処理
        Debug.Log("x, y = " + uv.x + ", " + uv.y);
        Debug.Log("Frosting");
        _drawMaterial.SetInt(_frostRadPropertyId, 0);
        _drawMaterial.SetInt(_drawRadPropertyId, _drawRad);
        _drawMaterial.SetVector(_drawUvPropertyId, uv);
        Graphics.Blit(_drawTexture, buf, _drawMaterial);
        Graphics.Blit(buf, _drawTexture);
        
        RenderTexture.ReleaseTemporary(buf);
    }

}