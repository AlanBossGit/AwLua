using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using Object = UnityEngine.Object;
using System.Linq;
using System.Text.RegularExpressions;

namespace AW
{
    public class FindAssetsPrefabs : MonoBehaviour
    {
        [MenuItem("Assets/检查引用",false)]
        static void Find()
        {
            EditorSettings.serializationMode = SerializationMode.ForceText;
            string path = AssetDatabase.GetAssetPath(Selection.activeObject);
            if (!string.IsNullOrEmpty(path))
            {
                Debug.Log("开始查找哪里引用到资源：" + path);
                string guid = AssetDatabase.AssetPathToGUID(path);
                List<string> withoutExtensions = new List<string>() { ".prefab"};
                string[] files = Directory
                    .GetFiles(Application.dataPath + "/Resources/UI", "*.*", SearchOption.AllDirectories)
                    .Where(s => withoutExtensions.Contains(Path.GetExtension(s).ToLower())).ToArray();
                int startIndex = 0;
                EditorApplication.update = delegate ()
                {
                    string file = files[startIndex];
                    if (string.IsNullOrEmpty(file))
                    {
                        Debug.Log("资源为空");
                        return;
                    }
                    bool isCancel = EditorUtility.DisplayCancelableProgressBar("匹配资源中", file, (float)startIndex / (float)file.Length);
                    if (Regex.IsMatch(File.ReadAllText(file),guid))
                    { 
                        Debug.Log("资源路径：" + GetRelativeAssetsPath(file));
                        Object find_oj = AssetDatabase.LoadAssetAtPath<Object>(GetRelativeAssetsPath(file));
                        Debug.Log(file+"引用到该资源",find_oj);
                        string extension = Path.GetExtension(file);
                        isCancel = EditorUtility.DisplayDialog("找到了",file+"引用资源","关闭","继续查找");
                    }
                    startIndex= Mathf.Clamp(startIndex = startIndex + 1,0, files.Length-1);
                    if (isCancel||startIndex>= files.Length)
                    {
                        Debug.Log("超出索引");
                        EditorUtility.ClearProgressBar();
                        EditorApplication.update = null;
                        startIndex = 0;
                        Debug.Log("匹配结束");
                    }
                };
            }
        }



        static private string GetRelativeAssetsPath(string path)
        {
            return "Assets" + Path.GetFullPath(path).Replace(Path.GetFullPath(Application.dataPath), "").Replace('\\','/');
        }
    }
}