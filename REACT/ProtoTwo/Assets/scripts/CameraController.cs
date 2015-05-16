using UnityEngine;
using System.Collections;


public class CameraController : ActorController 
{
	public Transform player;            // The position that that camera will be following.
	public float smoothing = 5f;        // The speed with which the camera will be following.

    Vector3 initPosition;
	Vector3 offset;                     // The initial offset from the player.
    Vector3 currentDirection;
    void Awake()
    {
        initPosition = player.position;
        initPosition.x -= 4;
        initPosition.y += 8;
        initPosition.z -= 16;
        transform.localPosition = initPosition;
    }

	void Start ()
	{

		// Calculate the initial offset.
		offset = transform.position - player.position;
	}
		
	void FixedUpdate ()
	{
        // Create a postion the camera is aiming for based on the offset from the player.
        Vector3 targetCamPos = player.position + offset;

        // Smoothly interpolate between the camera's current position and it's player position.
        transform.position = Vector3.Lerp(transform.position, targetCamPos, smoothing * Time.deltaTime);


	}

    void Turn()
    {
        //turn camera to look at player
        currentDirection.Set(0, -offset.y, -offset.z);
        Quaternion targetRotation = Quaternion.LookRotation(currentDirection);

        //turn camera ta face direction,and don't overshoot when on slow machines
        //
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, Mathf.Min(6 * Time.deltaTime, 1));
    }

}
