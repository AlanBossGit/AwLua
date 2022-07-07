using UnityEngine;
using System.Collections;

namespace LuaFramework {
    /// <summary>
    /// </summary>
    public class Main : MonoBehaviour {
        void Start() {
            BaseBehaviour.Initialize();
            AppFacade.Instance.StartUp();   //启动游戏
        }
    }
}