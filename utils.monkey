Strict

Import globals

'Set up aspect ratio stuff
Function CheckForResolution:Void()
  gResX = Float( DeviceWidth() )
  gResY = Float( DeviceHeight() )
  gAspectRatio = gResX / gResY
  gScaleRatio = gResY / IMGY
  gMaxX = gResX / gScaleRatio
End Function

Function UpdateFPS:Void()
  gLoopTimeAll = gLoopTimeEnd - gLoopTimeStart
  gRenderTimeAll = gRenderTimeAll + gLoopTimeAll
  gDiffTimeMS = Millisecs() - gTimeMSOld
  gDiffTimeSec = gDiffTimeMS / 1000.0
  gTimeMSOld = Millisecs()
  
  gFPSCounter = gFPSCounter + 1
  If( ( gLoopTimeStart - gFPSLastUpdate ) > 500 )
    gRenderTime = Float( gRenderTimeAll ) / Float( gFPSCounter )
    If( gRenderTime < 1.0 ) Then gRenderTime = 1.0
    gRenderTimeAll = 0
    gFPSLastUpdate = gLoopTimeStart
    gFPS = 1000.0 / gRenderTime
    gFPSCounter = 0
  End If
End Function

Class ArrayUtil<T>
  Function CreateArray:T[][]( rows:Int, cols:Int )
    Local a:T[][] = New T[rows][]
    For Local i:Int = 0 Until rows
      a[i] = New T[cols]
    End
    
    Return a
  End Function

  Function FillArray:Void( arr:T[][], xSize:Int, ySize:Int, val:T )
    For Local x:Int = 0 Until xSize
      For Local y:Int = 0 Until ySize
        arr[x][y] = val
      Next
    Next
  End Function
End Class

Function GetDist:Float( x1:Float, y1:Float, x2:Float, y2:Float )
  Return Sqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) )
End Function

Function IntToString:String( value:Int )
  Local v:String
  Local wasNegative:Bool = False
  If( value < 0 )
    wasNegative = True
    value = Abs( value )
  End If
  If( value < 10 )
    v = "0,0" + String( value )
  Else If( value < 100 )
    v = "0," + String( value )
  Else
    Local l:Int = value / 100
    Local ls:String = String( l )
    Local r:Int = value-l*100
    Local rs:String = String( r )
    v = ls + ","
    If( r < 10 ) Then v += "0"
    v += rs
  End If
  If( wasNegative ) Then v = "-" + v
  Return v
End Function

Function CheckFileConsistency:Void()
  Return
  Local stats:String = LoadState()
  'Gibt es noch keine Stats?
  If( stats.Length() = 0 )
    SaveStatistics()
    Return
  Else
    Local values:String[] = stats.Split( "," )
    If( values.Length() < 42 )
      'Oh oh...
      'Alles auf Null!
      gSoundEnabled = True
      SaveStatistics()
      Return
    End If
  End If
End Function

Function LoadStatistics:Void()
  Local stats:String = LoadState()
  If( stats.Length() = 0 )
    SaveState( "0" )
    Return
  End If
  gHighscore = Int( stats )
End Function

Function SaveStatistics:Void()
  Local stats:String = String( gHighscore )
  SaveState( stats )
End Function
