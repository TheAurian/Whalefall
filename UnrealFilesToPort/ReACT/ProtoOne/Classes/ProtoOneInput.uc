//  ================================================================================================
//   * File Name:    ProtoOneInput
//   * Created By:   Byron
//   * Time Stamp:     1/30/2014 12:17:50 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class ProtoOneInput extends PlayerInput within ProtoOnePlayerController
config(ProtoOneInput);
var Input       float aTargetSwitch;
var bool        bGameInfoGot, bCanSwitch;

var ProtoOneGame myGameInfo;


event PlayerInput(float DeltaTime)
{
    local bool      bSwitchRight;
    
    super.PlayerInput(DeltaTime);

    // `log("PlayerInput being called!!! aTurn == "$aBaseX);

    if (aTargetSwitch >= 0.9 && bCanSwitch == true)
    {
        
        bSwitchRight = true;
        myGameInfo.tierra.SwitchTarget(bSwitchRight);
        bCanSwitch = false;
        //`log("Switch TARGET to nearest RIGHT");
        //aTargetSwitch = 0;
    }
    else if (aTargetSwitch <= -0.9 && bCanSwitch == true)
    {
        
        bSwitchRight = false;
        myGameInfo.tierra.SwitchTarget(bSwitchRight);
        bCanSwitch = false;
        //`log("Switch TARGET to nearest LEFT");  
        //aTargetSwitch = 0;
    }
    else if (aTargetSwitch <= 0.2 && aTargetSwitch >= -0.2 && bCanSwitch == false)
    {
        bCanSwitch = true;
    }
    
    if (bGameInfoGot == false)
    {
       myGameInfo = ProtoOneGame(WorldInfo.game);
      
       bGameInfoGot = true;
    }
}

defaultproperties
{
    bGameInfoGot=false
    //bCanSwitch=true
}