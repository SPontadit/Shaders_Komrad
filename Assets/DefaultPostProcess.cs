using UnityEngine;

[ExecuteInEditMode]
public class DefaultPostProcess : MonoBehaviour
{
	[SerializeField]
	Material material;
	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		if (material != null)
		{
			Graphics.Blit(source, destination, material);
		}
	}
}
