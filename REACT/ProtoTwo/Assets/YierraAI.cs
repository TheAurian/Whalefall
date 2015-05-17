using UnityEngine;
using System.Collections;

public class YierraAI : ActorController 
{


    public Rigidbody toroa;
    
    private Transform player;
    public float Distance = 5;
    public float Speed;


    void Awake()
    {
        player = GameObject.FindGameObjectWithTag("Player").transform;

    }

    void Start()
    {

    }

    void Update()
    {
        if (Vector3.Distance(player.position, transform.position) > Distance)
        {
            //look at player
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(player.position - transform.position), Time.deltaTime * Speed);
            
            
            
            //go to player
            transform.position = Vector3.MoveTowards(transform.position, player.position, Time.deltaTime * Speed);
        }else
        {
            Debug.Log("I have reached Toroa");
        }
    }
}
