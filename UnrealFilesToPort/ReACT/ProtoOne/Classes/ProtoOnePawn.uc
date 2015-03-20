class ProtoOnePawn extends UTPawn;

/*
var float CamOffsetDistance; //distance to offset the camera from the player
var float CamMagnitudeLimit;
var float CamLeach;
var float CamSpeedMod;
*/


// Evading vars
var float DodgeDuration;
var bool bEvading;// true when the pawn is evading
var vector EvadeVelocity;
var bool bCanEvade;

//REACT vars
var float ReactCurTime;
var float ReactTotTime;
var bool hasEnteredREACT;
var float TimeDilationMagnitude;

var int totalForce;
var float maxStabForce;
var float chargeTime;
var float spearDist;
var float stabDmg;
var float sweepDmg;
var bool bChargingAttack;
var float chargingGroundSpeed;
var bool bArrowShot;

var rotator DesiredRot;

var ProtoOneGame myGameInfo;
/*
var int IsoCamAngle; //pitch angle of the camera
var int IsoCamYaw; //place in camrot.yaw for new view
var bool bFollowPlayer;
var vector CamOrigin;
*/
//override to make player mesh visible by default
simulated event BecomeViewTarget( PlayerController PC )
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         SetMeshVisibility(UTPC.bBehindView); 
         UTPC.bNoCrosshair = true;
      }
   }
}

simulated event PostBeginPlay()
{
     myGameInfo = ProtoOneGame(WorldInfo.game);   
}

  
Simulated Event Tick(float DeltaTime)
{   
    Super.Tick(DeltaTime);
    
    //if(bEvading)
    //{
        //    DoEvade();
    //}
    
    if(bChargingAttack)
    {
        totalForce = ChargeForce(DeltaTime);
    }
    
    if(hasEnteredREACT){
        DoREACT(DeltaTime);
    }

}

//////////////////////////Pawn Rotation\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
    GetRotation();//Rotates the pawn to face its velocity

    // Do not update Pawn's rotation depending on controller's ViewRotation if in FreeCam.
    if (!InFreeCam())
    {
        if ( Physics == PHYS_Ladder )//is player on a ladder?
        {
            NewRotation = OnLadder.Walldir;
        }
        else if ( (Physics == PHYS_Walking) || (Physics == PHYS_Falling) )//is the player walking or falling?
        {
            NewRotation = DesiredRot;
        }

        SetRotation(NewRotation);
        
    }
}

function GetRotation()
{
    local vector Velo;//create a vector for the pawns velocity


    Velo = Velocity;//Stores the pawns velocity
    
    if(IsZero(Velocity) || Velocity.Z != 0)//Is the player stationary or moving up/down?
    {
        //Keep the pawns current rotation
    }
    else//Player is Moving
    {                                         
        DesiredRot.Pitch = 0;
        Normal(Velo);//Normalize Vector
        DesiredRot = Rotator(Velo);//Convert the Vector into a rotation
    }
}

/////////////////////////Evade\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

