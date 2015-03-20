//  ================================================================================================
//   * File Name:    TierrasFollowPos
//   * Created By:   Byron
//   * Time Stamp:     12/31/2013 12:45:19 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2013. All Rights Reserved.
//  ================================================================================================

class TierrasFollowPos extends Actor;

var() Pawn Toroa;
var() Vector followOffset;

event PostBeginPlay()
{   
    Toroa=GetALocalPlayerController().Pawn;
    
    followOffset=vect(-300,0,0);
    
    if(Location != Toroa.Location + followOffset)
    {
        SetLocation(Toroa.location + followOffset);
        //`log("Follow Pos = " $Location);
    }

    SetBase(Toroa);

    super.PostBeginPlay();
}



defaultproperties
{
    begin object Class=SpriteComponent Name=Sprite
        Sprite=S_Actor
        HiddenGame=true
    end object
    Components.Add(Sprite)
    bHardAttach=false;
}