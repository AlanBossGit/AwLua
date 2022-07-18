using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
namespace AW
{
    public static class ButtonExtensions
    {
        public static void SetClickListener(this Button button,UnityAction call)
        {
            button.onClick.RemoveAllListeners();
            button.onClick.AddListener(call);
        }

        public static void AddClickListener(this Button button,UnityAction call)
        {
            Debug.Log("======");
            button.onClick.RemoveAllListeners();
            button.onClick.AddListener(call);
        }
    }
}