/*
    TOFIX: Does not properly track the last direction the player was in to evade 
    TODO: 1. Modify to evade in direction of 
          2. Set a timer to restrict the time between dodging
*/
exec function bool DoEvade()
{  
    local name EvadeDir;
    `log("Do Evade has been successfully called!");
     
    if( bCanEvade && Physics == Phys_Walking )
    {
        //temporarily raise speeds
        AirSpeed = DodgeSpeed;
        GroundSpeed = DodgeSpeed;
        bEvading = true;
        Velocity.Z = -default.GroundSpeed;
        EvadeVelocity.z = 0.0;
        
        EvadeDir = DoEvadeHelper();
        
        switch ( EvadeDir )
        {
            case 'LEFT':
                `log("Evade Left!");
                `log("EvadeVelocity is: " $EvadeVelocity);
                 EvadeVelocity.x = 0.0;
                 EvadeVelocity.y = -1200.0;
            break;
            
            case 'UP':
                `log("Evade Up!");
                 `log("EvadeVelocity is: " $EvadeVelocity);
                 EvadeVelocity.x = 1200.0;
                 EvadeVelocity.y = 0.0;
             break;
             
            case 'RIGHT':
                `log("Evade Right!");
                `log("Evade Velocity is: " $EvadeVelocity);
                 EvadeVelocity.x = 0.0;
                 EvadeVelocity.y = 1200.0;
                 
            break;
            
            case 'DOWN':
                `log("Evade Down!");
                 `log("EvadeVelocity is: " $EvadeVelocity);
                 EvadeVelocity.x = -1200.0;
                 EvadeVelocity.y = 0.0;
            break;
                
            case '':
                `log("Evade SameDirection!");
                //sEvadeVelocity = DesiredRot;
                break;
                
            default:
                `log("Evade Error Occured!");
                break;
        }
        
        Velocity = EvadeVelocity;
        SetPhysics(Phys_Flying); //gives the right physics
        bCanEvade = false; //prevent dodging mid dodge
        PlayerController(Controller).IgnoreMoveInput(true); //prevent the player from controlling pawn direction
        PlayerController(Controller).IgnoreLookInput(true); //prevent the player from controlling rotation
        SetTimer(DodgeDuration,false,'EndEvade'); //time until the dodge is done, then call UnEvade
        return true;
    }
    else
    {
        return false;
    }

}
/*
    / Returns direction to evade in; Aids DoEvade function
/ TODO: Need to detect when no direction is intended
*/
function name DoEvadeHelper()
{
    local PlayerController PC;
    local name EvadeDir; //holds direction to evade in
    
    PC = GetALocalPlayerController();
    
    //Checking for what direction to evade in
    if(PC.PlayerInput.PressedKeys.Find('A') >= 0)
    {
        EvadeDir = 'LEFT';
    }
    else if(PC.PlayerInput.PressedKeys.Find('W') >= 0)
    {
        EvadeDir = 'UP';
    }
    else if(PC.PlayerInput.PressedKeys.Find('D') >= 0)
    {
        EvadeDir = 'RIGHT';
    }
    else if(PC.PlayerInput.PressedKeys.Find('S') >= 0)
    {
        EvadeDir = 'DOWN';
    }
    else
    {
        EvadeDir = 'FACE';//no direction input pressed, so dodge in direction player is currently facing
    }

    return EvadeDir;

}

/*
/ Will allow evading down stairs, edge detection, colission detection, etc.
*/
function Evading()
{
    local vector TraceStart;
    local vector TraceEnd1, TraceEnd2, TraceEnd3;   


    if( bEvading )
    {
        //all traces start slightly offset from center of pawn
        TraceStart = Location + 20*Normal(EvadeVelocity);

        //trace location for detecting objects just below pawn
        TraceEnd1 = TraceStart;
        TraceEnd1.Z -= 55;

        //trace location for detecting objects below pawn that are close
        TraceEnd2 = TraceStart;
        TraceEnd2.Z -= 120;

        //trace locations for detecting when pawn will fall off a ledge
        TraceEnd3 = TraceStart;
        TraceEnd3.Z -= 121;     

        if( FastTrace(TraceEnd1, TraceStart) && !FastTrace(TraceEnd2, TraceStart) ) //nothing is directly underneath the pawn and something is sort of underneath the pawn
        {
            Velocity.Z = -default.DodgeSpeed; //push pawn down
        }
        
        if( FastTrace(TraceEnd3, TraceStart) ) //pawn is about to fall off a ledge
        {
            EndEvade();
        }
        else
        {
            //maintain a constant velocity
            Velocity.X = EvadeVelocity.X;
            Velocity.Y = EvadeVelocity.Y;
        }
    }
}

function EndEvade()
{
    local vector IdealVelocity;

    SetPhysics(Phys_Falling); //use falling instead of walking in case we are mid-air after the dodge
    bCanEvade = true;
    bEvading = false;
    PlayerController(Controller).IgnoreMoveInput(false);
    PlayerController(Controller).IgnoreLookInput(false);
    GroundSpeed = default.GroundSpeed;
    AirSpeed = default.AirSpeed;

    //reset the velocity of pawn
    IdealVelocity = normal(EvadeVelocity)*default.GroundSpeed;
    Velocity.X = IdealVelocity.X;
    Velocity.Y = IdealVelocity.Y;
   
}
   
  /////////////////////////REACT\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 exec function REACT()
  {  
    `log("exec REACT funct called");    
    hasEnteredREACT = true; 
    WorldInfo.TimeDilation *= TimeDilationMagnitude;  //TimeDilationMagnitued is < 1, so slows world down
    CustomTimeDilation = (1 / TimeDilationMagnitude) - 0.2; //CustomTimeDilation is given the reciprocal of WorldInfo.TimeDilation to stay at normal speed
  }
  
  
