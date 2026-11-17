using UnityEngine;

/// <summary>
/// 离线自由飞行相机：不依赖未接管的玩家实体，保证进图即可移动/观察。
/// PyEngine 仍保持初始化，后续可把控制权切回玩家实体。
/// </summary>
[DefaultExecutionOrder(20000)]
public class OfflineCameraRig : MonoBehaviour
{
    public Vector3 startPos = new Vector3(-4800f, 5000f, 5551f);
    public float yaw = 0f;
    public float pitch = 80f;
    public float sens = 0.05f;
    public float speed = 1200f;
    public float boost = 4f;

    private Camera cam;
    private bool locked = true;

    private void Start()
    {
        transform.position = startPos;
        Debug.Log("[OFFLINE-FLY] start=" + startPos + " yaw=" + yaw);
    }

    private void LateUpdate()
    {
        Camera best = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            Camera c = cams[i];
            if (c == null || !c.isActiveAndEnabled) continue;
            if (best == null || c.farClipPlane > best.farClipPlane) best = c;
        }
        if (best != cam)
        {
            cam = best;
            if (cam != null)
            {
                cam.nearClipPlane = 1f;
                Debug.Log("[OFFLINE-FLY] cam=" + cam.name + " far=" + cam.farClipPlane);
            }
        }
        if (cam == null) return;

        if (Input.GetKeyDown(KeyCode.Escape)) locked = !locked;
        Cursor.lockState = locked ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = !locked;

        if (locked)
        {
            yaw += Input.GetAxisRaw("Mouse X") * sens;
            pitch -= Input.GetAxisRaw("Mouse Y") * sens;
            pitch = Mathf.Clamp(pitch, -89f, 89f);
        }

        float h = 0f, v = 0f, u = 0f;
        if (Input.GetKey(KeyCode.A)) h -= 1f;
        if (Input.GetKey(KeyCode.D)) h += 1f;
        if (Input.GetKey(KeyCode.S)) v -= 1f;
        if (Input.GetKey(KeyCode.W)) v += 1f;
        if (Input.GetKey(KeyCode.Space)) u += 1f;
        if (Input.GetKey(KeyCode.LeftControl) || Input.GetKey(KeyCode.C)) u -= 1f;

        Quaternion rot = Quaternion.Euler(pitch, yaw, 0f);
        Vector3 dir = rot * Vector3.forward * v + rot * Vector3.right * h + Vector3.up * u;
        if (dir.sqrMagnitude > 1f) dir.Normalize();
        float sp = speed * (Input.GetKey(KeyCode.LeftShift) ? boost : 1f);
        transform.position += dir * sp * Time.deltaTime;

        cam.transform.position = transform.position;
        cam.transform.rotation = rot;
    }
}
