using UnityEngine;
using System.Collections;

public class PlayerController : ActorController {

    public Transform spawnLocation;
    public float attackRate;

    Vector3 currentDirection;
    Vector3 movement; //Vector to store direction of player's movement
    public float speed; //speed that player will move at
    float turnSpeed;
    float attackTimer;
    InputController input;


    void Awake()
    {
        //get player character components
        thisRigidBody = GetComponent<Rigidbody>();
        //speed = 6f;
        turnSpeed = 20f;
        bIsDead = false;
        anim = GetComponent<Animator>();
        attackTimer = 0;
        input = GetComponent<InputController>();
    }

    void Start()
    {
        Transform transform = GetComponent<Transform>();
        transform.position = spawnLocation.position;
    }

    void Update()
    {

    }



    void FixedUpdate()
    {
        //get movement values
        float h = input.GetMove_Horizontal();
        float v = input.GetMove_Vertical();

        //Move character in direction
        Move(h, v);



        //only turn to face input axes when moving, otherwise stay facing current direction
        if (h == 0 && v == 0)
        {}
        else
        {
            //Turn character in direction
            Turn(h, v);
        }

        //player attacks with a rate
        attackTimer += Time.deltaTime;

        if (input.GetSweep_R() && attackTimer >= attackRate)
        {
            Debug.Log("Toroa sweeping right!");
            anim.SetTrigger("tSweepRight");
            attackTimer = 0;
            EnemyController enemyHealth = collider.GetComponent<EnemyController>();
            if (enemyHealth != null)
            {
                enemyHealth.TakeDamage(20);
            }
        }
        else if (input.GetStab() && attackTimer >= attackRate)
        {
            Debug.Log("Toroa stabbing!");
            anim.SetTrigger("tStab");
            attackTimer = 0;
        }
        else if (input.GetSweep_L())
        {
            anim.SetBool("bInFightStance", true);
        }

    }

    void LateUpdate()
    {
    }

    void Move(float h, float v)
    {
        //set movement vector based on input axis
        movement.Set(h, 0f, v);

        movement = movement.normalized * speed * Time.deltaTime;

        //add movment vector to current position
        thisRigidBody.MovePosition(transform.position + movement);

    }

    //TODO: use coroutine to finish rotation?
    void Turn(float h, float v)
    {
        currentDirection.Set(h, 0f, v);
        Quaternion targetRotation = Quaternion.LookRotation(currentDirection);

        //turn rigidbody ta face direction,and don't overshoot when on slow machines
        thisRigidBody.MoveRotation(Quaternion.Lerp(thisRigidBody.rotation, targetRotation, Mathf.Min(turnSpeed * Time.deltaTime, 1)));
    }

    void Attack()
    {
        Debug.Log("Toroa has attacked!");
        anim.SetTrigger("tSweepRight");
    }

}