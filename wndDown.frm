VERSION 5.00
Begin VB.Form wndDown 
   AutoRedraw      =   -1  'True
   BackColor       =   &H80000005&
   BorderStyle     =   0  'None
   Caption         =   "Form2"
   ClientHeight    =   3360
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3195
   ClipControls    =   0   'False
   LinkTopic       =   "Form2"
   ScaleHeight     =   224
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   213
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.PictureBox pScroller 
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      Height          =   2655
      Left            =   180
      ScaleHeight     =   177
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   181
      TabIndex        =   0
      Top             =   360
      Width           =   2715
      Begin VB.VScrollBar vsb 
         Height          =   2295
         Left            =   2220
         Max             =   115
         SmallChange     =   100
         TabIndex        =   3
         TabStop         =   0   'False
         Top             =   120
         Width           =   255
      End
      Begin VB.PictureBox picGroup 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BorderStyle     =   0  'None
         ForeColor       =   &H80000008&
         Height          =   2295
         Left            =   60
         ScaleHeight     =   153
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   137
         TabIndex        =   1
         Top             =   120
         Width           =   2055
         Begin VB.Timer timUpdate 
            Enabled         =   0   'False
            Interval        =   1
            Left            =   1260
            Top             =   600
         End
         Begin VB.Image ImgItem 
            Height          =   240
            Index           =   0
            Left            =   60
            Stretch         =   -1  'True
            Top             =   0
            Width           =   240
         End
         Begin VB.Label lblCaption 
            BackColor       =   &H80000005&
            Caption         =   "Item-0"
            Height          =   255
            Index           =   0
            Left            =   420
            TabIndex        =   2
            Top             =   60
            Visible         =   0   'False
            Width           =   3315
         End
      End
   End
End
Attribute VB_Name = "wndDown"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''
''      ControlName:    ISCombo.
''      Version:        2.10
''      Author:         Alfredo Córdova Pérez ( fred_cpp )
''      e-mail:         fred_cpp@hotmail.com
''                      fred_cpp@yahoo.com.mx
''
''      Description:
''
''      This is the second Release of the ISCombo Control.
''      This is a Custom ImageCombo, that supports some aditional Features
''      See ISCombo.ctl For Detailed Info.:
''      you know, you can use this freely, just give me credit.
''      Votes and suggestions are wellcome.
''

Option Explicit

Private Type PointAPI
    X As Long
    Y As Long
End Type

Private Type RECT
        Left As Long
        Top As Long
        Right As Long
        Bottom As Long
End Type

Private Const WM_SIZE = &H5
Private Const WM_MOVE = &H3
Private Const WM_WINDOWPOSCHANGED = &H47
Private Const WM_KILLFOCUS = &H8
Private Const GWL_WNDPROC = (-4)

Private Const AW_HOR_POSITIVE = &H1
Private Const AW_HOR_NEGATIVE = &H2
Private Const AW_VER_POSITIVE = &H4
Private Const AW_VER_NEGATIVE = &H8
Private Const AW_CENTER = &H10
Private Const AW_HIDE = &H10000
Private Const AW_ACTIVATE = &H20000
Private Const AW_SLIDE = &H40000
Private Const AW_BLEND = &H80000

