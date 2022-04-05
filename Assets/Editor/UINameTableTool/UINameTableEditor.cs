using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditorInternal;
using System;
using Object = UnityEngine.Object;
namespace AW
{
    [CustomEditor(typeof(UINameTable))]
    internal sealed class UINameTableEditor : Editor
    {
        private SerializedProperty binds;
        private ReorderableList bindList;
        private string searchText;
        private UINameTable.BindPair[] seachResult;
        private HashSet<int> duplicateIndexs = new HashSet<int>();
        private Dictionary<string, int> checkTable = new Dictionary<string, int>((IEqualityComparer<string>)StringComparer.Ordinal);
        private Dictionary<Object, int> checkGogupLicateTable = new Dictionary<Object, int>();
        private GameObject newObject;
        private Object duplicatedObject;
        private static GameObject searchnameTableObj;
        private static GameObject searchObject;


        public override void OnInspectorGUI()
        {
            this.serializedObject.Update();
            this.bindList.DoLayoutList();
            if (this.serializedObject.ApplyModifiedProperties())
            {
                this.FindDuplicate();
            }
            UINameTable target = (UINameTable)this.target;
            GUILayout.BeginHorizontal();
            this.newObject = EditorGUILayout.ObjectField(this.newObject, typeof(GameObject), true) as GameObject;
            if (GUILayout.Button("Add"))
            {
                if ((Object)this.newObject == (Object)null)
                {
                    return;
                }
                this.duplicatedObject = (Object)null;
                if (this.FindDuplicate((Object)this.newObject))
                {
                    Debug.LogError("Duplicated object");
                    return;
                }
                string name = this.newObject.name;
                int num = 0;
                while ((bool)target.Find(name))
                {
                    name += (string)(object)num;
                    ++num;
                }
                Undo.RecordObject(target, "Add to Name Table");
                this.serializedObject.Update();
                target.Add(name, this.newObject);
                this.serializedObject.ApplyModifiedProperties();
            }
            GUILayout.EndHorizontal();
            string str = EditorGUILayout.TextField("Search", this.searchText);
            if (string.IsNullOrEmpty(str))
            {
                this.searchText = null;
                this.seachResult = null;
            } else if (str != this.searchText)
            {
                this.searchText = str;
                this.seachResult = target.Search(this.searchText);
            }
            if (this.seachResult != null) {
                GUI.enabled = false;
                GUILayout.BeginVertical(GUI.skin.textArea);
                foreach (var bindPair in this.seachResult)
                {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField(bindPair.Name);
                    EditorGUILayout.ObjectField(bindPair.Widget, bindPair.Widget.GetType(), true);
                    EditorGUILayout.EndHorizontal();
                }
                GUILayout.EndVertical();
                GUI.enabled = true;
            }
            if (!GUILayout.Button("Sort")) return;
            Undo.RecordObject(target, "Sort Name Table");
            this.serializedObject.Update();
            target.Sort();
            this.serializedObject.ApplyModifiedProperties();
        }

        private void OnDisable()
        {
            UINameTable target = this.target as UINameTable;
            if (!(null != target) || target.gameObject == searchnameTableObj)
            {
                return;
            }
            searchnameTableObj = null;
            searchObject = null;
        }

        private void OnEnable()
        {
            if (this.target == null)
            {
                return;
            }
            SerializedObject serializedObject = this.serializedObject;
            this.binds = serializedObject.FindProperty("binds");
            this.bindList = new ReorderableList(serializedObject, this.binds);
            this.bindList.drawHeaderCallback = (ReorderableList.HeaderCallbackDelegate)(rect => this.DrawBindHeader(rect));
            this.bindList.elementHeight = EditorGUIUtility.singleLineHeight;
            this.bindList.drawElementCallback = (ReorderableList.ElementCallbackDelegate)((rect, index, selected, focused) => this.DrawBind(this.binds, rect, index, selected, focused));
            this.FindDuplicate();

        }

        private void DrawBindHeader(Rect rect)
        {
            Rect position1 = new Rect(rect.x + 13, rect.y, rect.width / 2f, EditorGUIUtility.singleLineHeight);
            Rect position2 = new Rect((float)(rect.x + 10.0 + rect.width / 2.0), rect.y, rect.width / 2f, EditorGUIUtility.singleLineHeight);
            GUI.Label(position1, "Name");
            GUI.Label(position2, "Wedget");
        }



