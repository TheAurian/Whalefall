//  ================================================================================================
//   * File Name:    TierrasPawn
//   * Created By:   Byron
//   * Time Stamp:     12/29/2013 11:42:50 AM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2013. All Rights Reserved.
//  ================================================================================================

class TierrasPawn extends SimplePawn;

var(NPC) SkeletalMeshComponent NPCMesh;
var(NPC) class<AIController> NPCController;

simulated event PostBeginPlay()
{
    if(NPCController != none)
  {
    //set the existing ControllerClass to our new NPCController class
    ControllerClass = NPCController;
  }
    super.PostBeginPlay();
}


defaultproperties
{
     Begin Object Class=SkeletalMeshComponent Name=TestPawnSkeletalMesh
     
        SkeletalMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
        AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
        AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
        HiddenGame=FALSE
        HiddenEditor=FALSE
     
     End Object
     
     Mesh=TestPawnSkeletalMesh
     Components.Add(TestPawnSkeletalMesh)
     
     NPCController=class'TierrasAI'
}