Strict

Import fontmachine
Import mojo
Import framework.xgui

Import constants
Import controls
Import globals
Import game
Import utils

Function InitLoadScreen:Void()
  gSplashScreen = LoadImage( "gfx/titlescreen.jpg", 1, Image.MidHandle )
  gFontMain = New BitmapFont( "gfx/fonts/font_24.txt" )
  gFontNumbers = New BitmapFont( "gfx/fonts/fontzahl.txt" )
  gControls = New Controls()
  gGame = New Game()
End Function

Function Initialize:Void()
  gImages = New IntMap< Image >
  gSounds = New IntMap< Sound >
  gLanguages = New IntMap< String >
  gTimeMSOld = Millisecs()

  LoadResources()

  gGameGUI = New XGui( gGame, gScaleRatio )
  gGameGUI.addButton( "Start", gImages.Get( GFX_BUTTON_START ), Null, Null, gMaxX/2, IMGY-120, Null, gFontMain, "START", -16 )
End

Function LoadResources:Void()
  gImages.Set( GFX_BACKGROUND,           LoadImage( "gfx/background.jpg" ) )
  gImages.Set( GFX_FOREGROUND,           LoadImage( "gfx/foreground.png" ) )
  gImages.Set( GFX_LOWER_BAR,            LoadImage( "gfx/lower_bar.png" ) )
  gImages.Set( GFX_UPPER_BAR,            LoadImage( "gfx/upper_bar.png" ) )
  gImages.Set( GFX_GARGOYLE,             LoadImage( "gfx/gargoyle.png", 4, Image.MidHandle ) )
  gImages.Set( GFX_EXPLOSION,            LoadImage( "gfx/explosion.png", 50, 37, 9, Image.MidHandle ) )

  gImages.Set( GFX_BUTTON_START, LoadImage( "gfx/button_start.png", 1, Image.MidHandle ) )
  
  gSounds.Set( SFX_FLAP,      LoadSound( "sfx/flap.wav" ) )
  gSounds.Set( SFX_POINT,     LoadSound( "sfx/point.wav" ) )
  gSounds.Set( SFX_THUMP,     LoadSound( "sfx/thump.wav" ) )
  gSounds.Set( SFX_BURNING,   LoadSound( "sfx/burning.wav" ) )
  gSounds.Set( SFX_GAME_OVER, LoadSound( "sfx/gameover.wav" ) )
End Function

Function CleanUpResources:Void()
  For Local img:Image = Eachin gImages.Values()
    img.Discard()
  Next
  For Local sfx:Sound = Eachin gSounds.Values()
    sfx.Discard()
  Next
  gImages.Clear()
  gSounds.Clear()
End Function
