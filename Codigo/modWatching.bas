Attribute VB_Name = "modWatching"
Option Explicit

' TODO:
' 1. Poner el estado <Espectando> en el nick.

Function TrySpect(Userindex As Integer, targetIndex As Integer) As Boolean

    TrySpect = False
    Dim LoopC As Byte
    For LoopC = 1 To MAXSPECTING
        If UserList(targetIndex).flags.Specting(LoopC) = 0 Then
            UserList(targetIndex).flags.Specting(LoopC) = Userindex
            TrySpect = True
            Exit For
        End If
    Next
    
End Function

Sub EndSpect(Userindex As Integer, targetIndex As Integer)

    Dim LoopC As Byte
    For LoopC = 1 To MAXSPECTING
        If UserList(targetIndex).flags.Specting(LoopC) = Userindex Then
            UserList(targetIndex).flags.Specting(LoopC) = 0
        End If
    Next
        
End Sub

Sub WatchingPlayer(Userindex As Integer, targetIndex As Integer)

    With UserList(Userindex)
    
        Dim notifySpected As Boolean
        notifySpected = Not IsSomeoneSpecting(targetIndex)
    
        If Not TrySpect(Userindex, targetIndex) Then
            Call WriteConsoleMsg(Userindex, "" & UserList(.flags.TargetUser).Name & " ya se encuentra con espectadores.", FontTypeNames.FONTTYPE_INFO)
            Exit Sub
        End If
    
        .flags.TargetUser = targetIndex
        
        .Char.Escribiendo = 0
        Call SendData(SendTarget.ToPCAreaButIndex, Userindex, PrepareMessageSetTypingFlagToCharIndex(.Char.CharIndex, .Char.Escribiendo))
        
        .flags.Watching = True
        
        If notifySpected Then
            Call WriteModeWatching(targetIndex, 2)
        End If
        Call WriteModeWatching(Userindex, 1)
        
        .PosAnt.Map = .Pos.Map
        .Pos.Map = 0
        
        .Char.FX = 21
        .Char.loops = INFINITE_LOOPS
        Call modSendData.SendToAreaByPos(.Pos.Map, .Pos.X, .Pos.Y, PrepareMessageCreateFX(.Char.CharIndex, .Char.FX, .Char.loops))
        
        'Show the target stats
        Call CloneUserStats(Userindex, targetIndex)
        'Call WriteUpdateHungerAndThirst(UserIndex, TargetIndex)
        'Call WriteUpdateStrenghtAndDexterity(UserIndex, TargetIndex)
        
        'Show the target Inventory
        Call CloneUserInvs(Userindex, 0, targetIndex)
        
        'Show the target Spells
        Call CloneUserSpells(Userindex, 0, targetIndex)
        
        Call WriteConsoleMsg(Userindex, "Empiezas a espectar a " & UserList(.flags.TargetUser).Name & ".", FontTypeNames.FONTTYPE_INFO)

    End With

End Sub

Function IsSomeoneSpecting(ByVal Userindex As Integer) As Boolean
    
    IsSomeoneSpecting = False
    If Userindex > 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(Userindex).flags.Specting(LoopC) <> 0 Then
                IsSomeoneSpecting = True
                Exit Function
            End If
        Next
    End If
    

End Function

Sub CloneUserStats(ByVal Userindex As Integer, Optional targetIndex As Integer)

    If targetIndex <= 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(Userindex).flags.Specting(LoopC) <> 0 Then
                Call WriteUpdateUserStats(UserList(Userindex).flags.Specting(LoopC), Userindex)
            End If
        Next
    Else
       Call WriteUpdateUserStats(Userindex, targetIndex)
    End If

End Sub

Sub CloneUserInvs(ByVal Userindex As Integer, ByVal Slot As Byte, Optional targetIndex As Integer)

    If targetIndex <= 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(Userindex).flags.Specting(LoopC) <> 0 Then
                Call WriteChangeInventorySlot(UserList(Userindex).flags.Specting(LoopC), Slot, Userindex)
            End If
        Next
    Else
        For LoopC = 1 To UserList(targetIndex).CurrentInventorySlots
            Call WriteChangeInventorySlot(Userindex, LoopC, targetIndex)
        Next LoopC
    End If

End Sub

Sub CloneUserSpells(ByVal Userindex As Integer, ByVal Slot As Byte, Optional targetIndex As Integer)

    If targetIndex <= 0 Then
        Dim LoopC As Integer
        For LoopC = 1 To MAXSPECTING
            If UserList(Userindex).flags.Specting(LoopC) <> 0 Then
                Call reloadSpells(UserList(Userindex).flags.Specting(LoopC), Userindex)
            End If
        Next
    Else
        Call reloadSpells(Userindex, targetIndex)
    End If

End Sub

Sub reloadSpells(ByVal Userindex As Integer, ByVal targetIndex As Integer)

    Dim LoopC As Integer
    For LoopC = 1 To MAXUSERHECHIZOS
        Call WriteChangeSpellSlot(Userindex, LoopC, targetIndex)
    Next LoopC
    
End Sub

Sub StopWatching(Userindex As Integer)

    With UserList(Userindex)
    
        Call EndSpect(Userindex, UserList(Userindex).flags.TargetUser)

        Dim Nombre As String
        Nombre = UserList(.flags.TargetUser).Name
        If LenB(Nombre) = 0 Then
            Nombre = "un usuario."
        End If
        
        Call WriteConsoleMsg(Userindex, "Dejas de espectar a " & Nombre & ".", FontTypeNames.FONTTYPE_INFO)
        
        .Char.FX = 0
        .Char.loops = 0
        Call modSendData.SendToAreaByPos(.Pos.Map, .Pos.X, .Pos.Y, PrepareMessageCreateFX(.Char.CharIndex, .Char.FX, .Char.loops))
        
        'Update stats
        Call WriteUpdateUserStats(Userindex)
        Call WriteUpdateHungerAndThirst(Userindex)
        Call WriteUpdateStrenghtAndDexterity(Userindex)
        
        'Update Inventory
        Call UpdateUserInv(True, Userindex, 0)
        
        'Update Spells
        Call UpdateUserHechizos(True, Userindex, 0)
        
        .Pos.Map = .PosAnt.Map
        .PosAnt.Map = 0
        
        If Not IsSomeoneSpecting(.flags.TargetUser) Then
           Call WriteModeWatching(.flags.TargetUser, 0)
        End If
        Call WriteModeWatching(Userindex, 0)
                    
        .flags.TargetUser = 0
        .flags.Watching = False

    End With
    
End Sub

Sub SendMouseToSpect(ByVal Userindex As Integer, ByVal PosX As Integer, ByVal PosY As Integer, ByVal State As Byte)

    Dim LoopC As Integer
    For LoopC = 1 To MAXSPECTING
        If UserList(Userindex).flags.Specting(LoopC) <> 0 Then
            Call WriteWatchingMouse(UserList(Userindex).flags.Specting(LoopC), PosX, PosY, State)
        End If
    Next

End Sub

Sub ResetWatching(ByVal Userindex As Integer)

    If UserList(Userindex).flags.Watching Then
        Call StopWatching(Userindex)
    End If
    
    Dim LoopC As Integer
    For LoopC = 1 To LastUser
        With UserList(LoopC)
            If .flags.Watching And _
                .flags.TargetUser = Userindex Then
                Call StopWatching(LoopC)
            End If
        End With
    Next
    

End Sub










