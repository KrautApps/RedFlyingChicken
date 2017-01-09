Strict

Import mojo
Import framework.xgui
Import constants
Import globals
Import redflyingchicken
Import utils

Const STATE_MENU:Int = 1
Const STATE_RUNNING:Int = 2
Const STATE_GAME_OVER:Int = 3
Const STATE_GAME_OVER_RESTART:Int = 4

Const UPPER_BOUNDARY:Int = 32
Const LOWER_BOUNDARY:Int = 360-24

Class Bar
  Field _x:Float
  Field _lowerY:Int
  Field _upperY:Int
  Field _centerY:Int
  
  Method paint:Void()
    DrawImage( gImages.Get( GFX_LOWER_BAR ), _x, _lowerY )
    DrawImage( gImages.Get( GFX_UPPER_BAR ), _x, _upperY )
  End Method
End Class

Class Game Implements ButtonCallback
Private
  Field _score:Int
  Field _backgroundX:Int
  Field _foregroundX:Int
  Field _state:Int
  Field _xPos:Int
  Field _yPos:Float
  Field _acceleration:Float
  Field _bars:List<Bar>
  Field _gameOverStartTime:Int
  Field _touchPressed:Bool = False
  Field _currentPassingBar:Bar
  Field _soundChannel:Int
  Field _playFlapSound:Bool
  Field _thumpSoundPlayed:Bool
  Field _gameOverSoundPlayed:Bool
  Field _currentScoreCounter:Int
  Field _playScoreSound:Bool
  Field _titleMusicStarted:Bool
  Field _adsVisible:Bool

