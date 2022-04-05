using System;
using System.Collections.Generic;
using UnityEngine;

namespace AW
{
	[AddComponentMenu("Nirvana/UI/Bind/UI Name Table")]
	public sealed class UINameTable : MonoBehaviour
	{
		

		[SerializeField]
		[Tooltip("The bind list.")]
		public List<BindPair> binds = new List<BindPair>();

		private Dictionary<string, GameObject> lookup;

		public Dictionary<string, GameObject> Lookup
		{
			get
			{
				if (lookup == null)
				{
					lookup = new Dictionary<string, GameObject>(StringComparer.Ordinal);
					if (binds != null)
					{
						foreach (BindPair bind in binds)
						{
							lookup.Add(bind.Name, bind.Widget);
						}
					}
				}
				return lookup;
			}
		}

		public GameObject Find(string key)
		{
			GameObject gameObject;
			return this.Lookup.TryGetValue(key,out gameObject)? gameObject : null;
		}

		public bool Add(string key, GameObject obj)
		{
			if (lookup.ContainsKey(key))
			{
				return false;
			}
			lookup.Add(key, obj);
			this.binds.Add(new UINameTable.BindPair()
			{
				Name = key,
				Widget = obj
			});
			return true;
		}


		public void Sort() => this.binds.Sort((Comparison<UINameTable.BindPair>)((lhs,rhs)=>lhs.Name.CompareTo(rhs.Name)));
		public UINameTable.BindPair[] Search(string key)
        {
			List<UINameTable.BindPair> bindPairList = new List<BindPair>();
            foreach (var bind in binds)
            {
				if (bind.Name.StartsWith(key))
                {
					bindPairList.Add(bind);
                }
            }
			return bindPairList.ToArray();
		}


		[Serializable]
		public struct BindPair
		{
			[Tooltip("The name of this bind.")]
			public string Name;

			[Tooltip("The widget of this UI.")]
			public GameObject Widget;
		}
	}
}
