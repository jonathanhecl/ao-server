VERSION 5.00
Object = "{48E59290-9880-11CF-9754-00AA00C00908}#1.0#0"; "MSINET.OCX"
Object = "{33D38DA7-F4D2-4EDB-85C4-4DC9E7E096EB}#5.0#0"; "AOProgress.ocx"
Begin VB.Form frmCargando 
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   0  'None
   Caption         =   "Argentum"
   ClientHeight    =   3480
   ClientLeft      =   1410
   ClientTop       =   3000
   ClientWidth     =   6585
   ControlBox      =   0   'False
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   292.725
   ScaleMode       =   0  'User
   ScaleWidth      =   439
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      Height          =   2895
      Left            =   0
      ScaleHeight     =   2895
      ScaleWidth      =   6615
      TabIndex        =   0
      Top             =   0
      Width           =   6615
      Begin InetCtlsObjects.Inet Inet1 
         Left            =   1440
         Top             =   1200
         _ExtentX        =   1005
         _ExtentY        =   1005
         _Version        =   393216
      End
   End
   Begin AOProgress.uAOProgress cargar 
      Height          =   615
      Left            =   0
      TabIndex        =   1
      Top             =   2880
      Width           =   6615
      _ExtentX        =   11668
      _ExtentY        =   1085
      Min             =   1
      Value           =   1
      Animate         =   0   'False
      ShadowTextColor =   16744576
      BackColor       =   16744576
      BackAddColor    =   4934475
      BackSubColor    =   8224125
      CustomText      =   "Cargando"
      BeginProperty FONT {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Morpheus"
         Size            =   15
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      BeginProperty FONT {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Morpheus"
         Size            =   15
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
   End
End
Attribute VB_Name = "frmCargando"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Argentum Online 0.12.2
'Copyright (C) 2002 Marquez Pablo Ignacio
'
'This program is free software; you can redistribute it and/or modify
'it under the terms of the Affero General Public License;
'either version 1 of the License, or any later version.
'
'This program is distributed in the hope that it will be useful,
'but WITHOUT ANY WARRANTY; without even the implied warranty of
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'Affero General Public License for more details.
'
'You should have received a copy of the Affero General Public License
'along with this program; if not, you can find it at http://www.affero.org/oagpl.html
'
'Argentum Online is based on Baronsoft's VB6 Online RPG
'You can contact the original creator of ORE at aaron@baronsoft.com
'for more information about ORE please visit http://www.baronsoft.com/
'
'
'You can contact me at:
'morgolock@speedy.com.ar
'www.geocities.com/gmorgolock
'Calle 3 numero 983 piso 7 dto A
'La Plata - Pcia, Buenos Aires - Republica Argentina
'Codigo Postal 1900
'Pablo Ignacio Marquez

Option Explicit

Private VersionNumberMaster As String
Private VersionNumberLocal As String

Private Sub Form_Load()
    cargar.CustomText = GetVersionOfTheServer()
    Picture1.Picture = LoadPicture(App.Path & "\logo.jpg")
    Me.VerifyIfUsingLastVersion
End Sub

Function VerifyIfUsingLastVersion()

    On Error Resume Next
           
    If Not (CheckIfRunningLastVersion) Then
        If MsgBox("Tu version no es la actual, Deseas ejecutar el actualizador?. - Tu version: " & VersionNumberLocal & " Ultima version: " & VersionNumberMaster & " -- Your version is not up to date, open the launcher to update? ", vbYesNo) = vbYes Then
            Call ShellExecute(Me.hWnd, "open", App.Path & "\Autoupdate.exe", "", "", 1)
            End

        End If

    End If

End Function

Private Function CheckIfRunningLastVersion() As Boolean

    Dim responseGithub As String

    Dim JsonObject     As Object

    responseGithub = Inet1.OpenURL("https://api.github.com/repos/ao-libre/ao-server/releases/latest")

    If Len(responseGithub) = 0 Then Exit Function

    Set JsonObject = JSON.parse(responseGithub)
    
    VersionNumberMaster = JsonObject.Item("tag_name")
    VersionNumberLocal = GetVar(App.Path & "\Server.ini", "INIT", "VersionTagRelease")
    
    If VersionNumberMaster = VersionNumberLocal Then
        CheckIfRunningLastVersion = True
    Else
        CheckIfRunningLastVersion = False

    End If

End Function
