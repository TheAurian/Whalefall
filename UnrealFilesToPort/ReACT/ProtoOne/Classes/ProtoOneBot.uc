class ProtoOneBot extends AIController;

//var bool targetPlayer;
var Actor target;
var Pawn Toroa;
var() Vector TempDest;
/*
event PostBeginPlay()
{
    super.PostBeginPlay();

    NavigationHandle = new(self) class'NavigationHandle';
}
*/
event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);
    Pawn.SetMovementPhysics();
}

event PostBeginPlay()
{
    super.PostBeginPlay();
    Toroa=GetALocalPlayerController().Pawn;
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
    super.NotifyTakeHit( InstigatedBy, HitLocation, Damage, damageType, Momentum);
    //`log("Took a hit from " $InstigatedBy$ " for " $Damage$ " damage!");
    // `log("With a momenum of " $Momentum);
    //`log("Health Remaining = " $Pawn.health);
    GotoState('Idle');
}
auto state() Idle
{
    
    event SeePlayer( Pawn Seen )
    {
        super.SeePlayer(Seen);
        // `log("Current Bot Location = " $Pawn.location);
        if(pawn.Physics == PHYS_Walking)
        {
           if(seen == Toroa)
           {
                 target = Seen;//Targets the player when they are seen
                 GotoState('Follow');
           }
            //`log("Target = " $target$" class: " $target.class);
            
        }
    }
    Begin:  

}

state Follow
{
ignores SeePlayer;
    //The Nav Mesh is created by the Pylon in the UDK Level!
    function bool FindNavMeshPath()
    {
              if (NavigationHandle == None)
              {
                  // `log("No Navigation Handle found");
                      return false;
              }
              else
              {
                 // Clear cache and constraints (ignore recycling for the moment)
             NavigationHandle.PathConstraintList = none;
             NavigationHandle.PathGoalList = none;
 
             // Create constraints
             class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle,target );
             class'NavMeshGoal_At'.static.AtActor( NavigationHandle, target,32 );
 
             // Find path
            return NavigationHandle.FindPath();
              }
    }
Begin:

    if( NavigationHandle.ActorReachable(target) )
    {
        // FlushPersistentDebugLines();
        
        //Direct move
        MoveToward( target,target,128 );
        //`log("Should be moving towards the target");
    }
    else if( FindNavMeshPath() )
    {
        NavigationHandle.SetFinalDestination(target.Location);
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
        //We can't follow, so get the hell out of this state, otherwise we'll enter an infinite loop.
        // `log("Can't follow the target");
        GotoState('Idle');
    }
 
    goto 'Begin';
}

defaultproperties
{
    //Components.Add(NavagationHandle)
    //targetPlayer=true\
   bIsPlayer=false;
}
