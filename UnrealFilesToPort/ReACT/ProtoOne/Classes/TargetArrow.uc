class TargetArrow extends Actor;

var bool bIsSet;
var Actor theTarget;

event PostBeginPlay()
{
    
    local vector down;
    local rotator newRotation;
    
 
    down = vect(0,0,-1);
    newRotation = Rotator(down);
    SetRotation(newRotation);
    
    super.PostBeginPlay();
}

function SetTarget(Actor targeted)
{
    SetLocation(targeted.location + vect(0,0,150));
    
    SetBase(targeted);
    
    bIsSet = true;
    
    theTarget = targeted;
    

    
}
/*
simulated event Tick(float DeltaTime)
{
    
    if(theTarget.IsInState('Dying'))
    {
        
        bIsSet = false;
    }

}
*/

defaultproperties
{
    /*
     Begin Object Class=ArrowComponent Name=Arrow
        ArrowColor=(B=0,G=0,R=200,A=255)//A=255
        ArrowSize=1.0
        //   HiddenGame=false (this causes the compiler to crash...)
     End Object
     
     Components.Add(Arrow)
     //Components(0) = Arrow
    */
     begin object Class=SpriteComponent Name=Sprite
        Sprite=S_Actor
        HiddenGame=false
    end object
    Components.Add(Sprite)
    bHardAttach=true
    
    bIsSet=false
}
