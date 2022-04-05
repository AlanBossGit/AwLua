using System.IO;
using UnityEditor;
using UnityEngine;
/// <summary>
/// 拖入图片自动打标签(拖入自动赋值)
/// </summary>
public class AutoSetTextureUISprite : AssetPostprocessor
{
    void OnPreprocessTexture()
    {
        //自动设置类型;  
        TextureImporter textureImporter = (TextureImporter)assetImporter;
        textureImporter.textureType = TextureImporterType.Sprite;

        //自动设置打包tag;  
        string dirName = Path.GetDirectoryName(assetPath);
        //获取文件名字
        string folderStr = Path.GetFileName(dirName);

        textureImporter.spritePackingTag = dirName.Split('.')[0];
    }
}