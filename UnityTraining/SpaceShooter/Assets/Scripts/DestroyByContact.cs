using UnityEngine;
using System.Collections;

public class DestroyByContact : MonoBehaviour {

    public GameObject asteroidExplosion;
    public GameObject playerExplosion;
    public int scoreValue;

    private GameController gameController;

    void Start()
    {
        GameObject gameControllerObject = GameObject.FindWithTag("GameController");
        if (!gameControllerObject.Equals(null))
        {
            gameController = gameControllerObject.GetComponent<GameController>();
        }
        else
        {
            Debug.Log("Could not locate Game Controller");
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.tag.Equals("Boundary"))
        {
            return;
        }
     
        Instantiate(asteroidExplosion, transform.position, transform.rotation);          
        
        if (other.tag.Equals("Player"))
        {
            Instantiate(playerExplosion, other.transform.position, other.transform.rotation);
            gameController.GameOver();
            
        }
        gameController.AddScore(scoreValue);
        Destroy(other.gameObject);
        Destroy(gameObject);
    }

}