function DoREACT(float DeltaTime)
  { 
    
    ReactCurTime +=  (1 * DeltaTime) / 0.6; //calculates next millisecond
    //`log("Time in REACT = " $ReactCurTime);

    if(ReactCurTime >= ReactTotTime){ //REACTIME has been on for 3 second
        EndREACT();
    }
 
  }
  
  //Returns all modified values back to regular game-state values
  function EndREACT()
  {
    `log("CustomTimeDilation =" $CustomTimeDilation);
    `log("WorldInfo.TimeDilation = " $WorldInfo.TimeDilation);
    
    //return player and world speed to normal
    WorldInfo.TimeDilation = 1.0;
    CustomTimeDilation = 1.0;
    
    //reset react vars for next usage
    ReactCurTime = 0.0;
    hasEnteredREACT = false;
    
    `log("End REACT");
  }
  
  
////////////////////////////Stab\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
exec function ChargeStab()
{
    if(bEvading == false)
    {
        bChargingAttack = true;
    }
        
}

exec function Stab()
{
    local vector        stabRange, hitLoc, hitNorm, vHitMomentum;
    local TraceHitInfo  hitInfo;
    local Actor     traceHit;
    local float     fDamagePercent, fDamageGiven, fDamageMomentum;
    local ProtoOneEnemy     HitEnemy;
    //local ProtoOneEnemy hitEnemy;
    //local ProtoOneBot hitAI;
    
    GroundSpeed = 600;
    
    stabRange = Location + Normal(Vector(Rotation)) * spearDist;
    //stabRange.Z = 3;
    bChargingAttack = false;
    
    traceHit = Trace(hitLoc, hitNorm, stabRange, Location,,vect(30,150,30),hitInfo);
    DrawDebugLine( Location, stabRange, 0, 255, 0, FALSE );
    //DrawDebugLine( Location, hitLoc, 255, 0, 0, TRUE );
    
    if(totalForce < 13)//Did the player tap the stab button?
    {
        `log("Quick Stab!");
    }
    else//Otherwise they're charging the stab
    {
        `log("Charged Stab for " $totalForce);
        //if(totalForce == 100)
        // `log("Charged Stab with Maximum Force!!!!");
    }
    chargeTime = 0;
    if(traceHit == none)
    {
        `log("Stab was a miss");
    }
    else
    {
        //`log("Stab hit a: " $traceHit$" class: "$traceHit.class);
        //`log("Hit Location: "$hitLoc.X$","$hitLoc.Y$","$hitLoc.Z);
        //`log("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
        //`log("Component: "$hitInfo.HitComponent);
        
        if(traceHit.IsA('ProtoOneEnemy'))
        {
            HitEnemy = ProtoOneEnemy(traceHit);
            fDamageGiven = HitEnemy.MaxHealth - HitEnemy.Health;//Get the amount of damage that has been done
            fDamagePercent = (fDamageGiven / HitEnemy.MaxHealth) * 100; //Make that a percent
            fDamageMomentum = (totalForce * 1000) + (fDamagePercent * 100);//Total momentum from damage and charge force
            
            vHitMomentum = traceHit.Location - Location;//Get trajectory
            vHitMomentum = fDamageMomentum  * Normal(vHitMomentum);//Apply the full momentum
            
            stabDmg += totalForce * 0.1;//Modify damage by the charge force
            if(stabDmg >= 10)
            {
                stabDmg = 10;//Cap the damage
            }
            
            //tell the bot to take damage and send itself flying
            traceHit.TakeDamage(stabDmg, Controller(traceHit), hitLoc, vHitMomentum, class'UTDmgType_Rocket');
            stabDmg = 1; // set damage back to default
        }
        
    }

}


