Attribute VB_Name = "modWatching"
Option Explicit

Type TCamera
    Active As Boolean
    Pos As WorldPos
    UserIndex As Integer
    CreatorIndex As Integer
    ViewersIndex() As Integer
End Type

Dim Cameras() As TCamera

' /watch pepito  - Ver a pepito
' /watch <1,50,50>  - Ver pos 1,50,50
' /watch --  - listar camaras
' /watch -[1] - borrar camara 1
' /watch [1] - ver camara 1
' /watch - salir de camara

Public Function ListCameras() As String
    
    ListCameras = vbNullString
    
    Dim i As Integer
    For i = 1 To UBound(Cameras)
        With Cameras(i)
            If .Active Then
                Dim tempStr As String
                If .UserIndex > 0 Then
                    tempStr = " - Viendo a " & UserList(.UserIndex).Name
                Else
                    tempStr = " - Observando " & .Pos.Map & " " & .Pos.X & " " & .Pos.Y
                End If
            
                ListCameras = ListCameras & "Camara " & i & " " & tempStr & vbCrLf
            End If
        End With
    Next
    
End Function

Public Sub CleanCamera(CameraIndex As Integer)

    With Cameras(CameraIndex)
        .Active = False
        .Pos.Map = 0
        .Pos.X = 0
        .Pos.Y = 0
        .UserIndex = 0
        .CreatorIndex = 0
        ReDim .ViewersIndex(0 To 0)
    End With

End Sub

Public Function ExitFromCamera(OperatorIndex As Integer)
    
    Dim i As Integer
    
    For i = 1 To UBound(Cameras)
        With Cameras(i)
            If .Active Then
                If .CreatorIndex = OperatorIndex Then
                    Call CleanCamera(i)
                Else
                    Dim v As Integer
                    Dim exists As Boolean
                    
                    For v = 1 To UBound(.ViewersIndex)
                        If .ViewersIndex(v) = OperatorIndex Then
                            exists = True
                            Exit For
                        End If
                    Next
                    
                    If exists Then
                        Dim l As Integer
                        Dim PrevViewersIndex() As Integer
                        PrevViewersIndex = .ViewersIndex
                        
                        ReDim .ViewersIndex(1 To UBound(.ViewersIndex) - 1) As Integer
                        For v = 1 To UBound(PrevViewersIndex)
                            If PrevViewersIndex(v) <> OperatorIndex Then
                                l = l + 1
                                .ViewersIndex(l) = PrevViewersIndex(v)
                            End If
                        Next
                    End If
                End If
            End If
        End With
    Next

End Function

Public Function GoToCamera(CameraSelected As Integer, UserIndex As Integer, Pos As WorldPos, OperatorIndex As Integer) As Integer
    
    Dim i As Integer
    Dim CameraIndex As Integer
    
    CameraIndex = 0
        
    If CameraSelected > 0 Then
        
        If Not Cameras(CameraSelected).Active Then
            Exit Function
        End If
        
        With Cameras(CameraSelected)
            Dim exists As Boolean
            exists = False
            For i = 1 To UBound(.ViewersIndex)
                If .ViewersIndex(i) = OperatorIndex Then
                    exists = True
                    Exit For
                End If
            Next
            If Not exists Then
                ReDim Preserve .ViewersIndex(1 To UBound(.ViewersIndex) + 1) As Integer
                .ViewersIndex(UBound(.ViewersIndex)) = OperatorIndex
            End If
        End With
    
    ElseIf UserIndex > 0 Then ' Trackea un usuario

        ' Existe una camara activa que siga a este usuario?
        For i = 1 To UBound(Cameras)
            If Cameras(i).Active = True And Cameras(i).UserIndex = UserIndex Then
                CameraIndex = i
                Exit For
            End If
        Next
        
        ' No encontro camara activa
        If CameraIndex = 0 Then
            ' Buscamos una camara desactivada para "reciclar"
            For i = 1 To UBound(Cameras)
                If Cameras(i).Active = False Then
                    CameraIndex = i
                    Call CleanCamera(CameraIndex)
                    Exit For
                End If
            Next
        End If
        
        ' No encontro camara desactivada?
        If CameraIndex = 0 Then
            ' Crea nueva camara
            ReDim Preserve Cameras(1 To UBound(Cameras) + 1) As TCamera
            CameraIndex = UBound(Cameras)
            Call CleanCamera(CameraIndex)
        End If
        
        With Cameras(CameraIndex)
            If .CreatorIndex = 0 Then
                .Active = True
                .UserIndex = UserIndex
                .CreatorIndex = OperatorIndex
                ReDim .ViewersIndex(1 To 1) As Integer
                .ViewersIndex(1) = OperatorIndex
            Else
                .Active = True
                .UserIndex = UserIndex
                exists = False
                For i = 1 To UBound(.ViewersIndex)
                    If .ViewersIndex(i) = OperatorIndex Then
                        exists = True
                        Exit For
                    End If
                Next
                If Not exists Then
                    ReDim Preserve .ViewersIndex(1 To UBound(.ViewersIndex) + 1) As Integer
                    .ViewersIndex(UBound(.ViewersIndex)) = OperatorIndex
                End If
            End If
        End With
        
    Else 'Observa una posición
    
        'Buscar una camara inactiva
        If CameraIndex = 0 Then
            ' Buscamos una camara desactivada para "reciclar"
            For i = 1 To UBound(Cameras)
                If Cameras(i).Active = False Then
                    CameraIndex = i
                    Call CleanCamera(CameraIndex)
                    Exit For
                End If
            Next
        End If
        
        ' No encontro camara desactivada?
        If CameraIndex = 0 Then
            ' Crea nueva camara
            ReDim Preserve Cameras(1 To UBound(Cameras) + 1) As TCamera
            CameraIndex = UBound(Cameras)
            Call CleanCamera(CameraIndex)
        End If
        
        'Asignarsela
        With Cameras(CameraIndex)
            .Active = True
            .Pos.Map = Pos.Map
            .Pos.X = Pos.X
            .Pos.Y = Pos.Y
            .CreatorIndex = OperatorIndex
            ReDim .ViewersIndex(1 To 1) As Integer
            .ViewersIndex(1) = OperatorIndex
        End With
    
    End If
    
    GoToCamera = CameraIndex

