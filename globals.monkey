Strict

Import fontmachine
Import mojo
Import framework.xgui

Import constants
Import controls
Import game

Global gResX:Float
Global gResY:Float
Global gMaxX:Float
Global gAspectRatio:Float = 1.67
Global gScaleRatio:Float = 1.0

Global gControls:Controls

Global gGameGUI:XGui
Global gAlpha:Float = 1.0

Global gHighscore:Int

Global gFirstCall:Bool = True
Global gLoopTimeAll:Int
Global gLoopTimeStart:Int
Global gLoopTimeEnd:Int
Global gFPSCounter:Int
Global gFPSLastUpdate:Int
Global gRenderTime:Float
Global gRenderTimeAll:Int
Global gFPS:Float
Global gTimeMSOld:Float
Global gDiffTimeMS:Float
Global gDiffTimeSec:Float

Global gGameState:Int = GAME_STATE_INTRO
Global gRequestedState:Int = GAME_STATE_INTRO
Global gParentState:Int = GAME_STATE_INTRO
Global gStateChangeTime:Int = 1

Global gIsLoadingInitialized:Bool = False
Global gGameStartTime:Int = 0
Global gLoadScreenStartTime:Int
Global gLanguages:IntMap< String >
Global gImages:IntMap< Image >
Global gSounds:IntMap< Sound >
Global gSplashScreen:Image = Null
Global gFontMain:BitmapFont
Global gFontNumbers:BitmapFont
Global gGame:Game

Global gSoundEnabled:Bool = True
Global gButtonSoundPlayed:Bool = False
