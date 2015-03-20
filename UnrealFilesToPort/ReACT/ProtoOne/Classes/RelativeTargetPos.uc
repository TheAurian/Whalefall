//  ================================================================================================
//   * File Name:    RelativeTargetPos
//   * Created By:   Byron
//   * Time Stamp:     2/5/2014 12:55:13 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class RelativeTargetPos extends Actor;

var actor theTarget;
var vector newPos, targetDist, debugLineDist;
var float targetX;
var bool bNewTarget, bSetLine;

simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);
    //`log("Relative Target Pos ROTATION = "$Rotation);
    SetLocation(theTarget.location);//Is this bad for perfomance???
    //SetRotation(rotator(vect(0,1,0)));
}

function SetPosition(actor target)
{
    //SetLocation(target.location); 
    //SetBase(target);
       
    theTarget = target;
    bSetLine = false;
    /*
    bNewTarget = true;
    theTarget = target;
    targetDist = location - target.location;
    targetX = location.X + targetDist.x;
    newPos.x = targetX;
    newPos.y = location.y;
    newPos.z = location.z;
    SetRelativeLocation(newPos);
    bNewTarget = false;
    */
}

defaultproperties
{
    begin object Class=SpriteComponent Name=Sprite
        Sprite=S_Actor
        HiddenGame=false
    end object
    //Components.Add(Sprite)
    bHardAttach=true
    bSetLine=false  
}