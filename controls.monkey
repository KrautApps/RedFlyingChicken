Strict

Import mojo

Import constants
Import globals

Class Controls
Private
  Field _currentMouseX:Float[]
  Field _currentMouseY:Float[]
  Field _mousePressedX:Float[]
  Field _mousePressedY:Float[]
  Field _mouseReleasedX:Float[]
  Field _mouseReleasedY:Float[]
  Field _isMousePressed:Bool[]
  Field _isMouseReleased:Bool[]
  Field _numberOfTouchEvents:Int

Public
  Method New()
    _isMousePressed = New Bool[5]
    _isMouseReleased = New Bool[5]
    _currentMouseX = New Float[5]
    _currentMouseY = New Float[5]
    _mousePressedX = New Float[5]
    _mousePressedY = New Float[5]
    _mouseReleasedX = New Float[5]
    _mouseReleasedY = New Float[5]
    For Local i:Int = 0 To 4
      _isMousePressed[i] = False
      _isMouseReleased[i] = False
    Next
    _numberOfTouchEvents = 0
  End Method
  
  Method update:Void()
    _numberOfTouchEvents = 0
    For Local i:Int = 0 To 4
      _currentMouseX[i] = Float( TouchX(i) ) / gScaleRatio
      _currentMouseY[i] = Float( TouchY(i) ) / gScaleRatio
    
      If( TouchDown(i) And _isMousePressed[i] = False )
'        If( gSoundEnabled ) Then PlaySound( gSounds.Get( SFX_CLICK ), SFX_CHANNEL_1 )
        _isMousePressed[i] = True
        _isMouseReleased[i] = False
        _mousePressedX[i] = _currentMouseX[i]
        _mousePressedY[i] = _currentMouseY[i]
      Else If( Not TouchDown(i) And _isMousePressed[i] = True )
        _isMousePressed[i] = False
        _isMouseReleased[i] = True
        _mouseReleasedX[i] = _currentMouseX[i]
        _mouseReleasedY[i] = _currentMouseY[i]
      Else If( TouchDown(i) And _isMousePressed[i] = True )
        _numberOfTouchEvents += 1
      End If
    Next
    'Debug
  End Method
  
  Method getMousePressedX:Float()
    Return _mousePressedX[0]
  End Method

  Method getMousePressedY:Float()
    Return _mousePressedY[0]
  End Method

  Method getMouseReleasedX:Float()
    Return _mouseReleasedX[0]
  End Method

  Method getMouseReleasedY:Float()
    Return _mouseReleasedY[0]
  End Method

  Method getCurrentMouseX:Float()
    Return _currentMouseX[0]
  End Method

  Method getCurrentMouseY:Float()
    Return _currentMouseY[0]
  End Method

  Method isMousePressed:Bool()
    Return ( _numberOfTouchEvents = 1 )
  End Method

  Method isMouseReleased:Bool()
    Return _isMouseReleased[0]
  End Method
End Class
