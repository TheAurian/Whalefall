//  ================================================================================================
//   * File Name:    ReactGameInfo
//   * Created By:   Byron
//   * Time Stamp:     3/7/2014 12:46:53 PM
//   * UDK Path:   C:\UDK\UDK-2013-02
//   * Unreal X-Editor v3.1.4.0
//   * © Copyright 2012 - 2014. All Rights Reserved.
//  ================================================================================================

class ReactGameInfo extends GameInfo;

var ReactGameCamera mainCamera;

defaultproperties
{
    bDelayedStart=false
    PlayerControllerClass=class'ReactProtoTwo.PlayerControllerBase'
    DefaultPawnClass=class'ReactProtoTwo.ToroaPawn'
}