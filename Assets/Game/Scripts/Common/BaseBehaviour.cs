using System.Collections;
using System.Collections.Generic;
using Aw.Manager;
using LuaInterface;
using UnityEngine;

    public class BaseBehaviour
    {
        static Dictionary<string, BaseManager> Managers = new Dictionary<string, BaseManager>();
        static Dictionary<string, BaseObject> ExtManagers = new Dictionary<string, BaseObject>();
        private static ShaderManager _shaderMgr;
        public static ShaderManager shaderMgr
        {
            get
            {
                if (_shaderMgr == null)
                {
                    _shaderMgr = GetManager<ShaderManager>();
                }
                return _shaderMgr;
            }
        }


        private static ResourceManager _resMgr;
        protected static ResourceManager resMgr
        {
            get
            {
                if (_resMgr == null)
                {
                    _resMgr = GetManager<ResourceManager>();
                }
                return _resMgr;
            }
        }


        public T Instantiate<T>(T original) where T : UnityEngine.Object
        {
            return GameObject.Instantiate<T>(original);
        }

        public static void Destroy(UnityEngine.Object obj)
        {
            if (obj != null)
            {
                GameObject.Destroy(obj);
            }
        }

        public static void Destroy(UnityEngine.Object obj, float t)
        {
            if (obj != null)
            {
                GameObject.Destroy(obj, t);
            }
        }

        public Coroutine StartCoroutine(IEnumerator routine)
        {
            return ManagementCenter.main.StartCoroutine(routine);
        }

        [NoToLua]
        public static void Initialize()
        {
            InitManager();
        }

        /// <summary>
        /// 初始化管理器
        /// </summary>

        static void InitManager()
        {
            AddManager<ShaderManager>(); //Shader管理器
        }

        static T AddManager<T>() where T : BaseManager, new()
        {
            var type = typeof(T);
            var obj = new T();
            Managers.Add(type.Name, obj);
            return obj;
        }

        public static T GetManager<T>() where T : class
        {
            var type = typeof(T);
            if (!Managers.ContainsKey(type.Name))
            {
                return null;
            }
            return Managers[type.Name] as T;
        }

        public static BaseManager GetManager(string managerName)
        {
            if (!Managers.ContainsKey(managerName))
            {
                return null;
            }
            return Managers[managerName];
        }



        /// <summary>
        /// 初始化扩展管理器
        /// </summary>
        private static void InitExtManager()
        {
           
        }

        public static object GetExtManager(string componentName)
        {
            if (!ExtManagers.ContainsKey(componentName))
            {
                return null;
            }
            return ExtManagers[componentName];
        }
    }