//  ================================================================================================
//   * File Name:    ToroaPawn
//   * Created By:   Byron
//   * Time Stamp:     3/7/2014 12:50:51 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class ToroaPawn extends Pawn;



simulated event PostBeginPlay()
{
    super.PostBeginPlay();
}

//////////////////////////Pawn Rotation\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/*
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{
    local rotator DesiredRot;
    
    DesiredRot = GetRotation();//Rotates the pawn to face its velocity

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

function rotator GetRotation()
{
    local vector Velo;//create a vector for the pawns velocity
    local rotator newRot;

   // Velo = Velocity;//Stores the pawns velocity
    
    if(IsZero(Velocity) || Velocity.Z != 0)//Is the player stationary or moving up/down?
    {
        //Keep the pawns current rotation
       // return none;
       newRot = Rotation;

    }
    else//Player is Moving
    {                                         
        newRot.Pitch = 0;
        Velo = Normal(Velocity);//Normalize Vector
        newRot = Rotator(Velo);//Convert the Vector into a rotation
        
    }
        return newRot;  
}
    */  
defaultproperties
{
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