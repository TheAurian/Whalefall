class ProtoOneEnemy extends UTPawn;
//placeable;

   
var(NPC) SkeletalMeshComponent NPCMesh;
var(NPC) class<AIController> NPCController;
var float MaxHealth;

//var AnimNodeSlot FullBodyAnimSlot;

//var DynamicLightEnvironmentComponent LightEnvironment;

simulated event PostBeginPlay()
{
  if(NPCController != none)
  {
    //set the existing ControllerClass to our new NPCController class
    ControllerClass = NPCController;
  }
   
  Super.PostBeginPlay();
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
  local vector ApplyImpulse, ShotDir;
 
  bReplicateMovement = false;
  bTearOff = true;
  Velocity += TearOffMomentum;
  SetDyingPhysics();
  bPlayedDeath = true;
  HitDamageType = DamageType; // these are replicated to other clients
  TakeHitLocation = HitLoc;
  if ( WorldInfo.NetMode == NM_DedicatedServer )
  {
    GotoState('Dying');
    return;
  }
  InitRagdoll();
  mesh.MinDistFactorForKinematicUpdate = 0.f;
 
  if (Physics == PHYS_RigidBody)
  {
    //@note: Falling instead of None so Velocity/Acceleration don't get cleared
    setPhysics(PHYS_Falling);
  }
  PreRagdollCollisionComponent = CollisionComponent;
  CollisionComponent = Mesh;
  if( Mesh.bNotUpdatingKinematicDueToDistance )
  {
    Mesh.ForceSkelUpdate();
    Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
  }
  if( Mesh.PhysicsAssetInstance != None )
    Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
  Mesh.SetRBChannel(RBCC_Pawn);
  Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
  Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
  Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
  Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
  Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
  Mesh.ForceSkelUpdate();
  Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
  Mesh.PhysicsWeight = 1.0;
  Mesh.bUpdateKinematicBonesFromAnimation=false;
  // mesh.bPauseAnims=True;
  Mesh.SetRBLinearVelocity(Velocity, false);
  mesh.SetTranslation(vect(0,0,1) * 6);
  Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
  Mesh.SetNotifyRigidBodyCollision(true);
  Mesh.SetBlockRigidBody(true);
  Mesh.WakeRigidBody();
  if( TearOffMomentum != vect(0,0,0) )
  {
    ShotDir = normal(TearOffMomentum);
    ApplyImpulse = ShotDir * DamageType.default.KDamageImpulse;
    // If not moving downwards - give extra upward kick
    if ( Velocity.Z > -10 )
    {
      ApplyImpulse += Vect(0,0,1)*2;
    }
    Mesh.AddImpulse(ApplyImpulse, TakeHitLocation,, true);
  }
  GotoState('Dying');
}

simulated event PostInitAnimTree(SkeletalMeshcomponent SkelComp)
{
        AimNode.bForceAimDir = true; //forces centercenter
 
        if(Mesh !=none)
                {
                        super.PostInitAnimtree(SkelComp);
                        if (SkelComp == Mesh)
                        {
                                FullBodyAnimSlot = AnimNodeSlot(Mesh.FindAnimNode('FullBodySlot'));
                        }
                }
}


//override to do nothing
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
}



defaultproperties 
{
    //Pawn's light environment
    /*
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
                bSynthesizeSHLight=TRUE
                bIsCharacterLightEnvironment=TRUE
        End Object
        Components.Add(MyLightEnvironment)
        LightEnvironment=MyLightEnvironment
        **/
  //Setup default NPC mesh
  Begin Object Class=SkeletalMeshComponent Name=TestPawnSkeletalMesh
      assigning mesh to environment
      LightEnvironment=MyLightEnvironment
      CastShadow=true
      bCastDynamicShadow=true
      bOwnerNoSee=false
      bHasPhysicsAssetInstance=true
      bEnableSoftBodySimulation=true
      bSoftBodyAwakeonStartup=True
      PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
  
      SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'//CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA
      AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
      AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
      HiddenGame=FALSE
      HiddenEditor=FALSE
  End Object
  Mesh=TestPawnSkeletalMesh
  Components.Add(TestPawnSkeletalMesh)
  CollisionType=COLLIDE_BlockAll
  //Points to your custom AIController class - as the default value
  NPCController=class'ProtoOneBot'
  SuperHealthMax=300
  MaxHealth=10
  health=10
  GroundSpeed=500.0 //Making the bot slower than the player
}
