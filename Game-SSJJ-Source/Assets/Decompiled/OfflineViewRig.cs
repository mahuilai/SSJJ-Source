using UnityEngine;
using SSJJMath;

/// <summary>
/// 离线第三人称相机：围绕玩家实体/模型旋转，确保角色、手模和武器可见。
/// </summary>
[DefaultExecutionOrder(20000)]
public class OfflineViewRig : MonoBehaviour
{
    public static GameObject ModelObject;

    public float yaw = 0f;
    public float pitch = 10f;
    public float sens = 0.15f;
    public float distance = 650f;
    public float height = 200f;

    private Camera cam;
    private bool locked = true;

    private void LateUpdate()
    {
        PlayerEntity me = Contexts.sharedInstance.player.myPlayerEntity;
        bool hasPlayer = (me != null && me.hasBasicInfo && me.basicInfo.Current != null);
        Vector3 feet = Vector3.zero;
        if (hasPlayer)
            feet = VectorCoordConverter.SsjjToUnity(new Vector3(me.basicInfo.Current.X, me.basicInfo.Current.Y, me.basicInfo.Current.Z));

        Camera best = null;
        Camera[] cams = Camera.allCameras;
        for (int i = 0; i < cams.Length; i++)
        {
            Camera c = cams[i];
            if (c == null || !c.isActiveAndEnabled) continue;
            if (best == null || c.farClipPlane > best.farClipPlane) best = c;
        }
        cam = best;
        if (cam == null) return;

        if (Input.GetKeyDown(KeyCode.Escape)) locked = !locked;
        Cursor.lockState = locked ? CursorLockMode.Locked : CursorLockMode.None;
        Cursor.visible = !locked;

        if (locked)
        {
            yaw += Input.GetAxisRaw("Mouse X") * sens;
            pitch -= Input.GetAxisRaw("Mouse Y") * sens;
            pitch = Mathf.Clamp(pitch, -20f, 70f);
        }

        if (ModelObject != null && hasPlayer)
            ModelObject.transform.position = feet;

        if (hasPlayer)
        {
            Quaternion rot = Quaternion.Euler(pitch, yaw, 0f);
            Vector3 focus = feet + Vector3.up * 100f;
            Vector3 offset = rot * new Vector3(0f, 0f, -distance);
            cam.transform.position = focus + offset + Vector3.up * height;
            cam.transform.rotation = Quaternion.LookRotation(focus - cam.transform.position);
        }
    }
}
