using UnityEngine;
using System.Collections;

public class Rotator : MonoBehaviour {

	// Update is called once per frame
    //not using forces, so can use update
	void Update () 
    {
		transform.Rotate(new Vector3(15,30,45) * Time.deltaTime);
	}
}
