//  ================================================================================================
//   * File Name:    MainCamera
//   * Created By:   Byron
//   * Time Stamp:     3/17/2014 2:06:41 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class MainCamera extends GameCameraBase;

var float CamOffsetDistance; //distance to offset the camera from the player
var float CamMagnitudeLimit;
var float CamLeach;
var float CamSpeedMod;
var int IsoCamAngle; //pitch angle of the camera
var int IsoCamYaw; //place in camrot.yaw for new view
var bool bFollowPlayer;
var vector CamOrigin;

function UpdateCamera(Pawn P, GamePlayerCamera CameraActor, float DeltaTime, out TViewTarget OutVT)
{
     local float PlayerMagnitude;
     local vector PlayerDirection;

   
     OutVT.POV.Location = CamOrigin;
     OutVT.POV.Location.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
     OutVT.POV.Location.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
     OutVT.POV.Rotation.Pitch = -1 * IsoCamAngle;
     OutVT.POV.Rotation.Yaw = 0;
     OutVT.POV.Rotation.Roll = 0;
    
     PlayerDirection = P.Location - CamOrigin;//Get the direction the player is in from camera origin
     PlayerMagnitude = Sqrt(Square(PlayerDirection.x) + Square(PlayerDirection.y));//Get the distance the player is from the origin


    
    while(PlayerMagnitude > CamLeach)//Player is now pulling the camera
    {
        //Use CustomTimeDilation so camera moves normally when in REACT mode (still has to be redone)
        CamOrigin.x += (PlayerDirection.x * CamSpeedMod) * DeltaTime;
        CamOrigin.y += (PlayerDirection.y * CamSpeedMod) * DeltaTime; 
        return;
    }
    
}

defaultproperties
{
       //Camera Variables\\
   IsoCamAngle=5000 //6420.0 //35.264 degrees
   IsoCamYaw=5000 //7500
   CamOffsetDistance=1500  //800.0
   bFollowPlayer=FALSE
   CamOrigin=(x=-3728,y=600,z=60)
   CamLeach=300
   CamSpeedMod=0.8

}