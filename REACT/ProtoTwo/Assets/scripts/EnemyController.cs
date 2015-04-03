using UnityEngine;
using System.Collections;

public class EnemyController : MonoBehaviour {

    public Transform spawnLocation;
    public float attackRate;

    Vector3 currentDirection;
    Rigidbody enemyRigidBody;
    Vector3 movement; //Vector to store direction of player's movement
    public float speed; //speed that player will move at
    Animator anim;
    float turnSpeed;
    bool bIsDead;
    float attackTimer;


    void Awake()
    {
        //get player character components
        enemyRigidBody = GetComponent<Rigidbody>();
        //speed = 6f;
        turnSpeed = 20f;
        bIsDead = false;
        anim = GetComponent<Animator>();
        attackTimer = 0;
    }

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

    void Move(){

    }

    void Turn()
    {

    }
}
