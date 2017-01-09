Strict

Import fontmachine
Import mojo

Import xgui
Import xguielement

Const XGUI_BUTTON_LONG_PRESS_TIME:Int = 2000
Const XGUI_BUTTON_STATE_IDLE:Int = 1
Const XGUI_BUTTON_STATE_LONG_PRESSED:Int = 2
Const XGUI_BUTTON_STATE_PRESSED:Int = 3
Const XGUI_BUTTON_STATE_RELEASED:Int = 4
Const XGUI_BUTTON_STATE_DISABLED:Int = 5

Class XGuiButton Implements XGuiElement
Private
  Field _name:String
  Field _image:Image
  Field _imageP:Image
  Field _imageD:Image
  Field _text:String
  Field _font:BitmapFont
  Field _sound:Sound
  Field _soundPlayed:Bool
  Field _yTextOffset:Int
  Field _x:Int
  Field _y:Int
  Field _width:Int
  Field _height:Int
  Field _state:Int
  Field _startDelay:Int
  Field _speed:Float
  Field _amp:Float
  Field _size:Float
  Field _clickStartTime:Int
  Field _clickStartTimeInitialized:Bool
  Field _longPressActivated:Bool
  Field _callback:ButtonCallback

Public
  Method New( callBack:ButtonCallback, name:String, image:Image, imageP:Image, imageD:Image, x:Int, y:Int, sound:Sound, font:BitmapFont,
              text:String, yTextOffset:Int, startDelay:Int, speed:Float, amp:Float )
    _callback = callBack
    _name = name
    _image = image
    _imageP = imageP
    _imageD = imageD
    If( _image )
      _width = image.Width()
      _height = image.Height()
    Else If( _imageP )
      _width = imageP.Width()
      _height = imageP.Height()
    End If
    _x = x
    _y = y
    _sound = sound
    _font = font
    _text = text
    _yTextOffset = yTextOffset
    _startDelay = startDelay
    _speed = speed
    _amp = amp
    _size = 1.0

    _state = XGUI_BUTTON_STATE_IDLE
    _soundPlayed = False
    _clickStartTimeInitialized = False
    _longPressActivated = False
  End Method
  
  Method update:Void( touchPressed:Bool, touchX:Int, touchY:Int, playSound:Bool = True )
    'Nur wenn die Maustaste nicht gedrueckt ist, werden die Mauskoordinaten geupdatet
    'Ansonsten werden die alten verwendet. Das hat den Hintergrund, dass ein Button
    'nur dann als "pressed" erkannt werden soll, wenn der Mauszeiger ueber dem Button
    'ist und erst dann die Maustaste gedrueckt wird.
    'Sind wir ueber einem aktivierbaren Button?
    If( _state = XGUI_BUTTON_STATE_DISABLED ) Then Return
    
    _size *= 1.05
    If( _size > 1.0 ) Then _size = 1.0
    
    If( touchX >= _x-_width/2 And touchX <= _x+_width/2 And touchY >= _y-_height/2 And touchY <= _y+_height/2 )
      If( touchPressed )
        If( _sound And playSound )
          If( Not _soundPlayed )
            PlaySound( _sound )
            _soundPlayed = True
          End If
        End If
        If( Not _clickStartTimeInitialized )
          _clickStartTime = Millisecs()
          _clickStartTimeInitialized = True
        End If
        _state = XGUI_BUTTON_STATE_PRESSED
        _size *= 0.95
        If( _size < 0.9 ) Then _size = 0.9

        'Auf Long-Klick testen
        If( ( Millisecs() - _clickStartTime ) > XGUI_BUTTON_LONG_PRESS_TIME And Not _longPressActivated )
          _state = XGUI_BUTTON_STATE_LONG_PRESSED
          _longPressActivated = True
        End If
      Else If( _state = XGUI_BUTTON_STATE_PRESSED )
        'Der Button war gedrueckt und wird nun losgelassen
        _longPressActivated = False
        _clickStartTimeInitialized = False
        _soundPlayed = False
        _state = XGUI_BUTTON_STATE_RELEASED
        _callback.buttonCallBack( _name )
      End If
    Else
      _state = XGUI_BUTTON_STATE_IDLE
    End If
  End Method

  Method paint:Void()
    'Print "Active ID: " + gActiveGUI.activeHandleID + " handle: " + handleID
    Local scaleX:Float = _size + Sin( Float(Millisecs()+_startDelay)/_speed ) / _amp
    Local scaleY:Float = _size + Cos( Float(Millisecs()+_startDelay)/_speed ) / _amp
    Select _state
      Case XGUI_BUTTON_STATE_IDLE
        If( _image ) Then DrawImage( _image, _x, _y, 0, scaleX, scaleY )
        If( _font )
          PushMatrix()
            Translate( _x, _y+_yTextOffset )
            Scale( scaleX, scaleY )
            _font.DrawText( _text, 0, 0, eDrawAlign.CENTER )
          PopMatrix()
        End If
      Case XGUI_BUTTON_STATE_RELEASED
        If( _image ) Then DrawImage( _image, _x, _y, 0, scaleX, scaleY )
        If( _font )
          PushMatrix()
            Translate( _x, _y+_yTextOffset )
            Scale( scaleX, scaleY )
            _font.DrawText( _text, 0, 0, eDrawAlign.CENTER )
          PopMatrix()
        End If
      Case XGUI_BUTTON_STATE_PRESSED
        If( _imageP )
          DrawImage( _imageP, _x, _y, 0, scaleX, scaleY )
        Else
          If( _image ) Then DrawImage( _image, _x, _y, 0, scaleX, scaleY )
        End If
        If( _font )
          PushMatrix()
            Translate( _x, _y+_yTextOffset )
            Scale( scaleX, scaleY )
            _font.DrawText( _text, 0, 0, eDrawAlign.CENTER )
          PopMatrix()
        End If
      Case XGUI_BUTTON_STATE_LONG_PRESSED
        If( _imageP )
          DrawImage( _imageP, _x, _y, 0, scaleX, scaleY )
        Else
          If( _image ) Then DrawImage( _image, _x, _y, 0, scaleX, scaleY )
        End If
        If( _font )
          PushMatrix()
            Translate( _x, _y+_yTextOffset )
            Scale( scaleX, scaleY )
            _font.DrawText( _text, 0, 0, eDrawAlign.CENTER )
          PopMatrix()
        End If
      Case XGUI_BUTTON_STATE_DISABLED
        If( _imageD ) Then DrawImage( _imageD, _x, _y, 0, scaleX, scaleY )
        If( _font )
          PushMatrix()
            Translate( _x, _y+_yTextOffset )
            Scale( scaleX, scaleY )
            _font.DrawText( _text, 0, 0, eDrawAlign.CENTER )
          PopMatrix()
        End If
    End Select
  End Method
  
  Method enable:Void()
    _state = XGUI_BUTTON_STATE_IDLE
  End Method

  Method disable:Void()
    _state = XGUI_BUTTON_STATE_DISABLED
  End Method
End Class
