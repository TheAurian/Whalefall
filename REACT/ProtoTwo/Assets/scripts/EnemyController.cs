using UnityEngine;
using System.Collections;

public class EnemyController : ActorController
{

    public Transform spawnLocation;
    public float attackRate;

    Vector3 currentDirection;
    public Transform player;
    Vector3 movement; //Vector to store direction of player's movement
    NavMeshAgent navMesh;
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
        navMesh = GetComponent<NavMeshAgent>();
    }

	// Use this for initialization
	void Start () {
        //player = GameObject.FindGameObjectWithTag("Player").transform;

	}
	
	// Update is called once per frame
	void Update () {
        this.Move();
	}

    void FixedUpdate()
    {
        ///check for colision
        ///if colision is player weapon
    }

    void Move(){
        //transform.position = Vector3.Lerp(transform.position, )
        navMesh.SetDestination(player.position);
    }

    void Turn()
    {

    }

}
