using UnityEngine;
using System.Collections;

public class Mover : MonoBehaviour {

	public float speed;

	void Start(){
		Rigidbody boltRigidBody = GetComponent<Rigidbody>();
		boltRigidBody.velocity = transform.forward * speed; 
	}
}