//////////////////////////// Left Sweep \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
exec function ChargeLeftSweep()
{
    if(bEvading == false)
    {
        bChargingAttack = true;
    }
        
}

exec function LeftSweep()
{
    local vector        sweepRange, hitLoc, hitNorm, vHitMomentum, sweepOrigin;
    local TraceHitInfo  hitInfo;
    local Actor     traceHit;
    local Rotator   RotLeft;
    local float     fDamagePercent, fDamageGiven, fDamageMomentum;
    local ProtoOneEnemy     HitEnemy;
    //local ProtoOneEnemy hitEnemy;
    //local ProtoOneBot hitAI;
    
    GroundSpeed = 600;
    
    sweepRange = Location + Normal(Vector(Rotation)) * spearDist;
    RotLeft.Pitch = Rotation.Pitch;
    RotLeft.Yaw = Rotation.Yaw - (90 * DegToUnrRot);
    RotLeft.Roll = Rotation.Roll;
    sweepOrigin = Location + Normal(Vector(RotLeft)) * spearDist;
    //stabRange.Z = 3;
    bChargingAttack = false;
    
    traceHit = Trace(hitLoc, hitNorm, sweepRange, sweepOrigin,,vect(150,150,30),hitInfo);
    DrawDebugLine( sweepOrigin, sweepRange, 0, 255, 0, FALSE );

  
    if(totalForce < 13)//Did the player tap the stab button?
    {
        `log("Quick LeftSweep!");
    }
    else//Otherwise they're charging the stab
    {
        `log("Charged LeftSweep for " $totalForce);
        // if(totalForce == 100)
        //`log("Charged LeftSweep with Maximum Force!!!!");
    }
    chargeTime = 0;
    if(traceHit == none)
    {
        `log("LeftSweep was a miss");
    }
    else
    {
        //`log("LeftSweep hit a: " $traceHit$" class: "$traceHit.class);
        // `log("Hit Location: "$hitLoc.X$","$hitLoc.Y$","$hitLoc.Z);
        //`log("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
        //`log("Component: "$hitInfo.HitComponent);
        
        if(traceHit.IsA('ProtoOneEnemy'))
        {
            HitEnemy = ProtoOneEnemy(traceHit);
            fDamageGiven = HitEnemy.MaxHealth - HitEnemy.Health;//Get the amount of damage that has been done
            fDamagePercent = (fDamageGiven / HitEnemy.MaxHealth) * 100; //Make that a percent
            fDamageMomentum = (totalForce * 1000) + (fDamagePercent * 100);//Total momentum from damage and charge force
            
            vHitMomentum = traceHit.Location - sweepOrigin;//Get trajectory
            vHitMomentum = fDamageMomentum  * Normal(vHitMomentum);//Apply the full momentum
            
            sweepDmg += totalForce * 0.1;//Modify damage by the charge force
            if(sweepDmg >= 10)
            {
                sweepDmg = 10;//Cap the damage
            }
            
            //tell the bot to take damage and send itself flying
            traceHit.TakeDamage(sweepDmg, Controller(traceHit), hitLoc, vHitMomentum, class'UTDmgType_Rocket');
            sweepDmg = 1; // set damage back to default
        }
        
    }

}

