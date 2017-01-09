Strict

Import mojo

Import constants
Import globals
Import game
Import init
Import redflyingchicken

Const LOADTIME:Int = 3000

Function LoadScreen:Void()
  Cls()
  If( gFirstCall )
    gFirstCall = False
    gGameStartTime = Millisecs()
  End If
  'Fade in Splash Screen and display it for at least 3 seconds
  If( ( Millisecs() - gGameStartTime ) < 1000 )
    DrawImage( gSplashScreen, gMaxX/2, IMGY/2 )
    gFontMain.DrawText( VERSION, gMaxX-20, IMGY - 40, eDrawAlign.RIGHT )
    Return
  Else If( ( Millisecs() - gGameStartTime ) < LOADTIME )
    gAlpha = 1.0
    SetAlpha( gAlpha )
    DrawImage( gSplashScreen, gMaxX/2, IMGY/2 )
    gFontMain.DrawText( VERSION, gMaxX-20, IMGY - 40, eDrawAlign.RIGHT )
    If( Not gIsLoadingInitialized )
      gIsLoadingInitialized = True
      Initialize()
    End If

  'Fade out Splash Screen
  Else If( ( Millisecs() - gGameStartTime ) < (LOADTIME+1000) )
    gAlpha = 1.0 - Float( Millisecs() - gGameStartTime - (LOADTIME+0) ) / 1000.0
    SetAlpha( gAlpha )
    DrawImage( gSplashScreen, gMaxX/2, IMGY/2 )
    gFontMain.DrawText( VERSION, gMaxX-20, IMGY - 40, eDrawAlign.RIGHT )
  Else If( ( Millisecs() - gGameStartTime ) < (LOADTIME+2000) )
    gRequestedState = GAME_STATE_GAME
    gAlpha = Float( Millisecs() - gGameStartTime - (LOADTIME+1000) ) / 1000.0
    SetAlpha( gAlpha )
    gGame.draw()
  Else If( ( Millisecs() - gGameStartTime ) < (LOADTIME+2000) )
    gAlpha = 1.0
    SetAlpha( gAlpha )
    gGame.draw()
  Else
    gGameState = GAME_STATE_GAME
    gRequestedState = gGameState
    gSplashScreen.Discard()
    gAlpha = 1.0
    SetAlpha( gAlpha )
    gGame.draw()
  End If
End Function
