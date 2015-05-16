using UnityEngine;
using System.Collections;

public class EnemyController : ActorController
{

    public Transform spawnLocation;
    public float attackRate;

    Vector3 currentDirection;
    Vector3 movement; //Vector to store direction of player's movement
    public float speed; //speed that player will move at
    float turnSpeed;
    float attackTimer;


    void Awake()
    {
        //get player character components
        thisRigidBody = GetComponent<Rigidbody>();
        collider = GetComponent<CapsuleCollider>();
        //speed = 6f;
        turnSpeed = 20f;
        bIsDead = false;
        anim = GetComponent<Animator>();
        attackTimer = 0;
        currentHealth = initialHealth;
    }

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	    
	}

    void FixedUpdate()
    {
        ///check for colision
        ///if colision is player weapon
    }

    void Move(){

    }

    void Turn()
    {

    }

}
