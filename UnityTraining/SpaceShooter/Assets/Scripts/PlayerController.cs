using UnityEngine;
using UnityEditor;
using System.Collections;

[System.Serializable]
public class Boundary
{
    public float xMin, xMax, zMin, zMax;

}

public class PlayerController : MonoBehaviour {

    public float speed;
    public float tilt;
    public Boundary boundary;
	public GameObject shot;
	public Transform shotSpawn;

	public float fireRate = 0.5F;
	private float nextFire = 0.0F;

	void Update(){

		if (Input.GetButton("Fire1") && Time.time > nextFire) {
			nextFire = Time.time + fireRate;
			Instantiate(shot, shotSpawn.position, shotSpawn.rotation);
		}
	}

    void FixedUpdate(){
        float moveHorizontal = Input.GetAxis("Horizontal");
        float moveVertical = Input.GetAxis("Vertical");

        Vector3 movement =  new Vector3(moveHorizontal, 0.0f, moveVertical);

        Rigidbody playerRB = GetComponent<Rigidbody>();

        playerRB.velocity = movement * speed;

        playerRB.position = new Vector3
            (
                Mathf.Clamp(playerRB.position.x, boundary.xMin, boundary.xMax), 
                0.0f,
                Mathf.Clamp(playerRB.position.z, boundary.zMin, boundary.zMax)
            );

        playerRB.rotation = Quaternion.Euler(0.0f, 0.0f, playerRB.velocity.x * -tilt);
    }


}


