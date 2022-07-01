using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.UI;
using UnityEngine.EventSystems;

namespace AW
{
    public static class DevelopTool
    {
        static bool has_add_update = false;
        [MenuItem("艾玩工具/DevelopTool/射线定位预制体(CheckRaycast) &_z")]
        static void CheckRaycast()
        {
            if (DevelopTool.has_add_update) return;
            EditorApplication.update += () =>
            {
                if (Input.GetMouseButtonDown(1) && EditorApplication.isPlaying)
                {
                    GameObject ui_layer = GameObject.Find("GameRoot/UILayer");
                    Dictionary<MaskableGraphic, bool> dic = new Dictionary<MaskableGraphic, bool>();
                    if (ui_layer != null)
                    {
                        MaskableGraphic[] ms = ui_layer.GetComponentsInParent<MaskableGraphic>();
                        foreach (var m in ms)
                        {
                            dic.Add(m, m.raycastTarget);
                            m.raycastTarget = true;
                        }
                    }

                    PointerEventData eventData = new PointerEventData(EventSystem.current);
                    eventData.pressPosition = Input.mousePosition;
                    eventData.position = Input.mousePosition;
                    List<RaycastResult> list = new List<RaycastResult>();
                    EventSystem.current.RaycastAll(eventData,list);
                    if (list.Count>0)
                    {
                        EditorGUIUtility.PingObject(list[0].gameObject);
                    }
                    foreach (var m in dic)
                    {
                        m.Key.raycastTarget = m.Value;
                    }

                }
            };
            DevelopTool.has_add_update = true;
        }
    }
}