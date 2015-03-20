class ProtoOnePawn extends UTPawn;

//Camera vars
var float CamOffsetDistance; //distance to offset the camera from the player
var float CamMagnitudeLimit;
var float CamLeach;
var float CamSpeedMod;

//Evade vars
var bool bEvading;// true when the pawn is evading
var float EvadeSpeed;
var float EvadeDistance;
var vector startPos;

//REACT vars
var float ReactCurTime;
var float ReactTotTime;
var bool hasEnteredREACT;
var float TimeDilationMagnitude;

//Player Attacking vars
var int totalForce;
var float maxStabForce;
var float chargeTime;
var float spearDist;
var float stabDmg;
var float sweepDmg;
var bool bChargingAttack;
var float chargingGroundSpeed;


var int IsoCamAngle; //pitch angle of the camera
var int IsoCamYaw; //place in camrot.yaw for new view
var rotator DesiredRot;
var bool bFollowPlayer;
var vector CamOrigin;

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

  
Simulated Event Tick(float DeltaTime)
{   
    Super.Tick(DeltaTime);
    if(bEvading)
    {
        DoEvade(DeltaTime);
    }
    
    if(bChargingAttack)
    {
        totalForce = ChargeForce(DeltaTime);
    }
    
    if(hasEnteredREACT){
        DoREACT(DeltaTime);
    }
}

event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
    Super.Bump( Other, OtherComp, HitNormal );
    `log("OMG BUMPED SOMETHING");
    if(bEvading == true)//End evade it the player hits anouther actor (not working)
    {
        EndEvade();   
    }
}

event HitWall(Vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
    super.HitWall(HitNormal, Wall, WallComp);
    `log("HITTING DEM WALLZ!!!");
    if(bEvading == true)//End evade it the player hits anouther actor (not working)
    {
        EndEvade();   
    }
} 

event RanInto(Actor Other)
{
    super.RanInto(Other);
    `log("HITTING THINGZ!!!");
    if(bEvading == true)//End evade it the player hits anouther actor (not working)
    {
        EndEvade();   
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
//////////////////////////////Camera Logic\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
   CamLogic(fDeltaTime);//controls how the camera is moved by the player
   
   out_CamLoc = CamOrigin;
   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

   out_CamRot.Pitch = -1 * IsoCamAngle;   
   out_CamRot.Yaw = 0;
   out_CamRot.Roll = 0;

   return true;
}

function CamLogic(float DeltaTime)
{   
    local float PlayerMagnitude;
    local vector PlayerDirection;
    
    PlayerDirection = Location - CamOrigin;//Get the direction the player is in from camera origin
    PlayerMagnitude = Sqrt(Square(PlayerDirection.x) + Square(PlayerDirection.y));//Get the distance the player is from the origin
    
    //`log("PlayerMagnitude = " $PlayerMagnitude);
    //`log("Location = " $Location);

    
    while(PlayerMagnitude > CamLeach)//Player is now pulling the camera
    {
        //MoveToward(PlayerDirection);
		//Use CustomTimeDilation so camera moves normally when in REACT mode
        CamOrigin.x += (PlayerDirection.x * CamSpeedMod * CustomTimeDilation) * DeltaTime;
        CamOrigin.y += (PlayerDirection.y * CamSpeedMod * CustomTimeDilation) * DeltaTime; 
        return;
    }

}
/////////////////////////Evade\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
exec function Evade()
{  
  
    `log("exec funct called");
    bEvading = true;
    startPos = Location;//Save starting location
    
}

  
function DoEvade(float DeltaTime)
{
    local vector    distTravelled, hitLoc, hitNorm, checkRange; 
    local TraceHitInfo  hitInfo;
    local Actor     collisionCheck;
    local float currentDist, smoothTime;
    
    checkRange = Location + Normal(Vector(Rotation)) * 50;//Lenght of the trace infront of the player to determine collision
    collisionCheck = Trace(hitLoc, hitNorm, checkRange, Location,,,hitInfo);//Trace for collsision
    
    SetPhysics(PHYS_Falling);
    
    velocity.z = 1;//lift the player so they are not walking
    
    smoothTime = 50 * DeltaTime;//Controls how smooth the evade transition is
    distTravelled = Location - startPos;//Get the distance the player has travelled while evading
    currentDist = VSize(distTravelled);//Make the vector a float
    velocity += Vector(DesiredRot) * Lerp(EvadeSpeed, 1, smoothTime);//push the player in the direction they are facing

    `log("Travelled Distance = " $ currentDist);

    if(currentDist > EvadeDistance || collisionCheck != none)//If the player collides of finishes the evade...
    {
        EndEvade();
    }
    
}
  
function EndEvade()//switch everything back to normal at the end of an evade
{
    bEvading = false;
    `log("End Evade");
    SetPhysics(PHYS_Walking);
    velocity.z = 0;
    velocity = Vect(0,0,0);
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
	
    
    if(ReactCurTime >= ReactTotTime){ //REACTIME has been on for 1 second
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
        if(totalForce == 100)
        `log("Charged Stab with Maximum Force!!!!");
    }
    chargeTime = 0;
    if(traceHit == none)
    {
        `log("Stab was a miss");
    }
    else
    {
        `log("Stab hit a: " $traceHit$" class: "$traceHit.class);
        `log("Hit Location: "$hitLoc.X$","$hitLoc.Y$","$hitLoc.Z);
        `log("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
        `log("Component: "$hitInfo.HitComponent);
        
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
            
        }
        
    }

}

function int ChargeForce(float DeltaTime)
{
    local int   currentForce;
    
    GroundSpeed = chargingGroundSpeed;
    
    chargeTime += 1 * DeltaTime;//Tracks the how long the player has been charging the stab, and caps it at 1 second
        `log("Time charged = " $chargeTime);

    currentForce = chargeTime * maxStabForce;//Gets the force ammount by how long the player holds the button
    
    return FClamp(currentForce, 0.0, maxStabForce);//Caps the force by its max
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
        if(totalForce == 100)
        `log("Charged LeftSweep with Maximum Force!!!!");
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
            
        }
        
    }

}

//REFACTOR FOR CODE REUSE WITH LEFTSWEEP

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

  
    if(totalForce < 13)//Did the player tap the RightSweep button?
    {
        `log("Quick RightSweep!");
    }
    else//Otherwise they're charging the RightSweep
    {
        `log("Charged RightSweep for " $totalForce);
        if(totalForce == 100)
        `log("Charged RightSweep with Maximum Force!!!!");
    }
    chargeTime = 0;
    if(traceHit == none)
    {
        `log("RightSweep was a miss");
    }
    else
    {
        `log("RightSweep hit a: " $traceHit$" class: "$traceHit.class);
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
            
        }
        
    }

}

     


defaultproperties
{  

   //Camera Variables\\
   IsoCamAngle=7000 //6420.0 //35.264 degrees
   IsoCamYaw=7500
   CamOffsetDistance=1000  //800.0
   bFollowPlayer=FALSE
   CamOrigin=(x=-3728,y=600,z=60)
   CamLeach=300
   CamSpeedMod=0.8
   
   //Gameplay Variables\\
   bEvading=FALSE
   EvadeSpeed=200
   EvadeDistance=225
   
   bChargingAttack=FALSE
   chargeTime=0
   maxStabForce=100
   spearDist=150
   stabDmg=1
   sweepDmg=1
   bCollideActors=true
   bBlockActors=true
   chargingGroundSpeed=150
   
   //REACT assignments
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
