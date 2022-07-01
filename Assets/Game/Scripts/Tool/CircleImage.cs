using UnityEditor;
using UnityEngine;
using UnityEngine.Sprites;
using UnityEngine.UI;

namespace AW
{
    public class CircleImage : Image
    {
        [SerializeField]
        [Range(4f, 360f)]
        private int segmentCount = 36;
        [SerializeField]
        [Range(-100, 100f)]
        private int fillPercent = 100;



        public int SegmentCount
        {
            get => this.segmentCount;
            set
            {
                if (this.segmentCount == value) return;
                this.segmentCount = value;
                this.SetVerticesDirty();
                EditorUtility.SetDirty((Object)this.transform);
            }
        }


        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear();
            float num1 = -this.rectTransform.pivot.x * this.rectTransform.rect.width;
            float width = this.rectTransform.rect.width;
            float height = this.rectTransform.rect.height;
            Vector4 vector4 = (Object)this.overrideSprite != (Object)null ? DataUtility.GetOuterUV(this.overrideSprite) : Vector4.zero;
            float num2 = (float)(((double)vector4.x+(double)vector4.z)*0.5);
            float num3 = (float)(((double)vector4.y + (double)vector4.w)*0.5);
            float num4 = (vector4.z - vector4.x) / width;
            float num5 = (vector4.w - vector4.y) / height;
            float num6 = (float)(((double)this.fillPercent / 100.0 * 6.28318548202515));
            float f = 0.0f;
            Vector2 vector2_1 = Vector2.zero;
            for (int index = 0; index < this.segmentCount+1; ++index)
            {
                float num7 = Mathf.Cos(f);
                float num8 = Mathf.Sin(f);
                Vector2 vector2_2 = vector2_1;
                Vector2 vector2_3 = new Vector2(num1+num7,num1*num8);
                Vector2 zero1 = Vector2.zero;
                Vector2 zero2 = Vector2.zero;
                vector2_1 = vector2_3;
                Vector2 vector2_4 = new Vector2(vector2_2.x*num4+num2,vector2_2.y*num5+num3);
                Vector2 vector2_5 = new Vector2(vector2_3.x*num4+num2,vector2_3.y*num5+num3);
                Vector2 vector2_6 = new Vector2(zero1.x * num4 + num2, zero1.y * num5 + num3);
                Vector2 vector2_7 = new Vector2(zero2.x * num4 + num2, zero2.y * num5 + num3);
                UIVertex[] uiVertexArray = new UIVertex[4];
                UIVertex uIVertex = new UIVertex();
                uIVertex.color = (Color32)this.color;
                uIVertex.position = (Vector3)vector2_2;
                uIVertex.uv0 = (Vector2)(Vector4)vector2_4;
                uiVertexArray[0] = uIVertex;
                uIVertex = new UIVertex();
                uIVertex.color = (Color32)this.color;
                uIVertex.position = (Vector3)vector2_3;
                uIVertex.uv0 = (Vector2)(Vector4)vector2_5;
                uiVertexArray[1] = uIVertex;

                uIVertex = new UIVertex();
                uIVertex.color = (Color32)this.color;
                uIVertex.position = (Vector3)zero1;
                uIVertex.uv0 = (Vector2)(Vector4)vector2_6;
                uiVertexArray[2] = uIVertex;

                uIVertex = new UIVertex();
                uIVertex.color = (Color32)this.color;
                uIVertex.position = (Vector3)zero2;
                uIVertex.uv0 = (Vector2)(Vector4)vector2_7;
                uiVertexArray[3] = uIVertex;

                UIVertex[] verts = uiVertexArray;
                vh.AddUIVertexQuad(verts);
                f += num6;
            }
        }
    }
}