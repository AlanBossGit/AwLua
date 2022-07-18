using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
namespace AW
{
    public static  class ImageExtensions
    {
       public static void SetSprite(this Image image,string assetPath,Sprite sprite)
       {
            image.sprite = sprite;
       }
    }
}