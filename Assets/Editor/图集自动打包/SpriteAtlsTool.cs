using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.U2D;
using System.IO;
using UnityEngine.U2D;

namespace BWLB.Tool
{
    ///图集自动打包
    public class SpriteAtlsTool : Editor
    {
        [MenuItem("Assets/AlanTool/2D/AutoCreateSpriteStlas")]
        public static void AutoCreateSpriteAtlas()
        {
            Object[] selectObjs = Selection.GetFiltered(typeof(object),SelectionMode.Unfiltered);
            foreach (var select in selectObjs)
            {
                var assetPath = AssetDatabase.GetAssetPath(select);
                if (Directory.Exists(assetPath))
                {
                    DoAutoCreateSpriteAtlas(assetPath);
                }
            }
        }

        /// <summary>
        /// 在dirPath文件夹下插件SpeiteAtlas
        /// </summary>
        public static void DoAutoCreateSpriteAtlas(string dirpath)
        {
            string atlasName = GetSpriteAtlsaName(dirpath);
            string dstPath = dirpath + "/" + atlasName;
            if (File.Exists(dstPath))
            {
                File.Delete(dstPath);
            }
            SpriteAtlas atlas = new SpriteAtlas();
            //设置参数 可根据羡慕具体情况进行设置
            SpriteAtlasPackingSettings packSetting = new SpriteAtlasPackingSettings()
            {
                blockOffset = 1,
                enableRotation = false,
                enableTightPacking = false,
                padding = 2,
            };
            atlas.SetPackingSettings(packSetting);

            SpriteAtlasTextureSettings textureSetting = new SpriteAtlasTextureSettings()
            {
                readable = false,
                generateMipMaps = false,
                sRGB = true,
                filterMode = FilterMode.Bilinear,
            };
            atlas.SetTextureSettings(textureSetting);

            TextureImporterPlatformSettings platformSetting = new TextureImporterPlatformSettings()
            {
                maxTextureSize = 2048,
                format = TextureImporterFormat.Automatic,
                crunchedCompression = true,
                textureCompression = TextureImporterCompression.Compressed,
                compressionQuality = 50,
            };
            atlas.SetPlatformSettings(platformSetting);
            //创建图集：
            AssetDatabase.CreateAsset(atlas,dstPath);

            //1、添加文件
            DirectoryInfo dir = new DirectoryInfo(dirpath);
            //这里使用的是png图片，已经生成sprite精灵了，jpg到时候再看吧
            FileInfo[] files = dir.GetFiles("*.png");
            foreach (FileInfo file in files)
            {
                atlas.Add(new[] {AssetDatabase.LoadAssetAtPath<Sprite>($"{dirpath}/{file.Name}")});
            }
            //2、添加文件夹
            //Object obj = AssetDatabase.LoadAssetAtPath(_texturePaath,typeof(object));
            //atlas.Add(new[] { obj});
            AssetDatabase.SaveAssets();
            
        }

        private static string GetRelativeAssetsPath(string path)
        {
            return "Assets/" + Path.GetFullPath(path).Replace(Path.GetFullPath(Application.dataPath),"").Replace("\\","/");
        }
        private static string GetFullAssetsPath(string path)
        {
            return Application.dataPath + path.Replace("Assets", "");
        }

        public static string  GetSpriteAtlsaName(string path)
        {
            return "_" + path.Substring(path.LastIndexOf("/")+1)+".spriteatlas";
        }
    }
}