//  ================================================================================================
//   * File Name:    InventoryManager_PC1
//   * Created By:   Hami
//   * Time Stamp:     1/29/2014 7:47:13 PM
//   * UDK Path:   C:\UDK\WhalefallStudios
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class InventoryManager_PC1 extends InventoryManager;

function Inventory CreateInventoryArchetype(Inventory NewInventoryItemArchetype, optional bool bDoNotActivate)
{
    local Inventory Inv;

    if (NewInventoryItemArchetype != none)
    {
        Inv = Spawn(NewInventoryItemArchetype.Class, Owner,,,, NewInventoryItemArchetype);

        if (Inv != none)
        {
            if (!AddInventory(Inv, bDoNotActivate))
            {
                Inv.Destroy();
                Inv = none;
            }
        }
    }

    return Inv;
}


defaultproperties
{
    //weapon not waiting to fire
    PendingFire(0)=0
    
    TickGroup=TG_DuringAsyncWork

    bReplicateInstigator=TRUE
    RemoteRole=ROLE_SimulatedProxy
    bOnlyDirtyReplication=TRUE
    bOnlyRelevantToOwner=TRUE
    NetPriority=1.4
    bHidden=TRUE
    Physics=PHYS_None
    bReplicateMovement=FALSE
    bStatic=FALSE
    bNoDelete=FALSE
}