//////////////////////////// Right Sweep \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
exec function ChargeRightSweep()
{
    if(bEvading == false)
    {
        bChargingAttack = true;
    }
        
}

exec function RightSweep()
{
    local vector        sweepRange, hitLoc, hitNorm, vHitMomentum, sweepOrigin;
    local TraceHitInfo  hitInfo;
    local Actor     traceHit;
    local Rotator   RotRight;
    local float     fDamagePercent, fDamageGiven, fDamageMomentum;
    local ProtoOneEnemy     HitEnemy;
    //local ProtoOneEnemy hitEnemy;
    //local ProtoOneBot hitAI;
    
    GroundSpeed = 600;
    
    sweepRange = Location + Normal(Vector(Rotation)) * spearDist;
    RotRight.Pitch = Rotation.Pitch;
    RotRight.Yaw = Rotation.Yaw + (90 * DegToUnrRot);
    RotRight.Roll = Rotation.Roll;
    sweepOrigin = Location + Normal(Vector(RotRight)) * spearDist;
    //stabRange.Z = 3;
    bChargingAttack = false;
    
    traceHit = Trace(hitLoc, hitNorm, sweepRange, sweepOrigin,,vect(150,150,30),hitInfo);
    DrawDebugLine( sweepOrigin, sweepRange, 0, 255, 0, FALSE );

  
    if(totalForce < 13)//Did the player tap the stab button?
    {
        `log("Quick LeftSweep!");
    }
    else//Otherwise they're charging the stab
    {
        `log("Charged LeftSweep for " $totalForce);
        // if(totalForce == 100)
        //`log("Charged LeftSweep with Maximum Force!!!!");
    }
    chargeTime = 0;
    if(traceHit == none)
    {
        `log("LeftSweep was a miss");
    }
    else
    {
        `log("LeftSweep hit a: " $traceHit$" class: "$traceHit.class);
        `log("Hit Location: "$hitLoc.X$","$hitLoc.Y$","$hitLoc.Z);
        `log("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
        `log("Component: "$hitInfo.HitComponent);
        
        if(traceHit.IsA('ProtoOneEnemy'))
        {
            HitEnemy = ProtoOneEnemy(traceHit);
            fDamageGiven = HitEnemy.MaxHealth - HitEnemy.Health;//Get the amount of damage that has been done
            fDamagePercent = (fDamageGiven / HitEnemy.MaxHealth) * 100; //Make that a percent
            fDamageMomentum = (totalForce * 1000) + (fDamagePercent * 100);//Total momentum from damage and charge force
            
            vHitMomentum = traceHit.Location - sweepOrigin;//Get trajectory
            vHitMomentum = fDamageMomentum  * Normal(vHitMomentum);//Apply the full momentum
            
            sweepDmg += totalForce * 0.1;//Modify damage by the charge force
            if(sweepDmg >= 10)
            {
                sweepDmg = 10;//Cap the damage
            }
            
            //tell the bot to take damage and send itself flying
            traceHit.TakeDamage(sweepDmg, Controller(traceHit), hitLoc, vHitMomentum, class'UTDmgType_Rocket');
            sweepDmg = 1; // set damage back to default
        }
        
    }

}

////////////////////////////////////////////Fire Arrow\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
exec function ChargeBow()
{
    local TierrasAI     Tierra;
    
    Tierra = myGameInfo.tierra;
    
    `log("Charge Bow Exec function called");
    
    bArrowShot = true;
    
    if(Tierra.IsInState('Combat') == true)
    {
        if (Tierra.target != none)
        {
            if(bEvading == false)
            {
                bChargingAttack = true;
            }
        }
        else
        {
            `log("Tierra can't shoot because she HAS NO TARGET!");
        }
    }
    else
    {
        `log("Tierra can't shoot because she's NOT IN COMBAT!");
    }    
}

exec function FireArrow()
{
    local vector        hitLoc, hitNorm, vHitMomentum;
    local TraceHitInfo  hitInfo;
    local Actor     traceHit;
    local float     fDamagePercent, fDamageGiven, fDamageMomentum;
    local ProtoOneEnemy     HitEnemy;
    local TierrasAI     Tierra;
    
    Tierra = myGameInfo.tierra;
    
    bArrowShot = false;
    

    //stabRange.Z = 3;
    bChargingAttack = false;
    
    traceHit = Trace(hitLoc, hitNorm, Tierra.target.location, Tierra.pawn.Location,,,hitInfo);
    DrawDebugLine( Tierra.pawn.Location, hitLoc, 0, 255, 0, FALSE );
    //DrawDebugLine( Location, hitLoc, 255, 0, 0, TRUE );
    
    if(totalForce < 13)//Did the player tap the stab button?
    {
        `log("Quick Shot!");
    }
    else//Otherwise they're charging the stab
    {
        `log("Charged Shot for " $totalForce);
        //if(totalForce == 100)
        // `log("Charged Stab with Maximum Force!!!!");
    }
    
    chargeTime = 0;
    
    if(traceHit == none)
    {
        `log("Shot was a miss");
    }
    else
    {
        
        if(traceHit.IsA('ProtoOneEnemy'))
        {
            HitEnemy = ProtoOneEnemy(traceHit);
            fDamageGiven = HitEnemy.MaxHealth - HitEnemy.Health;//Get the amount of damage that has been done
            fDamagePercent = (fDamageGiven / HitEnemy.MaxHealth) * 100; //Make that a percent
            fDamageMomentum = (totalForce * 1000) + (fDamagePercent * 100);//Total momentum from damage and charge force
            
            vHitMomentum = traceHit.Location - Tierra.pawn.location;//Get trajectory
            vHitMomentum = fDamageMomentum  * Normal(vHitMomentum);//Apply the full momentum
            
            stabDmg += totalForce * 0.1;//Modify damage by the charge force
            if(stabDmg >= 10)
            {
                stabDmg = 10;//Cap the damage
            }
            
            //tell the bot to take damage and send itself flying
            traceHit.TakeDamage(stabDmg, Controller(traceHit), hitLoc, vHitMomentum, class'UTDmgType_Rocket');
            stabDmg = 1; // set damage back to default
        }
        
        
    }
}

function int ChargeForce(float DeltaTime)
{
    local int   currentForce;
    
    if(bArrowShot == false)
    {
        GroundSpeed = chargingGroundSpeed;
    }
    
    chargeTime += 1 * DeltaTime;//Tracks the how long the player has been charging the stab, and caps it at 1 second
    // `log("Time charged = " $chargeTime);

    currentForce = chargeTime * maxStabForce;//Gets the force ammount by how long the player holds the button
    
    return FClamp(currentForce, 0.0, maxStabForce);//Caps the force by its max
    
    
        
}
     


defaultproperties
{  
    //bFollowPlayer=FALSE
   //Gameplay Variables\\
   
   //Evading vars\\
   DodgeSpeed = 1200 //from UTPawn
   DodgeDuration = 0.2 //from UTPawn
   bCanEvade = true 
   bEvading = false
   
   bChargingAttack=FALSE
   chargeTime=0
   maxStabForce=100
   spearDist=150
   stabDmg=1
   sweepDmg=1
   bCollideActors=true
   bBlockActors=true
   chargingGroundSpeed=150
   bArrowShot=false
   
   //REACT assignments
   ReactTotTime=5.0;   
   ReactTotTime=3.0;
   TimeDilationMagnitude = 0.45;   
   
   //Create Proper Mesh\\
   Begin Object Class=SkeletalMeshComponent Name=TestPawnSkeletalMesh
   SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
   AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
   AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
   HiddenGame=FALSE
   HiddenEditor=FALSE
   End Object
   Mesh=TestPawnSkeletalMesh
   Components.Add(TestPawnSkeletalMesh)   

}
