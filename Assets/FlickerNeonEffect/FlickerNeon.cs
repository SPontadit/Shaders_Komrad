using UnityEngine;
using System.Collections.Generic;

// Written by Steve Streeting 2017
// License: CC0 Public Domain http://creativecommons.org/publicdomain/zero/1.0/

/// <summary>
/// Component which will flicker a linked light while active by changing its
/// intensity between the min and max values given. The flickering can be
/// sharp or smoothed depending on the value of the smoothing parameter.
///
/// Just activate / deactivate this component as usual to pause / resume flicker
/// </summary>
public class FlickerNeon : MonoBehaviour
{
	public Material material;
	[Tooltip("Minimum random light intensity")]
	public float minIntensity = 0f;
	[Tooltip("Maximum random light intensity")]
	public float maxIntensity = 1f;
	[Tooltip("How much to smooth out the randomness; lower values = sparks, higher = lantern")]
	[Range(1, 50)]
	public int smoothing = 5;

	// Continuous average calculation via FIFO queue
	// Saves us iterating every time we update, we just change by the delta
	Queue<float> smoothQueue;
	float lastSum = 0;

	public Vector2 colorRange;
	public Vector2 timeRangeBetweenChangeColor;
	private float timeStamp;

	public float lerpTime;
	bool isLerping = false;
	Color start;
	Color end;

	Color lastColor = Color.white;

	public void Reset()
	{
		smoothQueue.Clear();
		lastSum = 0;
	}

	void Start()
	{
		smoothQueue = new Queue<float>(smoothing);

		Invoke("GetRandomColor", Random.Range(timeRangeBetweenChangeColor.x, timeRangeBetweenChangeColor.y));
	}

	private void GetRandomColor()
	{
		isLerping = true;
		timeStamp = Time.time;

		float min = colorRange.x / 255f;
		float max = colorRange.y / 255f;
		float r = Random.Range(min, max);
		float g = Random.Range(min, max);
		float b = Random.Range(min, max);
		float a = 1f;

		start = lastColor;
		end = new Color(r, g, b, a);

		Invoke("GetRandomColor", Random.Range(timeRangeBetweenChangeColor.x, timeRangeBetweenChangeColor.y));
	}

	void Update()
	{
		if (material == null)
			return;

		if (isLerping)
		{
			float time = Time.time - timeStamp;
			float percent = time / lerpTime;

			Color color = Color.Lerp(start, end, percent);

			material.SetColor("_Color", color);

			if (percent >= 1f)
			{
				isLerping = false;
				lastColor = color;
			}

		}

		// pop off an item if too big
		while (smoothQueue.Count >= smoothing)
		{
			lastSum -= smoothQueue.Dequeue();
		}

		// Generate random new item, calculate new average
		float newVal = Random.Range(minIntensity, maxIntensity);
		smoothQueue.Enqueue(newVal);
		lastSum += newVal;

		// Calculate new smoothed average
		material.SetFloat("_Intensity", lastSum / (float)smoothQueue.Count);
	}

}