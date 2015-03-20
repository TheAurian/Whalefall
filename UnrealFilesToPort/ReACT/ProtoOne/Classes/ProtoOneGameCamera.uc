//  ================================================================================================
//   * File Name:    ProtoOneGameCamera
//   * Created By:   Byron
//   * Time Stamp:     1/20/2014 2:48:09 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class ProtoOneGameCamera extends GamePlayerCamera;
//var actor Toroa;
var (Camera) editinline transient GameCameraBase ProtoOneCam;
var (Camera) protected const class<GameCameraBase> ProtoOneCameraClass;

simulated event PostBeginPlay()
{
    local ProtoOneGame myGameInfo;
    
    super.PostBeginPlay();
     
     myGameInfo = ProtoOneGame(WorldInfo.game);
    
     if((ProtoOneCam == none) && (ProtoOneCameraClass != None))
     {
         ProtoOneCam = CreateCamera(ProtoOneCameraClass);
         myGameInfo.mainCamera = self;
     }
 }
protected function GameCameraBase FindBestCameraType(Actor CameraTarget)
{
    //Add here the code that will figure out which cam to use.
    return ProtoOneCam; // We only have this camera
}

defaultproperties
{
    ProtoOneCameraClass=class'ProtoOne.ProtoOneCamera'
    
}