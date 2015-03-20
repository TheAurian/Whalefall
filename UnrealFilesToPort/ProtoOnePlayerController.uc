class ProtoOnePlayerController extends UTPlayerController;

var rotator		OldRotation;

auto state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

  function PlayerMove( float DeltaTime )//Returns the players acceleration and rotation
  {
	local vector		NewAccel;
	local eDoubleClickDir	DoubleClickMove;
		
	local bool		bSaveJump;
		
	if( Pawn == None )
	{
		GotoState('Dead');
	}
	
	else
	{	
		// Update acceleration.
		NewAccel.X += PlayerInput.aForward;
		NewAccel.Y += PlayerInput.aStrafe;
		NewAccel.Z = 0;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);

		if (IsLocalPlayerController())
		{
			AdjustPlayerWalkingMoveAccel(NewAccel);
		}

		DoubleClickMove = PlayerInput.CheckForDoubleClickMove( DeltaTime/WorldInfo.TimeDilation );

		// Update rotation.
		OldRotation = Rotation;
		UpdateRotation( DeltaTime );
		bDoubleJump = false;

		if( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
		{
			bSaveJump = false;
		}

		if( Role < ROLE_Authority ) 
		{
			ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		}
		else
		{
			ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
		}
		bPressedJump = bSaveJump;
	}

		IgnoreLookInput( TRUE );//ignores mouse aiming input
	}


  
     function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)//process the data returned form PlayerMove
   {

   	   
      if( Pawn == None )
      {
         return;
      }

      if (Role == ROLE_Authority)
      {
         // Update ViewPitch for remote clients
         Pawn.SetRemoteViewPitch( Rotation.Pitch );
      }

      Pawn.Acceleration = NewAccel;

      
      CheckJumpOrDuck();
   }

}  


defaultproperties
{
   
   bIsPlayer=true
	
}
