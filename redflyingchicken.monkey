'**********************************************************
' Red Flying Chicken
' 2014 Christoph Schmucker & Martin Leidel
'**********************************************************

Strict

Import mojo
#If TARGET="ios" Or TARGET="android"
  Import brl.admob
#End
Import framework.xgui
Import controls
Import globals
Import init
Import loadScreen
Import utils

Const VERSION:String = "v.1.0.1.9"

Global gRedFlyingChicken:RedFlyingChicken

Function Main:Int()
  gRedFlyingChicken = New RedFlyingChicken()
  Return 0
End Function

Class RedFlyingChicken Extends App
  #If TARGET="ios" Or TARGET="android"
    Field _admob:Admob
    Field _style:Int = 3  'Smart Banner Landscape
    Field _layout:Int = 5 'Bottom Center
    Field _enabled:Bool = True
  #End
  Method OnCreate:Int()
    gIsLoadingInitialized = False
    CheckForResolution()
    InitLoadScreen()
    LoadStatistics()
    #If TARGET="ios" Or TARGET="android"
      _admob = Admob.GetAdmob()
      _admob.ShowAdView( _style, _layout )
    #End
    SetUpdateRate(30)
    Return 0
  End Method

  Method OnUpdate:Int()
    gControls.update()
    gGame.update()
    Return 0
  End Method
  
  Method OnSuspend:Int()
    SaveStatistics()
    Return 0
  End Method
  
  Method OnResume:Int()
    LoadStatistics()
    Return 0
  End Method

  Method OnRender:Int()
    gLoopTimeStart = Millisecs()
    Cls()
    PushMatrix()
      Scale( gScaleRatio, gScaleRatio )
      Select gGameState
        Case GAME_STATE_INTRO
          LoadScreen()
        Case GAME_STATE_GAME
          gGame.draw()
      End Select
    PopMatrix()
    gLoopTimeEnd = Millisecs()
    UpdateFPS()
    Return 0
  End Method
End Class