End Function


Function TrySpect(UserIndex As Integer, targetIndex As Integer) As Boolean

    TrySpect = False
    Dim LoopC As Byte
    For LoopC = 1 To MAXSPECTING
        If UserList(targetIndex).flags.Specting(LoopC) = 0 Then
            UserList(targetIndex).flags.Specting(LoopC) = UserIndex
            TrySpect = True
            Exit For
        End If
    Next
    
End Function

Sub EndSpect(UserIndex As Integer, targetIndex As Integer)

    Dim LoopC As Byte
    For LoopC = 1 To MAXSPECTING
        If UserList(targetIndex).flags.Specting(LoopC) = UserIndex Then
            UserList(targetIndex).flags.Specting(LoopC) = 0
        End If
    Next
        
End Sub

Sub StartWatching(UserIndex As Integer, targetIndex As Integer)

    With UserList(UserIndex)
    
        Dim notifySpected As Boolean
        notifySpected = Not IsSomeoneSpecting(targetIndex)
    
        If Not TrySpect(UserIndex, targetIndex) Then
            Call WriteConsoleMsg(UserIndex, "" & UserList(.flags.TargetUser).Name & " ya se encuentra con espectadores.", FontTypeNames.FONTTYPE_INFO)
            Exit Sub
        End If
    
        .flags.TargetUser = targetIndex
        
        .Char.Escribiendo = 0
        Call SendData(SendTarget.ToPCAreaButIndex, UserIndex, PrepareMessageSetTypingFlagToCharIndex(.Char.CharIndex, .Char.Escribiendo))
        
        .flags.Watching = True
        
        If notifySpected Then
            Call WriteModeWatching(targetIndex, 2, 0)
        End If
        Call WriteModeWatching(UserIndex, 1, targetIndex)
        
        .PosAnt.Map = .Pos.Map
        .Pos.Map = 0
        
        .Char.FX = 21
        .Char.loops = INFINITE_LOOPS
        Call modSendData.SendToAreaByPos(.Pos.Map, .Pos.X, .Pos.Y, PrepareMessageCreateFX(.Char.CharIndex, .Char.FX, .Char.loops))
        
        Call WriteUserCharIndexInServer(UserIndex, targetIndex)
        
        'Show the target stats
        Call CloneUserStats(UserIndex, targetIndex)
        'Call WriteUpdateHungerAndThirst(UserIndex, TargetIndex)
        'Call WriteUpdateStrenghtAndDexterity(UserIndex, TargetIndex)
        
        'Show the target Inventory
        Call CloneUserInvs(UserIndex, 0, targetIndex)
        
        'Show the target Spells
        Call CloneUserSpells(UserIndex, 0, targetIndex)
        
        Call WriteConsoleMsg(UserIndex, "Empiezas a espectar a " & UserList(.flags.TargetUser).Name & ".", FontTypeNames.FONTTYPE_INFO)

    End With

End Sub

Sub SendPosUpdateToWatchers(ByVal UserIndex As Integer)

    If UserIndex > 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(UserIndex).flags.Specting(LoopC) <> 0 Then
                Call WritePosUpdate(UserList(UserIndex).flags.Specting(LoopC), UserIndex)
                Call WriteAreaChanged(UserList(UserIndex).flags.Specting(LoopC), UserIndex)
            End If
        Next
    End If

