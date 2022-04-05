using UnityEngine;
using System.Collections;
using LuaInterface;

namespace LuaFramework {
    public class LuaManager : Manager {
        private LuaState lua;
        private LuaLoader loader;
        private LuaLooper loop = null;

        //新增函数（Alan）
        private LuaFunction gameUpdate;
        private LuaFunction gameDestroy;
        private LuaFunction gamePause;
        private LuaFunction gameFocus;
        private LuaFunction gameQuit;

        // Use this for initialization
        void Awake() {
            loader = new LuaLoader();
            lua = new LuaState();
            this.OpenLibs();
            lua.LuaSetTop(0);

            LuaBinder.Bind(lua);
            DelegateFactory.Init();
            LuaCoroutine.Register(lua, this);
        }

        public void InitStart() {
            InitLuaPath();
            InitLuaBundle();
            this.lua.Start();    //启动LUAVM
            this.StartMain();
            this.StartLooper();  
        }

        void StartLooper() {
            loop = gameObject.AddComponent<LuaLooper>();
            loop.luaState = lua;
        }

        //cjson 比较特殊，只new了一个table，没有注册库，这里注册一下
        protected void OpenCJson() {
            lua.LuaGetField(LuaIndexes.LUA_REGISTRYINDEX, "_LOADED");
            lua.OpenLibs(LuaDLL.luaopen_cjson);
            lua.LuaSetField(-2, "cjson");

            lua.OpenLibs(LuaDLL.luaopen_cjson_safe);
            lua.LuaSetField(-2, "cjson.safe");
        }

        void StartMain() {
            lua.DoFile("Main.lua");
            LuaFunction main = lua.GetFunction("Main");
            main.Call();
            main.Dispose();
            main = null;    
        }

        //注册Main.lua中的【FocusMain】函数（Alan）
        public void FocusMain(bool focus)
        {
            if (null == lua) return;
            gameFocus = lua.GetFunction("GameFocus");
            if (gameFocus != null)
            {
                gameFocus.Call(focus);
            }
        }

        //注册Main.lua中的【QuitMain】函数（Alan）
        public void QuitMain()
        {
            if (null == lua) return;
            gameQuit = lua.GetFunction("GameQuit");
            if (gameQuit != null)
            {
                gameQuit.Call();
                gameQuit.Dispose();
                gameQuit = null;
            }
        }
        
        //注册Main.lua中的【GamePause】函数（Alan）
        public void PauseMain(bool pause)
        {
            if (null == lua) return;
            gamePause = lua.GetFunction("GamePause");
            gamePause.Call(pause);
            gamePause.Dispose();
            gamePause = null;
        }

        //注册Main.lua中的【GameUpdate】函数（Alan）
        public void UpdateMain()
        {
            if (null == lua) return;
            gameUpdate = lua.GetFunction("GameUpdate");
            gameUpdate.Call();
        }

        //注册且释放Main.lua中的【GameDestroy】函数（Alan）
        public void DestroyMain()
        {
            if (null == lua) return;
            gameDestroy = lua.GetFunction("GameDestroy");
            if (gameDestroy != null)
            {
                gameDestroy.Call();
                gameDestroy.Dispose();
                gameDestroy = null;
            }
        }

        /// <summary>
        /// 初始化加载第三方库
        /// </summary>
        void OpenLibs() {
            lua.OpenLibs(LuaDLL.luaopen_pb);      
            lua.OpenLibs(LuaDLL.luaopen_sproto_core);
            lua.OpenLibs(LuaDLL.luaopen_protobuf_c);
            lua.OpenLibs(LuaDLL.luaopen_lpeg);
            lua.OpenLibs(LuaDLL.luaopen_bit);
            lua.OpenLibs(LuaDLL.luaopen_socket_core);
            this.OpenCJson();
        }

        /// <summary>
        /// 初始化Lua代码加载路径
        /// </summary>
        void InitLuaPath() {
            if (AppConst.DebugMode) {
                string rootPath = AppConst.FrameworkRoot;
                lua.AddSearchPath(rootPath + "/Lua");
                lua.AddSearchPath(rootPath + "/ToLua/Lua");
            } else
            {
                lua.AddSearchPath(Util.DataPath + "lua");
            }
        }

        /// <summary>
        /// 初始化LuaBundle
        /// </summary>
        void InitLuaBundle() {
            if (loader.beZip) {
                loader.AddBundle("lua/lua.unity3d");
                loader.AddBundle("lua/lua_math.unity3d");
                loader.AddBundle("lua/lua_system.unity3d");
                loader.AddBundle("lua/lua_system_reflection.unity3d");
                loader.AddBundle("lua/lua_unityengine.unity3d");
                loader.AddBundle("lua/lua_common.unity3d");
                loader.AddBundle("lua/lua_logic.unity3d");
                loader.AddBundle("lua/lua_view.unity3d");
                loader.AddBundle("lua/lua_controller.unity3d");
                loader.AddBundle("lua/lua_misc.unity3d");

                loader.AddBundle("lua/lua_protobuf.unity3d");
                loader.AddBundle("lua/lua_3rd_cjson.unity3d");
                loader.AddBundle("lua/lua_3rd_luabitop.unity3d");
                loader.AddBundle("lua/lua_3rd_pbc.unity3d");
                loader.AddBundle("lua/lua_3rd_pblua.unity3d");
                loader.AddBundle("lua/lua_3rd_sproto.unity3d");
            }
        }

        public void DoFile(string filename) {
            lua.DoFile(filename);
        }

        // Update is called once per frame
        public object[] CallFunction(string funcName, params object[] args) {
            LuaFunction func = lua.GetFunction(funcName);
            if (func != null) {
                return func.LazyCall(args);
            }
            return null;
        }

        public void LuaGC() {
            lua.LuaGC(LuaGCOptions.LUA_GCCOLLECT);
        }

        public void Close() {
            loop.Destroy();
            loop = null;

            lua.Dispose();
            lua = null;
            loader = null;

            //***********Alan修改*********//
            //释放注册Main.lua中的【GameUpdate】函数
            if (gameUpdate != null)
            {
                gameUpdate.Dispose();
                gameUpdate = null;
            }

            if (gameFocus != null)
            {
                gameFocus.Dispose();
                gameFocus = null;
            }
           
        }
    }
}