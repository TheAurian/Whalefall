//  ================================================================================================
//   * File Name:    PlayerControllerBase
//   * Created By:   Byron
//   * Time Stamp:     3/7/2014 12:50:11 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class PlayerControllerBase extends GamePlayerController;

var ReactGameInfo myGameInfo;
var rotator cameraRotation;
var vector cameraLocation;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();
    
    myGameInfo = ReactGameInfo(WorldInfo.game);
    cameraRotation = PlayerCamera.ViewTarget.POV.Rotation;
    cameraLocation = myGameInfo.mainCamera.location;
}


auto state PlayerMoving
{
ignores SeePlayer, HearNoise, Bump;



  function PlayerMove( float DeltaTime )//Returns the players acceleration and rotation
  {
      local vector        NewAccel, X, Y, Z, relativePos;
      local rotator       OldRotation, DesiredRotation;
      local eDoubleClickDir   DoubleClickMove;
     
      GetAxes(pawn.rotation,X,Y,Z);  
     
    if(pawn != none)
    {  
       // DesiredRotation.Yaw = PlayerCamera.ViewTarget.POV.Rotation.Yaw;
       // DoubleClickMove = DCLICK_None;
        //relativePos = pawn.location >> cameraRotation;
       // NewAccel.X = 0;//PlayerInput.aForward;
       // NewAccel.Y = 0;//PlayerInput.aStrafe;
       //NewAccel = PlayerInput.aForward*X + PlayerInput.aStrafe*Y;
       NewAccel = Abs(PlayerInput.aForward)*X + Abs(PlayerInput.aStrafe)*X;
       NewAccel.Z = 0;
        //NewAccel = TransformVectorByRotation(DesiredRotation, NewAccel);
        NewAccel = Pawn.AccelRate * Normal(NewAccel);
        
        OldRotation = Rotation;
        UpdateRotation(DeltaTime);
        `log(NewAccel);

        AdjustPlayerWalkingMoveAccel(NewAccel);
        
        
        DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );
        
        // Update rotation.
        
        //UpdateRotation( DeltaTime );
        
        /*
        if( NewAccel.X > 0.0 || NewAccel.X < 0.0 || NewAccel.Y > 0.0 || NewAccel.Y < 0.0 )
        DesiredRotation = rotator(NewAccel);
        else
        DesiredRotation = Pawn.Rotation;

        Pawn.SetRotation(DesiredRotation); 
        */
        if( Role < ROLE_Authority ) // then save this move and replicate it
                ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
            else
                ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
                // ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);//DCLICK_None
    }

        IgnoreLookInput( TRUE );//ignores mouse aiming input
    }


  
     function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)//process the data returned form PlayerMove
   {

       
      if( Pawn == None )
      {
         return;
      }


     //Pawn.SetRemoteViewPitch( Rotation.Pitch );
      
      Pawn.Acceleration = NewAccel;

      
      CheckJumpOrDuck();
   }
}

defaultproperties
{
    bIsPlayer=true   
    CameraClass=class'ReactProtoTwo.ReactGameCamera'
}