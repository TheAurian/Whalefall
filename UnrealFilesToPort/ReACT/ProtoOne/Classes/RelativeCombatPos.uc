//  ================================================================================================
//   * File Name:    RelativeCombatPos
//   * Created By:   Byron
//   * Time Stamp:     1/27/2014 11:08:22 AM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class RelativeCombatPos extends Actor;

defaultproperties
{
    
    begin object Class=SpriteComponent Name=Sprite
        Sprite=S_Actor
        HiddenGame=false
    end object
    //Components.Add(Sprite)
    bHardAttach=true;
}