Private Declare Function AnimateWindow Lib "user32" (ByVal hWnd As Long, ByVal dwTime As Long, ByVal dwFlags As Long) As Long
Private Declare Function SetWindowPos Lib "user32" (ByVal hWnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Private Declare Function ReleaseCapture Lib "user32" () As Long
'Private Declare Function SetWindowPos Lib "user32" (ByVal hWnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, Y, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long
Private Declare Function GetCursorPos Lib "user32" (lpPoint As PointAPI) As Long
Private Declare Function GetWindowRect Lib "user32" (ByVal hWnd As Long, lpRect As RECT) As Long
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Private Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long


Dim iPos As Integer
Dim iItems As Integer
Dim IsInside As Boolean
Dim iPrevPos As Integer
Dim iFirstVisible As Integer
Dim bAnimateWindow As Boolean
Dim bMoveBykeyBoard As Boolean
Dim m_lParentHeight As Long

Public m_bShowByAutocomplete As Boolean
Public m_bPreserve As Boolean
Public m_Items As New Collection
Public m_Images As New Collection
Public m_ShowingList As Boolean
Public ItemClick As Integer
Public m_Backcolor As OLE_COLOR
Public m_HoverColor As OLE_COLOR
Public m_BorderColor As OLE_COLOR
Public m_IconsBackColor As OLE_COLOR

Event ItemClick(iItem As Integer, sText As String)
Event Hide()
Private nValue As Long
Private OriginalWndProc As Long


'' Detect if the Mouse cursor is inside a Window
Private Function InBox(ObjectHWnd As Long) As Boolean
    Dim mpos As PointAPI
    Dim oRect As RECT
    GetCursorPos mpos
    GetWindowRect ObjectHWnd, oRect
    If mpos.X >= oRect.Left And mpos.X <= oRect.Right And _
        mpos.Y >= oRect.Top And mpos.Y <= oRect.Bottom Then
        InBox = True
    Else
        InBox = False
   End If
End Function

Private Sub Form_Paint()
    '' Draw The Border of the Window
    Line (0, 0)-(ScaleWidth, 0), m_BorderColor
    Line (0, 0)-(0, ScaleHeight), m_BorderColor
    Line (ScaleWidth - 1, 0)-(ScaleWidth - 1, ScaleHeight - 1), m_BorderColor
    Line (0, ScaleHeight - 1)-(ScaleWidth - 1, ScaleHeight - 1), m_BorderColor
End Sub

'' Draw All items
Private Sub DrawAll(ActiveItem As Integer)
    ''Customizable Colors :)
    ''  thanks to Lucifer for this Suggestion
    lblCaption(iPrevPos).Backcolor = m_Backcolor ' vbWindowBackground
    lblCaption(iPrevPos).ForeColor = vbButtonText
    lblCaption(ActiveItem).Backcolor = m_HoverColor ' vbHighlight
    lblCaption(ActiveItem).ForeColor = vbHighlightText
    If ActiveItem <= 0 Then
        iPrevPos = 0
    Else
        iPrevPos = ActiveItem
    End If
End Sub

Public Sub SetParentHeight(lParentHeight As Long)
    m_lParentHeight = lParentHeight
End Sub

Private Sub imgItem_Click(Index As Integer)
    lblCaption_Click Index
End Sub

Private Sub ImgItem_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    lblCaption_MouseMove Index, Button, Shift, X, Y
End Sub

'' Raise the ItemClick event
Private Sub lblCaption_Click(Index As Integer)
    Reset
    RaiseEvent ItemClick(Index, lblCaption(Index).Caption)
End Sub

'' Detect the mouse movement
Private Sub lblCaption_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    '' If the user moves the mouse over the text area, It's selected.
    '' But not if the move is a result of KeyBoard action.
    If Button = 0 And Not bMoveBykeyBoard Then
        timUpdate.Enabled = True
        iPos = Index
    End If
End Sub

''  Hide and unload if the window lost the focus
Private Sub picGroup_LostFocus()
    If Not m_bPreserve Then
        Reset
        RaiseEvent Hide
    End If
End Sub

''  Hide and unload if the window lost the focus
Private Sub Form_LostFocus()
    'If Not m_bPreserve Then
        Reset
        RaiseEvent Hide
    'End If
End Sub

'' Activate the TipUpdate Timer
Private Sub picGroup_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If Button = 0 Then
        timUpdate.Enabled = True
    End If
End Sub

Private Sub pScroller_KeyUp(KeyCode As Integer, Shift As Integer)
    '' Process the KeyBoard Events
    bMoveBykeyBoard = True
    Select Case KeyCode
        Case vbKeyUp, vbKeyLeft
            'Select previous Item
            If iPos >= 1 Then
                iPos = iPos - 1
                '' If the combo has a ScrollBar, then
                If vsb.Visible Then
                    '' check that the selected item is visible
                    If iPos <= vsb.Value - 1 Then
                        vsb.Value = iPos
                        DoEvents
                    End If
                End If
                DrawAll iPos
            End If
        Case vbKeyDown, vbKeyRight
            'Select Next Item
            If iPos <= m_Items.Count - 2 Then
                iPos = iPos + 1
                '' If the combo has a ScrollBar, then
                If vsb.Visible Then
                    '' check that the selected item is visible
                    If iPos >= vsb.Value + 8 Then
                        vsb.Value = iPos - 7
                        DoEvents
                    End If
                End If
                DrawAll iPos
            End If
        Case vbKeyEnd
            iPos = m_Items.Count - 1
            If vsb.Visible Then
                vsb.Value = iPos - 7
                DoEvents
            End If
        Case vbKeyHome
            iPos = 0
            If vsb.Visible Then
                vsb.Value = 0
                DoEvents
            End If
        Case vbKeyReturn
            'Click on the Selected Item.
            lblCaption_Click iPos
        Case vbKeyEscape
            'Cancel and Reset
            Reset
            RaiseEvent Hide
        Case vbKeyTab
            Reset
            RaiseEvent Hide
    End Select
    bMoveBykeyBoard = False