End Sub

Function IsSomeoneSpecting(ByVal UserIndex As Integer) As Boolean
    
    IsSomeoneSpecting = False
    If UserIndex > 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(UserIndex).flags.Specting(LoopC) <> 0 Then
                IsSomeoneSpecting = True
                Exit Function
            End If
        Next
    End If
    

End Function

Sub CloneUserStats(ByVal UserIndex As Integer, Optional targetIndex As Integer)

    If targetIndex <= 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(UserIndex).flags.Specting(LoopC) <> 0 Then
                Call WriteUpdateUserStats(UserList(UserIndex).flags.Specting(LoopC), UserIndex)
            End If
        Next
    Else
       Call WriteUpdateUserStats(UserIndex, targetIndex)
    End If

End Sub
 
Sub CloneUserInvs(ByVal UserIndex As Integer, ByVal Slot As Byte, Optional targetIndex As Integer)

    If targetIndex <= 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(UserIndex).flags.Specting(LoopC) <> 0 Then
                Call WriteChangeInventorySlot(UserList(UserIndex).flags.Specting(LoopC), Slot, UserIndex)
            End If
        Next
    Else
        For LoopC = 1 To UserList(targetIndex).CurrentInventorySlots
            Call WriteChangeInventorySlot(UserIndex, LoopC, targetIndex)
        Next LoopC
    End If

End Sub

Sub CloneUserSpells(ByVal UserIndex As Integer, ByVal Slot As Byte, Optional targetIndex As Integer)

    If targetIndex <= 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(UserIndex).flags.Specting(LoopC) <> 0 Then
                Call reloadSpells(UserList(UserIndex).flags.Specting(LoopC), UserIndex)
            End If
        Next
    Else
        Call reloadSpells(UserIndex, targetIndex)
    End If

End Sub

Sub reloadSpells(ByVal UserIndex As Integer, ByVal targetIndex As Integer)

    Dim LoopC As Integer
    For LoopC = 1 To MAXUSERHECHIZOS
        Call WriteChangeSpellSlot(UserIndex, LoopC, targetIndex)
    Next LoopC
    
End Sub

Sub StopWatching(UserIndex As Integer)

    With UserList(UserIndex)
    
        Call EndSpect(UserIndex, UserList(UserIndex).flags.TargetUser)

        Dim Nombre As String
        Nombre = UserList(.flags.TargetUser).Name
        If LenB(Nombre) = 0 Then
            Nombre = "un usuario."
        End If
        
        Call WriteConsoleMsg(UserIndex, "Dejas de espectar a " & Nombre & ".", FontTypeNames.FONTTYPE_INFO)
        
        .Char.FX = 0
        .Char.loops = 0
        Call modSendData.SendToAreaByPos(.Pos.Map, .Pos.X, .Pos.Y, PrepareMessageCreateFX(.Char.CharIndex, .Char.FX, .Char.loops))
        
        'Update stats
        Call WriteUpdateUserStats(UserIndex)
        Call WriteUpdateHungerAndThirst(UserIndex)
        Call WriteUpdateStrenghtAndDexterity(UserIndex)
        
        'Update Inventory
        Call UpdateUserInv(True, UserIndex, 0)
        
        'Update Spells
        Call UpdateUserHechizos(True, UserIndex, 0)
        
        .Pos.Map = .PosAnt.Map
        .PosAnt.Map = 0
        
        Call WriteUserCharIndexInServer(UserIndex)
        
        If Not IsSomeoneSpecting(.flags.TargetUser) Then
           Call WriteModeWatching(.flags.TargetUser, 0, 0)
        End If
        Call WriteModeWatching(UserIndex, 0, 0)
                    
        .flags.TargetUser = 0
        .flags.Watching = False

    End With
    
End Sub

Sub SendMouseToSpect(ByVal UserIndex As Integer, ByVal PosX As Integer, ByVal PosY As Integer, ByVal State As Byte)

    Dim LoopC As Integer
    For LoopC = 1 To MAXSPECTING
        If UserList(UserIndex).flags.Specting(LoopC) <> 0 Then
            Call WriteWatchingMouse(UserList(UserIndex).flags.Specting(LoopC), PosX, PosY, State)
        End If
    Next

End Sub

Sub ResetWatching(ByVal UserIndex As Integer)

    If UserList(UserIndex).flags.Watching Then
        Call StopWatching(UserIndex)
    End If
    
    Dim LoopC As Integer
    For LoopC = 1 To LastUser
        With UserList(LoopC)
            If .flags.Watching And _
                .flags.TargetUser = UserIndex Then
                Call StopWatching(LoopC)
            End If
        End With
    Next
    

End Sub