        private void DrawBind(SerializedProperty property, Rect rect, int index, bool selected, bool focused)
        {
            SerializedProperty arrayElementAtIndex = property.GetArrayElementAtIndex(index);
            int num = this.duplicateIndexs.Contains(index) ? 1 : 0;
            Color color = GUI.color;
            if (num != 0)
            {
                GUI.color = new Color(1f, 0.5f, 0.5f, 1f);
            }
                SerializedProperty serializedProperty1 = arrayElementAtIndex.FindPropertyRelative("Name");
                SerializedProperty serializedProperty2 = arrayElementAtIndex.FindPropertyRelative("Widget");
                if (serializedProperty2.objectReferenceValue == this.duplicatedObject)
                {
                    GUI.color = new Color(0.2f, 1f, 1f, 1f);
                } else if (serializedProperty2.objectReferenceValue == this.newObject || serializedProperty2.objectReferenceValue == searchObject)
                {
                    GUI.color = new Color(0.5f, 1f, 0.5f, 1f);
                }
                Rect position1 = new Rect(rect.x, rect.y, (float)(rect.width / 2.0 - 5.0), EditorGUIUtility.singleLineHeight);
                Rect position2 = new Rect((float)(rect.x + rect.width / 2.0 + 5.0), rect.y, (float)(rect.width / 2.0 - 5.0), EditorGUIUtility.singleLineHeight);
                EditorGUI.PropertyField(position1, serializedProperty1, GUIContent.none);
                SerializedProperty property1 = serializedProperty2;
                GUIContent none = GUIContent.none;
                EditorGUI.PropertyField(position2, property1, none);
                GUI.color = color;
       
        }

        private bool FindDuplicate(Object go)
        {
            for (int index = 0; index < binds.arraySize; ++index)
            {
                if (binds.GetArrayElementAtIndex(index).FindPropertyRelative("Widget").objectReferenceValue == go)
                {
                    this.duplicatedObject = go;
                    return true;
                }
            }
            return false;
        }


        private void FindDuplicate()
        {
            this.duplicateIndexs.Clear();
            this.checkTable.Clear();
            this.checkGogupLicateTable.Clear();
            for (int index = 0; index < this.binds.arraySize; ++index)
            {
                SerializedProperty arrayElementAtIndex = this.binds.GetArrayElementAtIndex(index);
                SerializedProperty propertyRelative = arrayElementAtIndex.FindPropertyRelative("Name");
                Object objectReferenceValue = arrayElementAtIndex.FindPropertyRelative("Widget").objectReferenceValue;
                if (checkTable.ContainsKey(propertyRelative.stringValue))
                {
                    this.duplicateIndexs.Add(checkTable[propertyRelative.stringValue]);
                    this.duplicateIndexs.Add(index);
                } else if (objectReferenceValue != null && this.checkGogupLicateTable.ContainsKey(objectReferenceValue))
                {
                    this.duplicateIndexs.Add(this.checkGogupLicateTable[objectReferenceValue]);
                    this.duplicateIndexs.Add(index);
                }
                else
                {
                    this.checkTable.Add(propertyRelative.stringValue, index);
                    if (objectReferenceValue != null)
                    {
                        checkGogupLicateTable.Add(objectReferenceValue, index);
                    }
                }
            }
        }

        [MenuItem("GameObject/Find Name Table",priority = 0)]
        private static void FindNameTable(){
            GameObject activeGameObject = Selection.activeGameObject;
            if (null==activeGameObject) return;
            UINameTable[] componentsInparent = activeGameObject.transform.GetComponentsInParent<UINameTable>(true);
            if (componentsInparent.Length == 0) return;
            foreach (var componetsInChild in componentsInparent[componentsInparent.Length - 1].GetComponentsInChildren<UINameTable>(true))
            {
                foreach (var bind in componetsInChild.binds)
                {
                    if (activeGameObject == bind.Widget)
                    {
                        Selection.activeObject = componetsInChild.gameObject;
                        searchnameTableObj = Selection.activeObject as GameObject;
                        searchObject = activeGameObject;
                        break;
                    }
                }
            }
        }

        [MenuItem("GameObject/Add Name Table", priority = 0)]
        private static void AddNameTable()
        {
            foreach (var go in Selection.gameObjects)
            {
                UINameTable ima = go.transform.parent.GetComponentInParent<UINameTable>();
                List<UINameTable.BindPair> binds = ima.binds;
                List<UINameTable.BindPair> list = new List<UINameTable.BindPair>();
                for (int i = 0; i < binds.Count; i++)
                {
                    if (binds[i].Widget == null || binds[i].Widget == go)
                    {
                        list.Add(binds[i]);
                    }
                }
                foreach (var i in list)
                {
                    binds.Remove(i);
                }
                if (ima != null)
                {
                    UINameTable.BindPair b = new UINameTable.BindPair();
                    b.Name = go.name;
                    b.Widget = go;
                    binds.Add(b);
                }
            }
        }

    }
}