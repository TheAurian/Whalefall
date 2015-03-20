//  ================================================================================================
//   * File Name:    TierrasAI
//   * Created By:   Byron
//   * Time Stamp:     12/29/2013 11:46:10 AM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2013. All Rights Reserved.
//  ================================================================================================

class TierrasAI extends AIController;

var Actor followPos, Toroa, target, traceHit;
var ProtoOneEnemy targetedEnemy;
var TierrasCombatPos combatPos;
var RelativeCombatPos relativePos;
var RelativeTargetPos relativeTargetPos;
var TargetArrow targetArrow;
var array<Pawn> Enemies;
//var() Pawn Toroa;
var() Vector TempDest, followOffset;
var ProtoOneGame myGameInfo;
var ProtoOneGameCamera theCamera;
var bool bTargetCheck, bToroaCheck, bNeedTarget;


event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
    `log(GetStateName());
}

event SeeMonster(Pawn Seen)
{
    local Vector    hitLoc, hitNorm;
    
    //`log("Tierra SEES a MONSTER");
    
    super.SeeMonster(Seen);
    if(bNeedTarget == true)
    {
        Target = Seen;
        

        if(targetArrow == none)
        { 
            targetArrow = Spawn(class'TargetArrow',,,target.location + vect(0,0,150));
            `log("Spawned target arrow");
        }
        
        targetArrow.SetTarget(target); 

        if(relativeTargetPos == none)
        {
            traceHit = Trace(hitLoc, hitNorm, traceHit.Location, theCamera.Location + vect(0,0,-1), false);//Get the location directly below the camera
            relativeTargetPos = Spawn(class'RelativeTargetPos',,,traceHit.Location);
            relativeTargetPos.SetPosition(target);
        }
        
       if(Seen.IsA('ProtoOneEnemy'))
       {
           Seen = targetedEnemy;//Could this create an issue???
       }
        
        if(IsInState('Combat') != true)
        {
            GotoState('Combat');
            //bNeedTarget = false;
        }
    }
    

}

simulated event PostBeginPlay()
{
    SetTimer(5, true);
    
     Toroa=GetALocalPlayerController().Pawn;
    
     followOffset=vect(0,-300,0);
     followPos = Spawn(class'TierrasFollowPos',,,Toroa.Location + followOffset);

     myGameInfo = ProtoOneGame(WorldInfo.game);
     
     theCamera = myGameInfo.mainCamera; 
     
     myGameInfo.tierra = self;
     
     bTargetCheck = false;
    
    super.PostBeginPlay();
}

function Timer()
{
    `log("Tierra is in the"$GetStateName()$" state!"); 
}
/*
simulated event Tick(float DeltaTime)
{
    if(targetArrow.bIsSet == false && target != none)
    {
        targetArrow.SetTarget(target);
    }
}
*/
auto state() Idle//-------------------------------------------------------------------
{
     Begin:
     //`log("Tierra is idle");
      if( NavigationHandle.ActorReachable(followPos) && pawn.Physics == PHYS_Walking )
     {
               GotoState('Follow'); 
     }
        
}

 state Follow//------------------------------------------------------------------------
{


    //The Nav Mesh is created by the Pylon in the UDK Level!
    function bool FindNavMeshPath()
    {
              if (NavigationHandle == None)
              {
                  `log("Tierra can't Navigation Handle found");
                      return false;
              }
              else
              {
                 // Clear cache and constraints (ignore recycling for the moment)
             NavigationHandle.PathConstraintList = none;
             NavigationHandle.PathGoalList = none;
 
             // Create constraints
             class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,Toroa );
             class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Toroa,32 );
 
             // Find path
            return NavigationHandle.FindPath();
              }
    }
Begin:

    

    if( NavigationHandle.ActorReachable(followPos) )
    {
        // FlushPersistentDebugLines();
        
        //Direct move
        MoveTo( followPos.location, Toroa, 128 );
        //`log("Should be moving towards the target");
    }
    else if( FindNavMeshPath() )
    {
        NavigationHandle.SetFinalDestination(followPos.location);
        //FlushPersistentDebugLines();
        //NavigationHandle.DrawPathCache(,TRUE);
        //`log("Finding a new path!");
        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
            //DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
            //DrawDebugSphere(TempDest,16,20,255,0,0,true);
 
            MoveTo( TempDest, Toroa );
        }
    }
    else
    {
        //We cant follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        `log("Can't find Toroa");
        GotoState('Idle');
    }
    

    goto 'Begin';
}

state Combat//----------------------------------------------------------------------------------
{
    
    local Vector    hitLoc, hitNorm, belowCamera, viewLoc;
    local Rotator   viewRot; 
    local TraceHitInfo  hitInfo;
    local bool      bFoundEnemy;
    
    ignores SeeMonster;
       //The Nav Mesh is created by the Pylon in the UDK Level!
    function bool FindNavMeshPath()
    {
              if (NavigationHandle == None)
              {
                      `log("No Navigation Handle found");
                      return false;
              }
              else
              {
                 // Clear cache and constraints (ignore recycling for the moment)
             NavigationHandle.PathConstraintList = none;
             NavigationHandle.PathGoalList = none;
 
             // Create constraints
             class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,combatPos );
             class'NavMeshGoal_At'.static.AtActor( NavigationHandle, combatPos,32 );
 
             // Find path
            return NavigationHandle.FindPath();
              }
    }
Begin:

   
    if(combatPos == none)
    {
        traceHit = Trace(hitLoc, hitNorm, traceHit.Location, theCamera.Location + vect(0,0,-1), false,,hitInfo);//Get the location directly below the camera
        relativePos = Spawn(class'RelativeCombatPos',,,traceHit.Location);//Set that location as the relative combat pos
        relativePos.SetBase(theCamera);
        
        combatPos = Spawn(class'TierrasCombatPos',,,traceHit.Location);
        combatPos.SetBase(relativePos);
        
        combatPos.basePos = combatPos.Location;
        combatPos.leftPos = combatPos.basePos + vect(-300,300,0);
        combatPos.rightPos = combatPos.basePos + vect(300,300,0); 
        `log("Spawned combat pos");

        
    }
    

    


  

    if (target.IsInState('Dying'))
    {
        `log("Tierra's TARGET DIED");
        bFoundEnemy = FindNearestEnemy(targetedEnemy);
        
        if (bFoundEnemy == false)
        {
            bNeedTarget = true;
            GoToState('Follow');
            targetArrow.Destroy();
        }
    }
    
    CheckCombatPos();
    
    if( NavigationHandle.ActorReachable(combatPos) )
    {
        // FlushPersistentDebugLines();
        
        //Direct move
        MoveTo( combatPos.location, Target, 128 );
        //`log("Should be moving towards the target");
    }
    else if( FindNavMeshPath() )
    {
        NavigationHandle.SetFinalDestination(combatPos.location);
        //FlushPersistentDebugLines();
        //NavigationHandle.DrawPathCache(,TRUE);
        //`log("Finding a new path!");
        // move to the first node on the path
        if( NavigationHandle.GetNextMoveLocation( TempDest, Pawn.GetCollisionRadius()) )
        {
            //DrawDebugLine(Pawn.Location,TempDest,255,0,0,true);
            //DrawDebugSphere(TempDest,16,20,255,0,0,true);
 
            MoveTo( TempDest, target );
        }
    }
    else
    {
        //We cant follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        `log("Can't follow the target");
        GotoState('Idle');
    }
    
    goto 'Begin';
}

function CheckCombatPos()
{
    local float     toroaDist, targetDist, cameraDist, toroaCamDist;
    //local bool      bTargetCheck;
    //local Actor     checkedActor;
    
    toroaDist = (toroa.location - pawn.location) dot (toroa.location - pawn.location);
    targetDist = VSizeSq(pawn.location - target.location);
    cameraDist = VSizeSq(pawn.location - theCamera.Location);
    toroaCamDist = VSizeSq(toroa.location - theCamera.Location);
    //checkedTargetDist = VSize(location - checkedTarget.location);
    //`log("toroaDist = "$toroaDist);
    if(toroaDist > targetDist && bTargetCheck == false)
    {
        combatPos.SetCombatPos();
        `log("CombatPos set due to TARGET distance");
        bTargetCheck = true;
        //checkedTarget = target;
    }
    else if (toroaDist < targetDist && bTargetCheck == true)
    {
        bTargetCheck = false;
        // `log("Toroa is closest again!");
    }
    
    if(toroaDist < 25000 && bToroaCheck == false)
    {
        combatPos.SetCombatPos();
        bToroaCheck = true;
        `log("Toroa is too close!");        
    }
    else if (toroaDist >= 25000 && bToroaCheck == true)
    {
        bToroaCheck = false;
    }
    /*
    else if (toroaCamDist < cameraDist)
    {
        combatPos.SetCombatPos(); 
        `log("CombatPos called due to CAMERA distance");
    }
    */
        
}

function bool FindNearestEnemy(ProtoOneEnemy deadTarget)
{
    //local array<class<ProtoOneEnemy> > aEnemy;
    local ProtoOneEnemy theEnemy;
    local int enemyDist;
    local int prevEnemyDist;
    local ProtoOneEnemy closestEnemy;
    
    `log("LOOKING for nearest ENEMY");
    
    foreach DynamicActors(class'ProtoOneEnemy',  theEnemy)
    {
        //`log("Enemy: "$theEnemy$"'s location is: " $theEnemy.Location);
        if (theEnemy.IsInState('Dying') != true)
        {
            enemyDist = VSizeSq(pawn.location - theEnemy.location);
            
            `log("Enemy: "$theEnemy$"'s distance is: " $enemyDist);
            
            if(prevEnemyDist == 0 || enemyDist <= prevEnemyDist && theEnemy != deadTarget)
            {
               closestEnemy = theEnemy;
            }
            
            prevEnemyDist = enemyDist;
        }
    }
    
    if(closestEnemy != none)
    {
        `log("The NEW TARGET is: "$closestEnemy$" Its location is: " $closestEnemy.Location);
        Target = closestEnemy;
        targetedEnemy = closestEnemy;
        targetArrow.SetTarget(Target);
        relativeTargetPos.SetPosition(target); 
        return true;
    }
    else
    {
        `log("NO ENEMIES near by");
        return false;
    }
}

function SwitchTarget(bool SwitchDirection)//This is called from ProtoOneInput
{
    local ProtoOneEnemy theEnemy;
    local int enemyDist;
    local int prevEnemyDist;
    local ProtoOneEnemy closestEnemy;
    local vector vEnemyDist;
    
    if(SwitchDirection == true)
    {

        `log("Switch TARGET to nearest RIGHT");
        
        foreach DynamicActors(class'ProtoOneEnemy',  theEnemy)
        {
            //`log("Enemy: "$theEnemy$"'s location is: " $theEnemy.Location);
            if (theEnemy.IsInState('Dying') != true)
            {
                enemyDist = VSizeSq(target.location - theEnemy.location);
                vEnemyDist = relativeTargetPos.location - theEnemy.location;
                
                `log("Enemy: "$theEnemy$"'s distance is: " $vEnemyDist);
                
                if(prevEnemyDist == 0 && vEnemyDist.x > 0|| enemyDist <= prevEnemyDist && vEnemyDist.x > 0)//Add code so it doesn't target dead targets
                {
                   closestEnemy = theEnemy;
                }
                
                prevEnemyDist = enemyDist;
                
            }
           
        }
        
        if(closestEnemy != none)
        {
            `log("The NEW TARGET is: "$closestEnemy$" Its location is: " $closestEnemy.Location);
            Target = closestEnemy;
            targetedEnemy = closestEnemy;
            targetArrow.SetTarget(Target);
            relativeTargetPos.SetPosition(target);       

        }
        else
        {
            `log("NO ENEMIES near by");
        }
    }
       
    else if (SwitchDirection == false)
    {
        
        `log("Switch TARGET to nearest LEFT"); 
    
         foreach DynamicActors(class'ProtoOneEnemy',  theEnemy)
        {
            //`log("Enemy: "$theEnemy$"'s location is: " $theEnemy.Location);
            if (theEnemy.IsInState('Dying') != true)
            {
                enemyDist = VSizeSq(target.location - theEnemy.location);
                vEnemyDist = relativeTargetPos.location - theEnemy.location;
                
                `log("Enemy: "$theEnemy$"'s distance is: " $vEnemyDist);
                
                if(prevEnemyDist == 0 && vEnemyDist.x < 0 || enemyDist <= prevEnemyDist && vEnemyDist.x < 0)//Add code so it doesn't target dead targets
                {
                   closestEnemy = theEnemy;
                }
                
                prevEnemyDist = enemyDist;
            }
        }
        
        if(closestEnemy != none)
        {
            `log("The NEW TARGET is: "$closestEnemy$" Its location is: " $closestEnemy.Location);
            Target = closestEnemy;
            targetedEnemy = closestEnemy;
            targetArrow.SetTarget(Target);
            relativeTargetPos.SetPosition(target);       

        }
        else
        {
            `log("NO ENEMIES near by");
        }    
    }
}

defaultproperties
{
    bIsPlayer=true;
    bNeedTarget=true;   
 
}