//  ================================================================================================
//   * File Name:    ReactGameCamera
//   * Created By:   Byron
//   * Time Stamp:     3/17/2014 2:02:52 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class ReactGameCamera extends GamePlayerCamera;

var (Camera) editinline transient GameCameraBase ProperCamera;
var (Camera) protected const class<GameCameraBase> MainCameraClass;

simulated event PostBeginPlay()
{
    local ReactGameInfo myGameInfo;
    
    super.PostBeginPlay();
     
    myGameInfo = ReactGameInfo(WorldInfo.game);
    
     if((ProperCamera == none) && (MainCameraClass != None))
     {
         ProperCamera = CreateCamera(MainCameraClass);
         myGameInfo.mainCamera = self;
     }
 }
protected function GameCameraBase FindBestCameraType(Actor CameraTarget)
{
    //Add here the code that will figure out which cam to use.
    return ProperCamera; // We only have this camera
}

defaultproperties
{
    MainCameraClass=class'ReactProtoTwo.MainCamera'
}