Public
  Method New()
    _score = 0
    _backgroundX = 0
    _foregroundX = 0
    _state = STATE_MENU
    _xPos = gMaxX / 2
    _yPos = IMGY - 200
    _acceleration = 0.0
    _gameOverStartTime = 0
    _bars = New List<Bar>
    _currentPassingBar = Null
    _soundChannel = 0
    _playFlapSound = False
    _thumpSoundPlayed = False
    _gameOverSoundPlayed = False
    _currentScoreCounter = 0
    _playScoreSound = False
    _titleMusicStarted = False
    _adsVisible = False
  End Method
  
  Method buttonCallBack:Void( buttonName:String )
    _state = STATE_RUNNING
    _bars.Clear()
    _score = 0
    _playFlapSound = False
    _thumpSoundPlayed = False
    _gameOverSoundPlayed = False
    _currentScoreCounter = 0
    _playScoreSound = False
  End Method

  Method update:Void()
    Select _state
      Case STATE_MENU
        Return
      Case STATE_RUNNING
        If( _xPos > 140 ) Then _xPos -= 4
        If( gControls.isMousePressed() And Not _touchPressed )
          _acceleration = -6.0
          _touchPressed = True
          _playFlapSound = True
        Else If( gControls.isMouseReleased() )
          _touchPressed = False
        End If
    
        _acceleration += 0.5
        _yPos += _acceleration
        If( _bars.Count() = 0 )
          'No bar yet, add one!
          Local bar:Bar = New Bar()
          bar._x = 720
          bar._lowerY = IMGY - Int( Rnd( 64, 201 ) )
          bar._centerY = bar._lowerY - 40
          bar._upperY = bar._lowerY - 256 - 80
          _bars.AddLast( bar )
        Else If( _bars.Count() < 4 )
          'Get last bar to see if we can another one
          Local bar:Bar = _bars.Last()
          If( bar._x < 500 )
            Local newBar:Bar = New Bar()
            newBar._x = 720
            newBar._lowerY = IMGY - Int( Rnd( 64, 201 ) )
            newBar._centerY = newBar._lowerY - 40
            newBar._upperY = newBar._lowerY - 256 - 80
            _bars.AddLast( newBar )
          End If
        End If
        If( checkForCollision() )
          'Collision happened! Game Over!
          _state = STATE_GAME_OVER
          _gameOverStartTime = Millisecs()
        End If
        'Check for a passed bar
        If( _currentPassingBar )
          If( ( _currentPassingBar._x - _xPos ) < -90 )
            _score += 1
            _currentPassingBar = Null
            _playScoreSound = True
          End If
        End If
 
      Case STATE_GAME_OVER
        _acceleration += 1.0
        _yPos += _acceleration
        If( _yPos > LOWER_BOUNDARY )
          _yPos = LOWER_BOUNDARY
          _acceleration = 0.0
        End If
        Local dt:Int = Millisecs() - _gameOverStartTime
        If( gControls.isMousePressed() And dt > 2000 )
          _state = STATE_GAME_OVER_RESTART
        End If
      Case STATE_GAME_OVER_RESTART
        If( gControls.isMouseReleased() )
          _state = STATE_MENU
          _xPos = gMaxX / 2
          _yPos = IMGY - 200
          _acceleration = 0.0
          _gameOverStartTime = 0
          _bars.Clear()
          If( _score > gHighscore )
            gHighscore = _score
            SaveStatistics()
          End If
          _score = 0
          _currentPassingBar = Null
          _playScoreSound = False
        End If
    End Select

  End Method
  
  Method draw:Void()
    DrawImage( gImages.Get( GFX_BACKGROUND ), _backgroundX, 0, 0, 2, 2 )
    DrawImage( gImages.Get( GFX_BACKGROUND ), _backgroundX+2048, 0, 0, 2, 2 )
    For Local bar:Bar = EachIn _bars
      bar.paint()
    Next
    DrawImage( gImages.Get( GFX_FOREGROUND ), _foregroundX, 0, 0, 2, 2 )
    DrawImage( gImages.Get( GFX_FOREGROUND ), _foregroundX+2048, 0, 0, 2, 2 )
    Local frame:Int = ( Millisecs() Mod 600 ) / 150
    Local angle:Float = -3.0*_acceleration
    gFontMain.DrawText( "Score:", 10, 15 )
    gFontNumbers.DrawText( _score, 104, 15 )
    Local txtWidth:Float = gFontNumbers.GetTxtWidth( gHighscore )
    gFontMain.DrawText( "Highscore:", gMaxX-10-txtWidth, 15, eDrawAlign.RIGHT )
    gFontNumbers.DrawText( gHighscore, gMaxX-10, 15, eDrawAlign.RIGHT )

    Select _state
      Case STATE_MENU
        #If TARGET="ios" Or TARGET="android"
          If( Not _adsVisible )
            gGargoyles._admob.ShowAdView( gGargoyles._style, gGargoyles._layout )
            _adsVisible = True
          End If
        #End
        If( Not _titleMusicStarted )
          StopMusic()
          PlayMusic( "sfx/music.mp3" )
          SetMusicVolume( 0.15 )
          _titleMusicStarted = True
        End If
        _backgroundX -= 1
        If( _backgroundX < -2048 ) Then _backgroundX = 0
        _foregroundX -= 4
        If( _foregroundX < -2048 ) Then _foregroundX = 0
    
        DrawImage( gImages.Get( GFX_GARGOYLE ), _xPos, _yPos, angle, 1, 1, frame )

        gGameGUI.update()
        gGameGUI.paint()
      Case STATE_RUNNING
        #If TARGET="ios" Or TARGET="android"
          If( _adsVisible )
            gGargoyles._admob.HideAdView()
            _adsVisible = False
          End If
        #End
        _titleMusicStarted = False  'to restart the music
        If( _playScoreSound )
          PlaySound( gSounds.Get( SFX_POINT ), _soundChannel )
          _soundChannel += 1
          If( _soundChannel > 7 ) Then _soundChannel = 0
          _playScoreSound = False
        End If
        _backgroundX -= 1
        If( _backgroundX < -2048 ) Then _backgroundX = 0
        _foregroundX -= 4
        If( _foregroundX < -2048 ) Then _foregroundX = 0
    
        DrawImage( gImages.Get( GFX_GARGOYLE ), _xPos, _yPos, angle, 1, 1, frame )
        If( _playFlapSound )
          PlaySound( gSounds.Get( SFX_FLAP ), _soundChannel )
          _playFlapSound = False
          _soundChannel += 1
          If( _soundChannel > 7 ) Then _soundChannel = 0
        End If

        For Local bar:Bar = EachIn _bars
          bar._x -= 4
          If( bar._x < -64 ) Then _bars.Remove( bar )
        Next
      Case STATE_GAME_OVER, STATE_GAME_OVER_RESTART
        If( Not _thumpSoundPlayed )
          _thumpSoundPlayed = True
          PlaySound( gSounds.Get( SFX_THUMP ), _soundChannel )
          _soundChannel += 1
          PlaySound( gSounds.Get( SFX_BURNING ), _soundChannel )
          _soundChannel += 1
          If( _soundChannel > 7 ) Then _soundChannel = 0
        End If
        Local dt:Int = Millisecs() - _gameOverStartTime
        Local dragonAlpha:Float = 1.0
        If( dt < 500 )
          Local scale:Float = 1.5 - Float( dt ) / 1000.0
          Local alpha:Float = Float( dt ) / 500.0
          dragonAlpha = 1.0 - alpha
          SetAlpha( alpha )
          PushMatrix()
            Translate( gMaxX/2, 160 )
            Scale( scale, scale )
            gFontMain.DrawText( "Game Over!", 0, 0, eDrawAlign.CENTER )
          PopMatrix()
        Else If( dt < 1000 )
          Local scale:Float = 1.5 - Float( dt-500 ) / 1000.0
          Local alpha:Float = Float( dt-500 ) / 500.0
          dragonAlpha = 0.0
          SetAlpha( alpha )
          If( _score > gHighscore )
            Local width:Float = ( gFontMain.GetTxtWidth( "New Highscore: " ) + gFontNumbers.GetTxtWidth( "0" ) ) / 2.0
            gFontMain.DrawText( "New Highscore: ", gMaxX/2-width, 200, eDrawAlign.LEFT )
            gFontNumbers.DrawText( "0", gMaxX/2+width, 200, eDrawAlign.RIGHT )
          Else
            Local width:Float = ( gFontMain.GetTxtWidth( "Score: " ) + gFontNumbers.GetTxtWidth( "0" ) ) / 2.0
            gFontMain.DrawText( "Score: ", gMaxX/2-width, 200, eDrawAlign.LEFT )
            gFontNumbers.DrawText( "0", gMaxX/2+width, 200, eDrawAlign.RIGHT )
          End If
          SetAlpha( gAlpha )
          gFontMain.DrawText( "Game Over!", gMaxX/2, 160, eDrawAlign.CENTER )
        Else
          If( Not _gameOverSoundPlayed )
            _gameOverSoundPlayed = True
            PlaySound( gSounds.Get( SFX_GAME_OVER ), _soundChannel )
            _soundChannel += 1
            If( _soundChannel > 7 ) Then _soundChannel = 0
          End If
          dragonAlpha = 0.0
          SetAlpha( gAlpha )
          gFontMain.DrawText( "Game Over!", gMaxX/2, 160, eDrawAlign.CENTER )
          If( _score > gHighscore )
            _currentScoreCounter += 1
            If( _currentScoreCounter > _score ) Then _currentScoreCounter = _score
            Local width:Float = ( gFontMain.GetTxtWidth( "New Highscore: " ) + gFontNumbers.GetTxtWidth( _currentScoreCounter ) ) / 2.0
            gFontMain.DrawText( "New Highscore: ", gMaxX/2-width, 200, eDrawAlign.LEFT )
            gFontNumbers.DrawText( _currentScoreCounter, gMaxX/2+width, 200, eDrawAlign.RIGHT )
          Else
            _currentScoreCounter += 1
            If( _currentScoreCounter > _score ) Then _currentScoreCounter = _score
            Local width:Float = ( gFontMain.GetTxtWidth( "Score: " ) + gFontNumbers.GetTxtWidth( _currentScoreCounter ) ) / 2.0
            gFontMain.DrawText( "Score: ", gMaxX/2-width, 200, eDrawAlign.LEFT )
            gFontNumbers.DrawText( _currentScoreCounter, gMaxX/2+width, 200, eDrawAlign.RIGHT )
          End If
        End If
        SetAlpha( dragonAlpha )
        DrawImage( gImages.Get( GFX_GARGOYLE ), _xPos, _yPos, angle, 1, 1, 0 )
        SetAlpha( gAlpha )
        'Play Explosion
        If( dt < 900 )
          Local frame:Int = dt / 100
          DrawImage( gImages.Get( GFX_EXPLOSION ), _xPos, _yPos, 0, 2, 2, frame )
        End If
    End Select
  End Method
  
  Method checkForCollision:Bool()
    'Is the gargoyle above or below boundaries?
    If( _yPos < UPPER_BOUNDARY Or _yPos > LOWER_BOUNDARY ) Then Return True
    
    'Check for collision with bars
    For Local bar:Bar = EachIn _bars
      'Are we within a bar?
      If( ( bar._x - _xPos ) > -86 And ( bar._x - _xPos ) < 24 )
        'Yes! Check if we are between both!
        'Print "dy: " + Abs( _yPos - bar._centerY )
        'Remember this bar
        _currentPassingBar = bar
        If( Abs( _yPos - bar._centerY ) > 30 ) Then Return True
      End If
    Next
    Return False
  End Method
End Class