End Sub

''  Hide and unload if the window lost the focus
Private Sub pScroller_LostFocus()
    'If Not m_bPreserve Then
        Reset
        RaiseEvent Hide
    'End If
End Sub

'' Detect the position of the cursor
''  (Only if the cursor is in the Window)
Private Sub timUpdate_Timer()
Static temiPos As Integer
    If InBox(picGroup.hWnd) Then
        If IsInside Then
            If temiPos <> iPos Then
                DrawAll iPos
            End If
        Else
            IsInside = True
        End If
    Else
        timUpdate.Enabled = False
        DrawAll 0
        IsInside = False
    End If
    temiPos = iPos
End Sub

'' Change the position of the items when the ScrollBar changes
Private Sub vsb_Change()
    On Error Resume Next
    picGroup.Move 0, 1 - 17 * vsb.Value
    'Me.SetFocus
End Sub

Public Sub SetSelectedItem(iSelectedItem As Integer)
    'Select A Specified Item
    iPos = iSelectedItem
    If iPos > 8 Then vsb.Value = iPos - 7
    DrawAll iPos
End Sub


'' Hide Window and Save state in Variable
Public Sub Reset()
    Hide
    m_ShowingList = False
End Sub

'' This function Show the cDown Window, And adds the items
Public Function PopUp(X As Long, Y As Long, lWidth As Single, parent As Object, iSelectedItem As Integer) As Boolean
    Dim ni As Integer
    Dim ht As Single
    Dim lHeight As Single
    m_ShowingList = True
    ht = (17 * (m_Items.Count) + 2) * Screen.TwipsPerPixelY
    picGroup.Backcolor = m_IconsBackColor
    For ni = 1 To m_Items.Count + 2
        Load lblCaption(ni)
        Load ImgItem(ni)
    Next ni
    If m_Items.Count <= 8 Then
        lHeight = ht
        vsb.Visible = False
    Else
        lHeight = (8 * 17 + 2) * Screen.TwipsPerPixelY
        vsb.Visible = True
        vsb.Min = 0
        vsb.Max = m_Items.Count - 8
        vsb.SmallChange = 1
        vsb.LargeChange = m_Items.Count - 8
    End If
    On Error GoTo LimitOfItems
    For ni = 1 To m_Items.Count
        lblCaption(ni - 1).Backcolor = m_Backcolor
        lblCaption(ni - 1).Visible = True
        lblCaption(ni - 1).Caption = m_Items.Item(ni)
        lblCaption(ni - 1).Move 24, 17 * (ni - 1), lWidth - 28
        ImgItem(ni - 1).Visible = True
        Set ImgItem(ni - 1).Picture = m_Images(ni)
        ImgItem(ni - 1).Move 2, 17 * (ni - 1)
    Next ni
LimitOfItems:
    ''Check If dropdown list exceeds screen area then dropup
    ''  If Is OK, show. . .
    '' This is a suggestion made by Charles P. V.
    If Y + lHeight <= Screen.Height Then
        Me.Move X, Y, lWidth, lHeight
    Else
        Me.Move X, Y - lHeight - m_lParentHeight * Screen.TwipsPerPixelY, lWidth, lHeight '- parent.ScaleHeight
    End If
    
    'Show The DropDown List
    If bAnimateWindow Then
        AnimateWindow Me.hWnd, 250, AW_VER_POSITIVE + AW_SLIDE + AW_ACTIVATE
    Else
        Show
    End If
    
    picGroup.Move 0, 0, ScaleWidth - 4, ht - 4
    vsb.Move ScaleWidth - vsb.Width - 2, 0, vsb.Width, ScaleHeight - 2
    pScroller.Move 1, 1, ScaleWidth - 2, ScaleHeight - 2
    iPrevPos = 0
    iPos = iSelectedItem
    On Error Resume Next
    If iPos > 8 Then vsb.Value = iPos - 7
    
    'SetWindowPos hWnd, -1, 0, 0, 0, 0, 1 Or 2
    Me.SetFocus
    Form_Paint
    DrawAll iPos
End Function

Private Sub vsb_Scroll()
    vsb_Change
End Sub
