using UnityEngine;
using System.Collections;

public class InputController : MonoBehaviour {


    public bool bUsingGamepad;
	// Use this for initialization

    
	void Awake () {
        if (bUsingGamepad)
        {
            Debug.Log("Gamepad is being used...");
        }
        else
        {
            Debug.Log("Keyboard is being used...");
        }

	}

    public float GetMove_Horizontal()
    {
        if (bUsingGamepad)
        {
            return Input.GetAxisRaw("L_XAxis_1");
        }
        else
        {
            return Input.GetAxisRaw("KB_Horizontal");
        }
    }

    public float GetMove_Vertical()
    {
        if (bUsingGamepad)
        {
            return Input.GetAxisRaw("L_YAxis_1");
        }
        else
        {
            return Input.GetAxisRaw("KB_Vertical");
        }
    }

    public bool GetSweep_R()
    {
        if (bUsingGamepad)
        {
            return Input.GetButton("B_1");
        }
        else
        {
            return Input.GetButton("KB_Sweep_R");
        }
    }

    public bool GetSweep_L()
    {
        if (bUsingGamepad)
        {
            return Input.GetButton("X_1");
        }
        else
        {
            return Input.GetButton("KB_Sweep_L");
        }
    }

    public bool GetStab()
    {
        if (bUsingGamepad)
        {
            return Input.GetButton("Y_1");
        }
        else
        {
            return Input.GetButton("KB_Stab");
        }
    }

    /// <summary>
    /// Only account for
    /// </summary>
    /// <returns></returns>
    public float GetSwitchTierraTargetButton()
    {
        if (bUsingGamepad)
        {
            return Input.GetAxisRaw("R_XAxis_1");
        }
        else
        {
            return Input.GetAxisRaw("KB_Horizontal");
        }
    }

    public bool GetEvadeButton()
    {
        //A button
        //
        if (bUsingGamepad)
        {
            return Input.GetButton("Y_1");
        }
        else
        {
            return Input.GetButton("KB_Stab");
        }
    }

    public void GetREACTButton()
    {
        //left trigger
        //
    }

    public void GetFireArrowButton()
    {
        //right trigger
        //
    }

    public void GetUseItemButton()
    {
        //D-Pad Up
        //
    }

    public void GetCommandButton_Follow()
    {
        //dpad down
        //
    }

    public void GetCommandButton_1()
    {
        //dpad right
        //
    }

    public void GetCommandButton_2()
    {
        //dpad left
    }

    public void GetScrollButton_SpearTips()
    {
        //right bumper
        //
    }

    public void GetScrollButton_ArrowHeads()
    {
        //left bumper
        //
    }

    public void GetMenuSelectButton()
    {

    }

    public void GetStartButton()
    {
        //start button
        //esc key
    }
}
