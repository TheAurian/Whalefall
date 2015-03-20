//  ================================================================================================
//   * File Name:    TierrasCombatPos
//   * Created By:   Byron
//   * Time Stamp:     1/3/2014 12:35:13 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class TierrasCombatPos extends Actor;

var actor      theCamera;
var vector      leftPos, rightPos, currentPos, basePos;
var bool        bSetPos;

event PostBeginPlay()
{
    local ProtoOneGame myGameInfo;    
    
    super.PostBeginPlay(); 
    
    //SetTimer(3, true);

    myGameInfo = ProtoOneGame(WorldInfo.game);
    
    if(myGameInfo != None)
    {
        theCamera = myGameInfo.mainCamera;
    }
    

}

function Timer()
{
    `log("Tierra's CombatPos is: "$location); 
}

function SetCombatPos()
{

    
    if(theCamera != none)
    {
        if(currentPos == leftPos)
        {

            SetRelativeLocation(vect(-200,-300,0));
         
             currentPos = rightPos;
    
             //SetBase(theCamera);   
        
             bSetPos = true;      
        }
        else
        {
           SetRelativeLocation(vect(-200,300,0));
         
             currentPos = leftPos;
    
             //SetBase(theCamera);   
        
             bSetPos = true;      
            
        }
    }
   
}


defaultproperties
{
    begin object Class=SpriteComponent Name=Sprite
        Sprite=S_Actor
        HiddenGame=false
    end object
    // Components.Add(Sprite)
    bHardAttach=true;
    bSetPos=false
    
   
    
}