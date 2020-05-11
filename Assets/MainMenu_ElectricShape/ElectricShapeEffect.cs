using UnityEngine;

public class ElectricShapeEffect : MonoBehaviour
{
	[SerializeField]
	private Material material;

	[SerializeField]
	private float pauseDuration;

	[SerializeField]
	private float periodDuration;

	private float time;

	private void Start()
	{
		EnableMaterial();
	}

	private void Update()
	{
		time += Time.deltaTime;

		material.SetFloat("_Period", periodDuration);
		material.SetFloat("_Pause", pauseDuration);
		material.SetFloat("_BaseTime", time);
	}

	private void EnableMaterial()
	{
		material.SetFloat("_Intensity", 1.0f);
		material.SetFloat("_BaseTime", 0.0f);
		time = 0.0f;

		Invoke("DisableMaterial", periodDuration);
	}

	private void DisableMaterial()
	{
		material.SetFloat("_Intensity", 0.0f);
		Invoke("EnableMaterial", pauseDuration);
	}

}
