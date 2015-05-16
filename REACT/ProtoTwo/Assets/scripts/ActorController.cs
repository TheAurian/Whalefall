using UnityEngine;
using System.Collections;

public class ActorController : MonoBehaviour
{

    protected float currentHealth;
    public float initialHealth;
    protected bool bIsDead;

    //Actor Components
    protected CapsuleCollider collider;
    protected Animator anim;
    protected Rigidbody thisRigidBody;

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    protected void Kill()
    {
        bIsDead = true;

        collider.isTrigger = true;
    }

    public void TakeDamage(int hitDamage)
    {
        if (bIsDead)
        {
            return;
        }

        currentHealth -= hitDamage;

        if (currentHealth <= 0)
        {
            Kill();
        }
    }
}
