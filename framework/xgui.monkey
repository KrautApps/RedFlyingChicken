Strict

Import fontmachine
Import mojo

Import xguibutton
Import xguielement

Interface ButtonCallback
  Method buttonCallBack:Void( buttonName:String )
End Interface

Class XGui
Private
  Field _callback:ButtonCallback
  Field _elements:List<XGuiElement>
  Field _scaleRatio:Float
  Field _translateY:Float
  Field _touchX:Float
  Field _touchY:Float
  Field _touchPressed:Bool

Public
  Method New( callback:ButtonCallback, scaleRatio:Float, translateY:Float = 0.0 )
    _callback = callback
    _scaleRatio = scaleRatio
    _translateY = translateY
    _touchPressed = False
    _elements = New List<XGuiElement>
  End Method
  
  Method addButton:XGuiButton( name:String, image:Image, imageP:Image, imageD:Image, x:Int, y:Int, sound:Sound = Null, font:BitmapFont = Null,
                               text:String = "", yTextOffset:Int = 0, startDelay:Int = 0, speed:Float = 5.0, amp:Float = 80.0 )
    Local button:XGuiButton = New XGuiButton( _callback, name, image, imageP, imageD, x, y, sound, font, text, yTextOffset, startDelay, speed, amp )
    _elements.AddLast( button )
    Return button
  End Method
  
  Method update:Void()
    _touchX = Float( TouchX(0) ) / _scaleRatio
    _touchY = Float( TouchY(0) ) / _scaleRatio - _translateY
    If( TouchDown(0) )
      _touchPressed = True
    Else
      _touchPressed = False
    End If

    For Local button:XGuiElement = EachIn _elements
      button.update( _touchPressed, _touchX, _touchY )
    Next
  End Method
  
  Method paint:Void()
    For Local button:XGuiElement = EachIn _elements
      button.paint()
    Next
  End Method
End Class
