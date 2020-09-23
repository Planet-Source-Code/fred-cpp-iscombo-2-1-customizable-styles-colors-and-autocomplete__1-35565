VERSION 5.00
Begin VB.UserControl ISCombo 
   BackColor       =   &H80000005&
   ClientHeight    =   1605
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   3420
   ScaleHeight     =   107
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   228
   ToolboxBitmap   =   "ISCombo.ctx":0000
   Begin VB.Timer timUpdate 
      Enabled         =   0   'False
      Interval        =   10
      Left            =   2160
      Top             =   660
   End
   Begin VB.TextBox txtText 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      Height          =   225
      Left            =   120
      TabIndex        =   1
      Text            =   "Combo"
      Top             =   2160
      Width           =   1875
   End
   Begin VB.PictureBox picButton 
      BorderStyle     =   0  'None
      Height          =   615
      Left            =   1860
      ScaleHeight     =   41
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   29
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   1980
      Width           =   435
   End
   Begin VB.Image ImgItem 
      Height          =   195
      Left            =   300
      Stretch         =   -1  'True
      Top             =   2460
      Width           =   375
   End
End
Attribute VB_Name = "ISCombo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
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
''      This is a Custom ImageCombo, that supports some aditional Features Like:
''      *Style:
''          Version 2.10 Support Multiple Styles:
''          * Normal:       Classic ImageCombo Style
''          * MSO2000:      Flat Office 2000 Style
''          * MSOXP:        Flat Office XP Style
''          * WINXP:        Windows XP style
''
''      * KeyBoard Navigation Supported
''          All Keyboard functionality is now supported
''          (Including AltKey + DownKey to show the Scroll Window)
''
''      * Keep Bookmark.
''          Automatically The previous Selection Is Displayed when user activates Scroll Window
''
''      * Text Align:
''          Supports This Property like TextBoxes
''
''      * DefaultIcon
''          Is the Icon that is Shown When there isn't a Selected Item.
''
''      * Backcolor
''          You can select the Backcolor for all styles
''
''      * HoverColor
''          You can select also the Hovercolor in all styles
''
''      * MSOXPColor
''          The Color for the Button in MSOXPStyle
''
''      * MSOXPHoverColor
''          The HoverColor for the button in the MSOXPStyle
''
''      * WINXPColor
''          The color for the Button in WINXPStyle
''
''      * WINXPHoverColor
''          The HoverColor for the Button in WINXPStyle
''
''      * WINXPBorderColor
''          The Color in the Border in WINXPStyle
''
''      * DropDownListBackColor
''          The color for the DropDownList in all styles
''
''      * DropDownListHoverColor
''          The color for the selected items in DropDownList in all styles
''
''      * DropDownListBorderColor
''          The color for the Border in DropDownList in all styles
''
''      * FontColor
''          The color for the text in all styles
''
''      * FontHighLightColor
''          The HighLight Color fot the text in all styles.
''
''      * RestoreOriginalColors
''          Set all Colors to the default value.
''
''      * Autocomplete
''          Now Complete, The problem is that The control doesn't show the dropdown list
''          when the autocomplte is on process
''
''      Special thanks:
''      Charles P.V.    :Lot of tips
''      Lucifer         :Almost all autocomplete routines.
''      Chad            :
''      you know, you can use this freely, just give me credit.
''      Votes and suggestions are wellcome.
''

Option Explicit

'************************************************************'
'*                                                          *'
'*  Declaratios (Structures, Constants and API)             *'
'*                                                          *'
'************************************************************'

' Type Declarations

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

Public Enum ISAlign
    AlignLeft
    AlignRight
    AlignCenter
End Enum

Private Enum State
    Normal
    Hover
    pushed
    disabled
End Enum

Public Enum iscStyle
    ISNormal
    ISMSO2000
    ISMSOXP
    ISWINXP
End Enum

''Color Constants

Private Const COLOR_ACTIVEBORDER = 10
Private Const COLOR_ACTIVECAPTION = 2
Private Const COLOR_ADJ_MAX = 100
Private Const COLOR_ADJ_MIN = -100
Private Const COLOR_APPWORKSPACE = 12
Private Const COLOR_BACKGROUND = 1
Private Const COLOR_BTNFACE = 15
Private Const COLOR_BTNHIGHLIGHT = 20
Private Const COLOR_BTNSHADOW = 16
Private Const COLOR_BTNTEXT = 18
Private Const COLOR_CAPTIONTEXT = 9
Private Const COLOR_GRAYTEXT = 17
Private Const COLOR_HIGHLIGHT = 13
Private Const COLOR_HIGHLIGHTTEXT = 14
Private Const COLOR_INACTIVEBORDER = 11
Private Const COLOR_INACTIVECAPTION = 3
Private Const COLOR_INACTIVECAPTIONTEXT = 19
Private Const COLOR_MENU = 4
Private Const COLOR_MENUTEXT = 7
Private Const COLOR_SCROLLBAR = 0
Private Const COLOR_WINDOW = 5
Private Const COLOR_WINDOWFRAME = 6
Private Const COLOR_WINDOWTEXT = 8

' 3D border styles
Private Const BDR_RAISEDOUTER = &H1
Private Const BDR_SUNKENOUTER = &H2
Private Const BDR_RAISEDINNER = &H4
Private Const BDR_SUNKENINNER = &H8

Private Const BDR_OUTER = &H3
Private Const BDR_INNER = &HC

Private Const EDGE_RAISED = (BDR_RAISEDOUTER Or BDR_RAISEDINNER)
Private Const EDGE_SUNKEN = (BDR_SUNKENOUTER Or BDR_SUNKENINNER)
Private Const EDGE_ETCHED = (BDR_SUNKENOUTER Or BDR_RAISEDINNER)
Private Const EDGE_BUMP = (BDR_RAISEDOUTER Or BDR_SUNKENINNER)

' Border flags
Private Const BF_LEFT = &H1
Private Const BF_TOP = &H2
Private Const BF_RIGHT = &H4
Private Const BF_BOTTOM = &H8

Private Const BF_TOPLEFT = (BF_TOP Or BF_LEFT)
Private Const BF_TOPRIGHT = (BF_TOP Or BF_RIGHT)
Private Const BF_BOTTOMLEFT = (BF_BOTTOM Or BF_LEFT)
Private Const BF_BOTTOMRIGHT = (BF_BOTTOM Or BF_RIGHT)
Private Const BF_RECT = (BF_LEFT Or BF_TOP Or BF_RIGHT Or BF_BOTTOM)

Private Const BF_DIAGONAL = &H10

'' Private Variables
Private InOut As Boolean
Private iState As State
Private OnClicking As Boolean
Private OnFocus As Boolean
Private bPressed As Boolean
Private bPreserve As Boolean
Private bListIsVisible As Boolean
Private gScaleX As Single
Private gScaleY As Single
Private bRead As Byte
Private bInput As Boolean
Private m_Focused As Boolean
Private m_ImageSize As Integer
Private m_Items As New Collection
Private m_Images As New Collection
Private m_ItemsCount As Integer
Private m_Autocomplete As Boolean
Private m_Editable As Boolean
Private m_SelectedItem As Integer

Private WithEvents cDown As wndDown
Attribute cDown.VB_VarHelpID = -1

'Default Property Values:
Const m_def_Enabled = True
Const m_def_Autocomplete = True
Const m_def_IconAlign = 0
Const m_def_IconSize = 0
Const m_def_TextAlign = 4
Const m_def_BackColor = &HFFFFFF
Const m_def_HoverColor = &HFFFFFF
'Const m_def_Default = False
'Const m_def_Editable = False
Const m_def_Style = 1
Const m_def_FontColor = 0
Const m_def_FontHighlightColor = &H80000
Const m_def_MSOXPColor = &HC08080
Const m_def_MSOXPHoverColor = &H800000
Const m_def_WINXPColor = &HFF8D6F
Const m_def_WINXPHoverColor = &HFF9D7F
Const m_def_WINXPBorderColor = &HB99D7F
Const m_def_DropDownListBackColor = &H80000005
Const m_def_DropDownListHoverColor = &H8000000D
Const m_def_DropDownListBorderColor = 0
Const m_def_DropDownListIconsBackColor = &H80000005

'Property Variables:
Dim m_Enabled As Boolean
Dim m_FontColor As OLE_COLOR
Dim m_FontHighlightColor As OLE_COLOR
Dim m_TextAlign As ISAlign
Dim m_Icon As Picture
Dim m_Backcolor As OLE_COLOR
Dim m_HoverColor As OLE_COLOR
Dim m_Style As iscStyle
Dim m_MSOXPColor As OLE_COLOR
Dim m_MSOXPHoverColor As OLE_COLOR
Dim m_WINXPColor As OLE_COLOR
Dim m_WINXPHoverColor As OLE_COLOR
Dim m_WINXPBorderColor As OLE_COLOR
Dim m_DropDownListBackColor As OLE_COLOR
Dim m_DropDownListHoverColor As OLE_COLOR
Dim m_DropDownListBorderColor As OLE_COLOR
Dim m_DropDownListIconsBackColor As OLE_COLOR

'Event Declarations:
Event ItemClick(iItem As Integer)
Event Click()
Event DblClick()
Event MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Event MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Event MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Event MouseOut()
Event MouseHover()
Event KeyPress(KeyAscii As Integer)
Event ButtonClick()
Event Change()
Const pBorderColor = &HC08080

' API Declarations
Private Declare Function ReleaseCapture Lib "user32" () As Long
Private Declare Function GetSysColor Lib "user32" (ByVal nIndex As Long) As Long
Private Declare Function GetCursorPos Lib "user32" (lpPoint As PointAPI) As Long
Private Declare Function FillRect Lib "user32" (ByVal hdc As Long, lpRect As RECT, ByVal hBrush As Long) As Long
Private Declare Function GetWindowRect Lib "user32" (ByVal hWnd As Long, lpRect As RECT) As Long
Private Declare Function ScreenToClient Lib "user32" (ByVal hWnd As Long, lpPoint As PointAPI) As Long
Private Declare Function DrawEdge Lib "user32" (ByVal hdc As Long, qrc As RECT, ByVal edge As Long, ByVal grfFlags As Long) As Long
Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Private Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long) As Long
Private Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long
Private Declare Function SetWindowPos Lib "user32" (ByVal hWnd As Long, ByVal hWndInsertAfter As Long, ByVal X As Long, ByVal Y As Long, ByVal cx As Long, ByVal cy As Long, ByVal wFlags As Long) As Long
Private Declare Function MoveToEx Lib "gdi32" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long, lpPoint As PointAPI) As Long
Private Declare Function LineTo Lib "gdi32" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long) As Long
Private Declare Function CreateSolidBrush Lib "gdi32" (ByVal crColor As Long) As Long
Private Declare Function CreatePen Lib "gdi32" (ByVal nPenStyle As Long, ByVal nWidth As Long, ByVal crColor As Long) As Long
Private Declare Function SelectObject Lib "gdi32" (ByVal hdc As Long, ByVal hObject As Long) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Private Declare Function SetParent Lib "user32" (ByVal hWndChild As Long, ByVal hWndNewParent As Long) As Long
Private Declare Function GetParent Lib "user32" (ByVal hWnd As Long) As Long
Private Declare Function SendMessage2 Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Any) As Long

Private Const CB_SHOWDROPDOWN = 335

'************************************************************'
'*                                                          *'
'*  Autocomplete routines                                   *'
'*                                                          *'
'***********************************************************

Function Search(text As String) As Integer
    Dim a, i
    a = m_Items.Count

    For i = 1 To a
        If text = m_Items.Item(i) Then
            'Item Exists
            Search = 1
            Exit For
        End If
    Next i
End Function

Function Complete() As Integer
    Dim a, ni
    a = m_Items.Count

    If txtText.text <> "" And bInput = False Then
        bRead = Len(txtText.text)
        For ni = 1 To a
            If LCase(txtText.text) = LCase(m_Items.Item(ni)) Then
                Exit Function
            ElseIf LCase(txtText.text) = LCase(Left(m_Items.Item(ni), bRead)) Then
                bInput = True
                txtText.SetFocus
                txtText.text = m_Items.Item(ni)
                txtText.SelStart = bRead
                txtText.SelLength = Len(txtText.text) - bRead
                m_SelectedItem = ni - 1
                'This should open the Dropdown List, but this combo is diferent, so I need Code all manually :(
                'SendMessage2 txtText.hwnd, CB_SHOWDROPDOWN, 1, txtText.text
                'I'll edit Dropdown Functionality
                If Not cDown Is Nothing Then cDown.m_bPreserve = False
                Exit For
            End If
        Next ni
        m_SelectedItem = ni - 1
    Else
        bInput = False
    End If
End Function

'************************************************************'
'*                                                          *'
'*  Drawing Routines                                        *'
'*                                                          *'
'***********************************************************

Private Sub APIFillRect(hdc As Long, rc As RECT, Color As Long)
  Dim OldBrush As Long
  Dim NewBrush As Long
  
  NewBrush& = CreateSolidBrush(Color&)
  Call FillRect(hdc&, rc, NewBrush&)
  Call DeleteObject(NewBrush&)
End Sub


Private Function APILine(ByVal hdc As Long, ByVal X1 As Long, ByVal Y1 As Long, ByVal X2 As Long, ByVal Y2 As Long, Optional Color As OLE_COLOR = -1) As Long
    Dim hPen As Long, hPenOld As Long
    Dim R
    Dim pt As PointAPI
    hPen = CreatePen(0, 1, Color)
    hPenOld = SelectObject(hdc, hPen)
    MoveToEx hdc, X1, Y1, pt
    LineTo hdc, X2, Y2
    SelectObject hdc, hPenOld
    DeleteObject hPen
End Function

Private Function APIRectangle(ByVal hdc As Long, rtRect As RECT, Optional Color As OLE_COLOR = -1) As Long
    Dim hPen As Long, hPenOld As Long
    Dim R
    Dim pt As PointAPI
    hPen = CreatePen(0, 1, Color)
    hPenOld = SelectObject(hdc, hPen)
    MoveToEx hdc, rtRect.Left, rtRect.Top, pt
    LineTo hdc, rtRect.Right, rtRect.Top
    LineTo hdc, rtRect.Right, rtRect.Bottom
    LineTo hdc, rtRect.Left, rtRect.Bottom
    LineTo hdc, rtRect.Left, rtRect.Top
    SelectObject hdc, hPenOld
    DeleteObject hPen
End Function

'' Make Soft a color
Function SoftColor(lColor As OLE_COLOR) As OLE_COLOR
    Dim lRed As OLE_COLOR
    Dim lGreen As OLE_COLOR
    Dim lBlue As OLE_COLOR
    Dim lr As OLE_COLOR, lg As OLE_COLOR, lb As OLE_COLOR
    lr = (lColor And &HFF)
    lg = ((lColor And 65280) \ 256)
    lb = ((lColor) And 16711680) \ 65536
    lRed = (76 - Int(((lColor And &HFF) + 32) \ 64) * 19)
    lGreen = (76 - Int((((lColor And 65280) \ 256) + 32) \ 64) * 19)
    lBlue = (76 - Int((((lColor And &HFF0000) \ &H10000) + 32) / 64) * 19)
    SoftColor = RGB(lr + lRed, lg + lGreen, lb + lBlue)
End Function

''  Offset a color
Function OffsetColor(lColor As OLE_COLOR, lOffset As Long) As OLE_COLOR
    Dim lRed As OLE_COLOR
    Dim lGreen As OLE_COLOR
    Dim lBlue As OLE_COLOR
    Dim lr As OLE_COLOR, lg As OLE_COLOR, lb As OLE_COLOR
    lr = (lColor And &HFF)
    lg = ((lColor And 65280) \ 256)
    lb = ((lColor) And 16711680) \ 65536
    lRed = (lOffset + lr)
    lGreen = (lOffset + lg)
    lBlue = (lOffset + lb)
    If lRed > 255 Then lRed = 255
    If lRed < 0 Then lRed = 0
    If lGreen > 255 Then lGreen = 255
    If lGreen < 0 Then lGreen = 0
    If lBlue > 255 Then lBlue = 255
    If lBlue < 0 Then lBlue = 0
    OffsetColor = RGB(lRed, lGreen, lBlue)
End Function

'' Detect If the Mouse is over a Window Rect
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

'************************************************************'
'*                                                          *'
'*  Event Procedures                                        *'
'*                                                          *'
'***********************************************************

Private Sub cDown_ItemClick(iItem As Integer, sText As String)
    UserControl.ImgItem.Picture = m_Images(iItem + 1)
    txtText.text = sText
    txtText.SelStart = 0
    txtText.SelLength = Len(sText)
    m_SelectedItem = iItem
    UserControl.SetFocus
    iState = Hover
    bListIsVisible = False
    Unload cDown
    Set cDown = Nothing
    RaiseEvent ItemClick(iItem)
End Sub

Private Sub cDown_Hide()
    Unload cDown
    Set cDown = Nothing
    bListIsVisible = False
End Sub

Private Sub ImgItem_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    UserControl_MouseMove Button, Shift, X, Y
End Sub

Private Sub picButton_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    OnClicking = True
    If Button = vbLeftButton Then
        bPressed = True
        iState = pushed
        DrawFace
    End If
End Sub

Private Sub picButton_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
        UserControl_MouseMove Button, Shift, X, Y
End Sub

Private Sub picButton_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    OnClicking = False
    bPressed = False
    DrawFace
End Sub

Private Sub picButton_Paint()
    'DrawFace
End Sub

Private Sub timUpdate_Timer()
    If InBox(UserControl.hWnd) Then
        If InOut = False Then
            iState = Hover
            UserControl_Paint
            RaiseEvent MouseHover
        Else
            iState = Normal
        End If
        InOut = True
    Else
        If InOut Then
            timUpdate.Enabled = False
            If OnFocus Then
                iState = Hover
            Else
                iState = Normal
            End If
            UserControl_Paint
            RaiseEvent MouseOut
        End If
        InOut = False
    End If
End Sub

Private Sub txtText_Change()
    If m_Autocomplete Then
        Dim a
        a = Complete()   'Autocomplete
    End If
    RaiseEvent Change
End Sub

Private Sub txtText_GotFocus()
    txtText.SelStart = 0
    txtText.SelLength = Len(txtText.text)
End Sub

Private Sub txtText_KeyDown(KeyCode As Integer, Shift As Integer)
   If Not m_Autocomplete Then Exit Sub
   If KeyCode = 8 Then
        If bRead > 0 And txtText.SelLength > 0 Then
            txtText.SelStart = bRead - 1
            txtText.SelLength = Len(txtText.text) - bRead + 1
        End If
    ElseIf KeyCode = 46 Then
        If txtText.SelLength <> 0 Then
            txtText.text = Left(txtText.text, bRead)
            bInput = True
        End If
    End If
End Sub

Private Sub txtText_KeyPress(KeyAscii As Integer)
    On Error Resume Next
    Dim a
    Select Case KeyAscii
    Case 13:
        a = Search(txtText.text)
        ' si a = 0 The especified Text doesn't exist in the list, so then Add the item
        ' si a = 1 Exist, Don't add the item.
        If a = 0 And txtText.text <> "" Then
            Me.AddItem txtText.text, , m_Icon
        End If
        ImgItem.Picture = m_Images(m_SelectedItem + 1)
        txtText.SelStart = 0
        txtText.SelLength = Len(txtText.text)
        If bListIsVisible Then cDown.Hide
        bListIsVisible = False
    Case 27
        If bListIsVisible Then cDown.Hide
        txtText.text = Left(txtText.text, txtText.SelStart)
        bListIsVisible = False
    End Select
    RaiseEvent KeyPress(KeyAscii)
    RaiseEvent ItemClick(m_SelectedItem)
End Sub

Private Sub txtText_KeyUp(KeyCode As Integer, Shift As Integer)
    '' Process the KeyBoard Events to Move Or Edit Text
    If KeyCode = vbKeyUp Or KeyCode = vbKeyDown Then
        If (Shift And 7) = 4 Then
            picButton_Click
        Else
            If KeyCode = vbKeyUp Then
                m_SelectedItem = m_SelectedItem - 1
                If m_SelectedItem < 0 Then m_SelectedItem = 0
            ElseIf KeyCode = vbKeyDown Then
                m_SelectedItem = m_SelectedItem + 1
                If m_SelectedItem > m_Items.Count - 1 Then m_SelectedItem = m_Items.Count - 1
            End If
            txtText.text = CStr(m_Items(m_SelectedItem + 1))
            ImgItem.Picture = m_Images(m_SelectedItem + 1)
            txtText.SelStart = 0
            txtText.SelLength = Len(txtText.text)
        End If
    End If
End Sub

Private Sub txtText_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    UserControl_MouseMove Button, Shift, X, Y
End Sub

Private Sub UserControl_EnterFocus()
    bPreserve = True
    If Not cDown Is Nothing Then cDown.m_bPreserve = True
    OnFocus = True
    iState = Hover
    If m_Enabled Then
        DrawFace
    End If
    DoEvents
    bPreserve = False
    If Not cDown Is Nothing Then cDown.m_bPreserve = False
End Sub

Private Sub UserControl_ExitFocus()
    OnFocus = False
    iState = Normal
    If Not cDown Is Nothing Then If cDown.m_ShowingList And Not bPreserve Then cDown.Reset
    If m_Enabled Then
        DrawFace
    End If
End Sub

Private Sub UserControl_Initialize()
    InOut = False
    OnClicking = False
    
    gScaleX = Screen.TwipsPerPixelX
    gScaleY = Screen.TwipsPerPixelY
    m_ImageSize = 16
    UserControl_Resize
End Sub

Private Sub UserControl_KeyDown(KeyCode As Integer, Shift As Integer)
    If m_Enabled Then DrawFace
End Sub

Private Sub UserControl_KeyPress(KeyAscii As Integer)
    If m_Enabled Then
        RaiseEvent Click
        RaiseEvent KeyPress(KeyAscii)
    End If
End Sub

Private Sub UserControl_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If m_Enabled Then
        iState = pushed
        UserControl_Paint
        timUpdate.Enabled = False
        OnClicking = True
        RaiseEvent MouseDown(Button, Shift, X, Y)
    End If
End Sub

Private Sub UserControl_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If m_Enabled Then
        If Button = 0 Then timUpdate.Enabled = True
        RaiseEvent MouseMove(Button, Shift, X, Y)
    End If
End Sub

Private Sub UserControl_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    If m_Enabled Then
        iState = Hover
        UserControl_Paint
        timUpdate.Enabled = True
        RaiseEvent MouseUp(Button, Shift, X, Y)
        If InBox(UserControl.hWnd) Then
            RaiseEvent Click
        End If
        OnClicking = False
    End If
End Sub

Private Sub UserControl_Resize()
    '   Text Position
    UserControl.ScaleMode = 3
    If ScaleWidth < 56 Then Width = 56 * gScaleX
    If ScaleHeight < 21 Then Height = 21 * gScaleY
    ImgItem.Move 4, (UserControl.ScaleHeight - m_ImageSize) / 2, m_ImageSize, m_ImageSize
    txtText.Move 7 + m_ImageSize, (UserControl.ScaleHeight - txtText.Height) / 2, ScaleWidth - m_ImageSize - picButton.Width - 10
    picButton.Move ScaleWidth - 18, 2, 16, ScaleHeight - 4
    Select Case m_TextAlign
        Case 0  '   Left
            txtText.Alignment = 0
        Case 1  '   Right
            txtText.Alignment = 1
        Case 2  '   Top
            txtText.Alignment = 2
    End Select
    'Locate Button
    UserControl_Paint
End Sub

Private Sub UserControl_DblClick()
    If m_Enabled Then RaiseEvent DblClick
End Sub

Private Sub UserControl_Show()
    UserControl_Resize
    UserControl_Paint
End Sub

Private Sub picButton_Click()
    ' Show de Auxiliar Window
    Dim ni As Integer

    If m_Enabled Then
        Set cDown = New wndDown
        For ni = 1 To m_Items.Count
            cDown.m_Items.Add m_Items(ni)
            cDown.m_Images.Add m_Images(ni)
        Next ni
        RaiseEvent ButtonClick
        Dim rt As RECT
        GetWindowRect UserControl.hWnd, rt
        cDown.m_Backcolor = m_DropDownListBackColor
        cDown.m_BorderColor = m_DropDownListBorderColor
        cDown.m_HoverColor = m_DropDownListHoverColor
        cDown.m_IconsBackColor = m_DropDownListIconsBackColor
        cDown.SetParentHeight UserControl.ScaleHeight
        bPreserve = True
        cDown.PopUp rt.Left * gScaleX, rt.Bottom * gScaleY, UserControl.Width, UserControl.Extender.parent, m_SelectedItem
        bListIsVisible = True
        DoEvents
        bPreserve = False
    End If
NoItemsToShow:
End Sub

Private Sub UserControl_Terminate()
    On Error Resume Next
    If Not cDown Is Nothing Then
        Unload cDown
        Set cDown = Nothing
    End If
End Sub


'************************************************************'
'*                                                          *'
'*  Properties                                              *'
'*                                                          *'
'***********************************************************

Public Property Get Style() As iscStyle
    Style = m_Style
End Property

Public Property Let Style(ByVal New_Style As iscStyle)
    m_Style = New_Style
    InOut = False
    timUpdate.Enabled = True
    DoEvents
    UserControl_Paint
    PropertyChanged "Style"
End Property

Public Property Get Caption() As String
    Caption = txtText.text
End Property

Public Property Let Caption(ByVal New_Caption As String)
    txtText.text() = New_Caption
    PropertyChanged "Caption"
End Property

Public Property Get Font() As Font
    Set Font = txtText.Font
End Property

Public Property Set Font(ByVal New_Font As Font)
    Set txtText.Font = New_Font
    txtText.Height = 1 'TextBox Will Automacally adjust to Minimum Height
    UserControl_Resize
    PropertyChanged "Font"
End Property

Public Property Get ToolTipText() As String
    ToolTipText = txtText.ToolTipText
End Property

Public Property Let ToolTipText(ByVal New_ToolTipText As String)
    txtText.ToolTipText() = New_ToolTipText
    PropertyChanged "ToolTipText"
End Property

Public Property Get Icon() As Picture
    Set Icon = m_Icon
End Property

Public Property Set Icon(ByVal New_Icon As Picture)
    Set m_Icon = New_Icon
    Set ImgItem.Picture = New_Icon
    PropertyChanged "Icon"
End Property

Public Property Get TextAlign() As ISAlign
    TextAlign = m_TextAlign
End Property

Public Property Let TextAlign(ByVal New_TextAlign As ISAlign)
    m_TextAlign = New_TextAlign
    UserControl_Resize
    PropertyChanged "TextAlign"
End Property

Public Property Get Backcolor() As OLE_COLOR
    Backcolor = m_Backcolor
End Property

Public Property Let Backcolor(newBackColor As OLE_COLOR)
    m_Backcolor = newBackColor
    UserControl_Paint
    PropertyChanged "Backcolor"
End Property

Public Property Get HoverColor() As OLE_COLOR
    HoverColor = m_HoverColor
End Property

Public Property Let HoverColor(newHoverColor As OLE_COLOR)
    m_HoverColor = newHoverColor
    UserControl_Paint
    PropertyChanged "Hovercolor"
End Property

''' Office XP Color
Public Property Get MSOXPColor() As OLE_COLOR
    MSOXPColor = m_MSOXPColor
End Property
Public Property Let MSOXPColor(newColor As OLE_COLOR)
    m_MSOXPColor = newColor
    UserControl_Paint
    PropertyChanged "MSOXPColor"
End Property

''' Office XP Color (Pushed)
Public Property Get MSOXPHoverColor() As OLE_COLOR
    MSOXPHoverColor = m_MSOXPHoverColor
End Property
Public Property Let MSOXPHoverColor(newColor As OLE_COLOR)
    m_MSOXPHoverColor = newColor
    UserControl_Paint
    PropertyChanged "MSOXPHoverColor"
End Property

''' Windows XP Color
Public Property Get WINXPColor() As OLE_COLOR
    WINXPColor = m_WINXPColor
End Property
Public Property Let WINXPColor(newColor As OLE_COLOR)
    m_WINXPColor = newColor
    UserControl_Paint
    PropertyChanged "WINXPColor"
End Property

''' Windows XP Hover Color
Public Property Get WINXPHoverColor() As OLE_COLOR
    WINXPHoverColor = m_WINXPHoverColor
End Property
Public Property Let WINXPHoverColor(newColor As OLE_COLOR)
    m_WINXPHoverColor = newColor
    UserControl_Paint
    PropertyChanged "WINXPHoverColor"
End Property

''' Windows XP Border Color
Public Property Get WINXPBorderColor() As OLE_COLOR
    WINXPBorderColor = m_WINXPBorderColor
End Property
Public Property Let WINXPBorderColor(newColor As OLE_COLOR)
    m_WINXPBorderColor = newColor
    UserControl_Paint
    PropertyChanged "WINXPBorderColor"
End Property

''' DropDownList BackColor
Public Property Get DropDownListBackColor() As OLE_COLOR
    DropDownListBackColor = m_DropDownListBackColor
End Property
Public Property Let DropDownListBackColor(newColor As OLE_COLOR)
    m_DropDownListBackColor = newColor
    UserControl_Paint
    PropertyChanged "DropDownListBackColor"
End Property

''' DropDownList HoverColor
Public Property Get DropDownListHoverColor() As OLE_COLOR
    DropDownListHoverColor = m_DropDownListHoverColor
End Property
Public Property Let DropDownListHoverColor(newColor As OLE_COLOR)
    m_DropDownListHoverColor = newColor
    PropertyChanged "DropDownListHoverColor"
End Property

''' DropDownList BorderColor
Public Property Get DropDownListBorderColor() As OLE_COLOR
    DropDownListBorderColor = m_DropDownListBorderColor
End Property
Public Property Let DropDownListBorderColor(newColor As OLE_COLOR)
    m_DropDownListBorderColor = newColor
    PropertyChanged "DropDownListBorderColor"
End Property

''' DropDownList Icons Backcolor
Public Property Get DropDownListIconsBackColor() As OLE_COLOR
    DropDownListIconsBackColor = m_DropDownListIconsBackColor
End Property
Public Property Let DropDownListIconsBackColor(newColor As OLE_COLOR)
    m_DropDownListIconsBackColor = newColor
    PropertyChanged "DropDownListIconsBackColor"
End Property

''' Font Colors
Public Property Get FontColor() As OLE_COLOR
    FontColor = m_FontColor
End Property
Public Property Let FontColor(ByVal New_FontColor As OLE_COLOR)
    m_FontColor = New_FontColor
    txtText.ForeColor = New_FontColor
    PropertyChanged "FontColor"
End Property

Public Property Get FontHighlightColor() As OLE_COLOR
    FontHighlightColor = m_FontHighlightColor
End Property

Public Property Let FontHighlightColor(ByVal New_FontHighlightColor As OLE_COLOR)
    m_FontHighlightColor = New_FontHighlightColor
    PropertyChanged "FontHighlightColor"
End Property

Public Property Get Autocomplete() As Boolean
    Autocomplete = m_Autocomplete
End Property

Public Property Let Autocomplete(ByVal New_Autocomplete As Boolean)
    m_Autocomplete = New_Autocomplete
    PropertyChanged "Autocomplete"
End Property

Public Property Get Enabled() As Boolean
    Enabled = m_Enabled
End Property

Public Property Get hWnd() As Long
    hWnd = UserControl.hWnd
End Property

Public Property Let Enabled(ByVal New_Enabled As Boolean)
    m_Enabled = New_Enabled
    UserControl.Enabled = New_Enabled
    picButton.Enabled = New_Enabled
    ImgItem.Enabled = New_Enabled
    If New_Enabled Then
        txtText.Backcolor = vbWindowBackground
        UserControl.Backcolor = vbWindowBackground
        txtText.ForeColor = vbButtonText
        txtText.Locked = False
        txtText.Enabled = True
        iState = Normal
    Else
        txtText.Backcolor = vb3DFace
        UserControl.Backcolor = vb3DFace
        txtText.ForeColor = vbGrayText
        txtText.Locked = True
        txtText.Enabled = False
        iState = disabled
    End If
    UserControl_Paint
    PropertyChanged "Enabled"
End Property

Private Sub UserControl_InitProperties()
    Set m_Icon = LoadPicture("")
    m_TextAlign = m_def_TextAlign
    m_FontColor = m_def_FontColor
    m_FontHighlightColor = m_def_FontHighlightColor
    
    m_HoverColor = m_def_HoverColor
    m_Backcolor = m_def_BackColor
    m_MSOXPColor = m_def_MSOXPColor
    m_MSOXPHoverColor = m_def_MSOXPHoverColor
    m_WINXPColor = m_def_WINXPColor
    m_WINXPHoverColor = m_def_WINXPHoverColor
    m_WINXPBorderColor = m_def_WINXPBorderColor
    
    m_DropDownListBackColor = m_def_DropDownListBackColor
    m_DropDownListHoverColor = m_def_DropDownListHoverColor
    m_DropDownListBorderColor = m_def_DropDownListBorderColor
    m_DropDownListIconsBackColor = m_def_DropDownListIconsBackColor
    
    m_Autocomplete = m_def_Autocomplete
    txtText.text = UserControl.Extender.Name
    m_Enabled = m_def_Enabled
    m_Style = m_def_Style
End Sub

Private Sub UserControl_ReadProperties(PropBag As PropertyBag)
    Dim picNormal As Picture
    With PropBag
        Set picNormal = PropBag.ReadProperty("Icon", Nothing)
        If Not (picNormal Is Nothing) Then Set Icon = picNormal
    End With

    m_Backcolor = PropBag.ReadProperty("BackColor", m_def_BackColor)
    m_HoverColor = PropBag.ReadProperty("HoverColor", m_def_HoverColor)
    m_MSOXPColor = PropBag.ReadProperty("MSOXPColor", m_def_MSOXPColor)
    m_MSOXPHoverColor = PropBag.ReadProperty("MSOXPHoverColor", m_def_MSOXPHoverColor)
    m_WINXPColor = PropBag.ReadProperty("WINXPColor", m_def_WINXPColor)
    m_WINXPHoverColor = PropBag.ReadProperty("WINXPHoverColor", m_def_WINXPHoverColor)
    m_WINXPBorderColor = PropBag.ReadProperty("WINXPBorderColor", m_def_WINXPBorderColor)
    
    m_DropDownListBackColor = PropBag.ReadProperty("DropDownListBackColor", m_def_DropDownListBackColor)
    m_DropDownListHoverColor = PropBag.ReadProperty("DropDownListHoverColor", m_def_DropDownListHoverColor)
    m_DropDownListBorderColor = PropBag.ReadProperty("DropDownListBorderColor", m_def_DropDownListBorderColor)
    m_DropDownListIconsBackColor = PropBag.ReadProperty("DropDownListIconsBackColor", m_def_DropDownListIconsBackColor)
    
    m_FontColor = PropBag.ReadProperty("FontColor", m_def_FontColor)
    m_FontHighlightColor = PropBag.ReadProperty("FontHighlightColor", m_def_FontHighlightColor)
    
    txtText.text = PropBag.ReadProperty("Caption", "Caption")
    Set txtText.Font = PropBag.ReadProperty("Font", Ambient.Font)
    txtText.ToolTipText = PropBag.ReadProperty("ToolTipText", "")
    m_TextAlign = PropBag.ReadProperty("TextAlign", m_def_TextAlign)
    
    m_Autocomplete = PropBag.ReadProperty("Autocomplete", m_def_Autocomplete)
    m_Enabled = PropBag.ReadProperty("Enabled", m_def_Enabled)
    m_Style = PropBag.ReadProperty("Style", m_def_Style)
    txtText.Enabled = m_Enabled
    picButton.Enabled = m_Enabled
End Sub

'Escribir valores de propiedad en el almacén
Private Sub UserControl_WriteProperties(PropBag As PropertyBag)

    Call PropBag.WriteProperty("HoverColor", m_HoverColor, m_def_HoverColor)
    Call PropBag.WriteProperty("BackColor", m_Backcolor, m_def_BackColor)
    Call PropBag.WriteProperty("MSOXPColor", m_MSOXPColor, m_def_MSOXPColor)
    Call PropBag.WriteProperty("MSOXPHoverColor", m_MSOXPHoverColor, m_def_MSOXPHoverColor)
    Call PropBag.WriteProperty("WINXPColor", m_WINXPColor, m_def_WINXPColor)
    Call PropBag.WriteProperty("WINXPHoverColor", m_WINXPHoverColor, m_def_WINXPHoverColor)
    Call PropBag.WriteProperty("WINXPBorderColor", m_WINXPBorderColor, m_def_WINXPBorderColor)
    
    Call PropBag.WriteProperty("DropDownListBackColor", m_DropDownListBackColor, m_def_DropDownListBackColor)
    Call PropBag.WriteProperty("DropDownListHoverColor", m_DropDownListHoverColor, m_def_DropDownListHoverColor)
    Call PropBag.WriteProperty("DropDownListBorderColor", m_DropDownListBorderColor, m_def_DropDownListBorderColor)
    Call PropBag.WriteProperty("DropDownListIconsBackColor", m_DropDownListIconsBackColor, m_def_DropDownListIconsBackColor)
    
    Call PropBag.WriteProperty("FontColor", m_FontColor, m_def_FontColor)
    Call PropBag.WriteProperty("FontHighlightColor", m_FontHighlightColor, m_def_FontHighlightColor)
    
    Call PropBag.WriteProperty("Caption", txtText.text, "Caption")
    Call PropBag.WriteProperty("Font", txtText.Font, Ambient.Font)
    Call PropBag.WriteProperty("ToolTipText", txtText.ToolTipText, "")
    Call PropBag.WriteProperty("TextAlign", m_TextAlign, m_def_TextAlign)
    
    Call PropBag.WriteProperty("Autocomplete", m_Autocomplete, m_def_Autocomplete)
    Call PropBag.WriteProperty("Icon", m_Icon, Nothing)
    Call PropBag.WriteProperty("Enabled", m_Enabled, m_def_Enabled)
    Call PropBag.WriteProperty("Style", m_Style, m_def_Style)
End Sub

'************************************************************'
'*                                                          *'
'*  Section: Miscelaneus Functions                          *'
'*                                                          *'
'***********************************************************

Private Sub UserControl_Paint()
    'Call All Drawing code
    Call DrawFace
End Sub

Private Sub DrawArrow(Optional bBlack As Boolean = True)
    '' This sub Draws the Small Down Arrow in the Classic Combo Box Button
    Dim lhdc As Long
    Dim lcw As Long, lch As Long
    Dim hPen As Long, hPenOld As Long
    Dim pt As PointAPI
    lcw = picButton.Width / 2
    lch = picButton.Height / 2
    lhdc = picButton.hdc
    hPen = CreatePen(0, 1, IIf(bBlack, 0, vbWhite))
    hPenOld = SelectObject(hdc, hPen)
    MoveToEx lhdc, lcw - 4, lch - 1, pt
    LineTo lhdc, lcw + 3, lch - 1
    MoveToEx lhdc, lcw - 3, lch, pt
    LineTo lhdc, lcw + 2, lch
    MoveToEx lhdc, lcw - 2, lch + 1, pt
    LineTo lhdc, lcw + 1, lch + 1
    MoveToEx lhdc, lcw - 1, lch + 2, pt
    LineTo lhdc, lcw, lch + 2
    SelectObject lhdc, hPenOld
    DeleteObject hPen
    DeleteObject hPenOld
End Sub

Private Sub DrawWinXPButton(Mode As State)
    '' This Sub Draws the XPStyle Button
    Dim lhdc As Long
    Dim tempColor As Long
    Dim lh As Long, lw As Long
    Dim lcw As Long, lch As Long
    Dim lStep As Single
    Dim ni As Single
    lw = picButton.Width
    lh = picButton.Height
    lhdc = picButton.hdc
    lcw = lw / 2
    lch = lh / 2
    UserControl.picButton.Cls
    lStep = 25 / lh
    Select Case Mode
    Case 0, 1:
        tempColor = IIf((Mode = Hover), OffsetColor(m_WINXPHoverColor, &H30), OffsetColor(m_WINXPColor, &H30))
        For ni = 0 To lh
            APILine lhdc, 0, lh - ni, lw, lh - ni, OffsetColor(tempColor, ni * lStep)
        Next ni
        APILine lhdc, 0, lh - 1, lw - 0, lh - 1, OffsetColor(tempColor, -64)
        APILine lhdc, 1, lh - 2, lw - 1, lh - 2, OffsetColor(tempColor, -32)
        APILine lhdc, lw - 1, 0, lw - 1, lh - 0, OffsetColor(tempColor, -32)
        APILine lhdc, lw - 2, 1, lw - 2, lh - 1, OffsetColor(tempColor, -12)
        APILine lhdc, 1, 0, lw - 1, 0, OffsetColor(tempColor, 19)
        APILine lhdc, 0, 1, lw - 1, 1, OffsetColor(tempColor, 32)
        APILine lhdc, 1, 2, 1, lh - 2, OffsetColor(tempColor, 4)
        picButton.PSet (1, 1), OffsetColor(tempColor, 48)
        picButton.PSet (1, lh - 2), OffsetColor(tempColor, -12)
        picButton.PSet (lw - 2, 1), OffsetColor(tempColor, 40)
        picButton.PSet (lw - 2, lh - 2), OffsetColor(tempColor, -64)
        picButton.PSet (0, 0), m_Backcolor 'OffsetColor(tempColor, 92) ' &HFCEEE6
        picButton.PSet (0, lh - 1), m_Backcolor 'OffsetColor(tempColor, 80) ' &HF9E6DC
        picButton.PSet (lw - 1, 0), m_Backcolor 'OffsetColor(tempColor, 80) '&HF6E3D9
        picButton.PSet (lw - 1, lh - 1), m_Backcolor 'OffsetColor(tempColor, 64) '&HF8E3D8
        
    Case 2:
        tempColor = OffsetColor(m_WINXPHoverColor, &H30) 'OffsetColor(RGB(127, 157, 255), &H30)
        For ni = 0 To lh
            APILine lhdc, 0, lh - ni, lw, lh - ni, OffsetColor(tempColor, -ni * lStep)
        Next ni
        APILine lhdc, 0, lh - 1, lw - 0, lh - 1, OffsetColor(tempColor, -16)
        APILine lhdc, 1, lh - 2, lw - 1, lh - 2, OffsetColor(tempColor, -24)
        APILine lhdc, lw - 1, 0, lw - 1, lh - 0, OffsetColor(tempColor, -32)
        APILine lhdc, lw - 2, 1, lw - 2, lh - 1, OffsetColor(tempColor, -24)
        APILine lhdc, 1, 0, lw - 1, 0, OffsetColor(tempColor, -64)
        APILine lhdc, 0, 1, lw - 1, 1, OffsetColor(tempColor, -32)
        APILine lhdc, 0, 1, 0, lh - 1, OffsetColor(tempColor, -64)
        APILine lhdc, 1, 2, 1, lh - 2, OffsetColor(tempColor, -32)
        picButton.PSet (1, 1), &HBF8D6F
        picButton.PSet (1, lh - 2), &HDFAD8F
        picButton.PSet (lw - 2, 1), &HDFAD8F
        picButton.PSet (lw - 2, lh - 2), &HFBC9AB
        
        picButton.PSet (0, 0), m_HoverColor '&HFCEEE6
        picButton.PSet (0, lh - 1), m_HoverColor '&HF9E6DC
        picButton.PSet (lw - 1, 0), m_HoverColor '&HF6E3D9
        picButton.PSet (lw - 1, lh - 1), m_HoverColor '&HF8E3D8
        lch = lch + 1
        lcw = lcw + 1
    Case 3:
        tempColor = GetSysColor(COLOR_BTNFACE) 'OffsetColor(GetSysColor(COLOR_BTNFACE), &H30)
        For ni = 0 To lh
            APILine lhdc, 0, lh - ni, lw, lh - ni, OffsetColor(tempColor, ni * lStep)
        Next ni
        APILine lhdc, 0, lh - 1, lw - 0, lh - 1, OffsetColor(tempColor, -64)
        APILine lhdc, 1, lh - 2, lw - 1, lh - 2, OffsetColor(tempColor, -32)
        APILine lhdc, lw - 1, 0, lw - 1, lh - 0, OffsetColor(tempColor, -32)
        APILine lhdc, lw - 2, 1, lw - 2, lh - 1, OffsetColor(tempColor, -12)
        APILine lhdc, 1, 0, lw - 1, 0, OffsetColor(tempColor, 19)
        APILine lhdc, 0, 1, lw - 1, 1, OffsetColor(tempColor, 32)
        'APILine lhdc, 0, 1, 0, lh - 1, vbRed 'OffsetColor(tempColor, -4)
        APILine lhdc, 1, 2, 1, lh - 2, OffsetColor(tempColor, 4)
        picButton.PSet (1, 1), &HFFEFD2
        picButton.PSet (1, lh - 2), &HFBC9AB
        picButton.PSet (lw - 2, 1), &HFFE3C5
        picButton.PSet (lw - 2, lh - 2), &HBF8D6F
        picButton.PSet (0, 0), &HFCEEE6
        picButton.PSet (0, lh - 1), &HF9E6DC
        picButton.PSet (lw - 1, 0), &HF6E3D9
        picButton.PSet (lw - 1, lh - 1), &HF8E3D8
    End Select
    '' Draw The XP Style Arrow
    APILine lhdc, lcw - 5, lch - 2, lcw, lch + 3, 0
    APILine lhdc, lcw - 4, lch - 2, lcw, lch + 2, 0
    APILine lhdc, lcw - 4, lch - 3, lcw, lch + 1, 0
    
    APILine lhdc, lcw + 3, lch - 2, lcw - 2, lch + 3, 0
    APILine lhdc, lcw + 2, lch - 2, lcw - 2, lch + 2, 0
    APILine lhdc, lcw + 2, lch - 3, lcw - 2, lch + 1, 0
        
End Sub

Private Sub DrawFace()
    ''Code for Button Drawing
    UserControl.ScaleMode = 3
    Dim rt As RECT, rtout As RECT
    Dim tmpState As State
    
    rt.Top = 0
    rt.Left = 0
    rt.Bottom = picButton.ScaleHeight
    rt.Right = picButton.ScaleWidth
    rtout.Top = 1
    rtout.Left = picButton.Left - 1
    rtout.Right = UserControl.ScaleWidth - 2
    rtout.Bottom = UserControl.ScaleHeight - 2
    
    tmpState = iState
    If OnFocus Then tmpState = Hover
    If bPressed Then tmpState = 2
    ''Control drawing
    
    Dim lw As Long, lh As Long
    Dim lUCHDC As Long, lPBHDC As Long
    Dim colorShadow As Long, colorLight As Long, colorBack As Long, colorFace As Long
    Dim ucRT        As RECT, rtIn As RECT
    
    lw = ScaleWidth
    lh = ScaleHeight
    lUCHDC = UserControl.hdc
    lPBHDC = picButton.hdc
    ucRT.Top = 0
    ucRT.Left = 0
    ucRT.Bottom = UserControl.ScaleHeight
    ucRT.Right = UserControl.ScaleWidth
    rtIn.Top = 1
    rtIn.Left = 1
    rtIn.Right = UserControl.ScaleWidth - 2
    rtIn.Bottom = UserControl.ScaleHeight - 2
    UserControl.Backcolor = IIf(iState = disabled, GetSysColor(COLOR_BTNFACE), IIf((iState <> Normal), m_HoverColor, m_Backcolor))
    txtText.Backcolor = IIf(iState = disabled, GetSysColor(COLOR_BTNFACE), IIf(iState = Normal, m_Backcolor, m_HoverColor))
    Select Case m_Style
    Case 0: 'Normal
        UserControl.Cls
        Call DrawEdge(UserControl.hdc, ucRT, EDGE_SUNKEN, BF_RECT)
        picButton.Backcolor = GetSysColor(COLOR_BTNFACE)
        Select Case tmpState
        Case 0  'Normal
            DrawEdge picButton.hdc, rt, EDGE_RAISED, BF_RECT
            txtText.ForeColor = m_FontColor
        Case 1  'Hover
            DrawEdge picButton.hdc, rt, EDGE_RAISED, BF_RECT
            txtText.ForeColor = m_FontHighlightColor
        Case 2  'Pushed
            txtText.ForeColor = m_FontHighlightColor
            DrawEdge picButton.hdc, rt, EDGE_SUNKEN, BF_RECT
        Case 3  'Disabled
            DrawEdge picButton.hdc, rt, EDGE_RAISED, BF_RECT
        End Select
        DrawArrow True
    Case 1: 'MSO2000
        Select Case tmpState
        Case 0
            UserControl.Backcolor = m_Backcolor
            UserControl.Cls
            txtText.ForeColor = m_FontColor
            ucRT.Bottom = UserControl.ScaleHeight - 1
            ucRT.Right = UserControl.ScaleWidth - 1
            APIRectangle UserControl.hdc, ucRT, GetSysColor(COLOR_BTNFACE)
            APIRectangle UserControl.hdc, rtIn, GetSysColor(COLOR_BTNFACE)
            picButton.Cls
            rt.Bottom = picButton.ScaleHeight - 1
            rt.Right = picButton.ScaleWidth - 1
            APIRectangle picButton.hdc, rt, m_Backcolor 'GetSysColor(COLOR_WINDOW)
        Case 1
            UserControl.Backcolor = m_HoverColor
            UserControl.Cls
            txtText.ForeColor = m_FontHighlightColor
            APIRectangle UserControl.hdc, rtIn, GetSysColor(COLOR_BTNFACE)
            Call DrawEdge(UserControl.hdc, ucRT, BDR_SUNKENOUTER, BF_RECT)
            picButton.Cls
            APILine UserControl.hdc, picButton.Left - 1, 2, picButton.Left - 1, UserControl.ScaleHeight - 2, GetSysColor(COLOR_BTNFACE)
            DrawEdge picButton.hdc, rt, BDR_RAISEDINNER, BF_RECT
        Case 2
            UserControl.Backcolor = m_HoverColor
            UserControl.Cls
            txtText.ForeColor = m_FontHighlightColor
            APIRectangle UserControl.hdc, rtIn, GetSysColor(COLOR_BTNFACE)
            Call DrawEdge(UserControl.hdc, ucRT, BDR_SUNKENOUTER, BF_RECT)
            picButton.Cls
            APILine UserControl.hdc, picButton.Left - 1, 2, picButton.Left - 1, UserControl.ScaleHeight - 2, GetSysColor(COLOR_BTNFACE)
            DrawEdge picButton.hdc, rt, BDR_SUNKENINNER, BF_RECT
        Case 3
            UserControl.Cls
            ucRT.Bottom = UserControl.ScaleHeight - 1
            ucRT.Right = UserControl.ScaleWidth - 1
            APIRectangle UserControl.hdc, rtIn, GetSysColor(COLOR_WINDOW)
            APIFillRect picButton.hdc, rt, GetSysColor(COLOR_BTNFACE)
        End Select
        DrawArrow True
    Case 2: 'MSOXP
        ucRT.Bottom = UserControl.ScaleHeight - 1
        ucRT.Right = UserControl.ScaleWidth - 1
        Select Case tmpState
        Case 0
            UserControl.Cls
            txtText.ForeColor = m_FontColor
            ucRT.Bottom = UserControl.ScaleHeight - 1
            ucRT.Right = UserControl.ScaleWidth - 1
            APIRectangle UserControl.hdc, ucRT, GetSysColor(COLOR_BTNFACE)
            APIRectangle UserControl.hdc, rtIn, GetSysColor(COLOR_BTNFACE)
            picButton.Cls
            rt.Bottom = picButton.ScaleHeight - 1
            rt.Right = picButton.ScaleWidth - 1
            APIRectangle picButton.hdc, rt, m_Backcolor
            DrawArrow True
        Case 1
            UserControl.Cls
            txtText.ForeColor = m_FontHighlightColor
            colorShadow = RGB(0, 0, 0)
            APIRectangle UserControl.hdc, rtIn, m_HoverColor
            APIRectangle UserControl.hdc, ucRT, m_MSOXPColor
            picButton.Cls
            APIFillRect picButton.hdc, rt, m_MSOXPColor '&HC08080
            APILine UserControl.hdc, picButton.Left - 1, 2, picButton.Left - 1, UserControl.ScaleHeight - 2, vbRed 'GetSysColor(COLOR_BTNFACE)
            APIRectangle UserControl.hdc, rtout, m_MSOXPColor '&HC08080
            DrawArrow False
        Case 2
            UserControl.Cls
            colorShadow = RGB(0, 0, 0)
            txtText.ForeColor = m_FontHighlightColor
            APIRectangle UserControl.hdc, rtIn, m_HoverColor
            APIRectangle UserControl.hdc, ucRT, m_MSOXPHoverColor
            picButton.Cls
            APIFillRect picButton.hdc, rt, m_MSOXPHoverColor
            APIRectangle UserControl.hdc, rtout, m_MSOXPHoverColor
            DrawArrow False
        Case 3
            UserControl.Cls
            ucRT.Bottom = UserControl.ScaleHeight - 1
            ucRT.Right = UserControl.ScaleWidth - 1
            APIRectangle UserControl.hdc, rtIn, GetSysColor(COLOR_WINDOW)
            APIFillRect picButton.hdc, rt, GetSysColor(COLOR_BTNFACE)
            DrawArrow False
        End Select
    Case 3: 'WINXP
        ucRT.Bottom = UserControl.ScaleHeight - 1
        ucRT.Right = UserControl.ScaleWidth - 1
        If iState = disabled Then
            picButton.Cls
            APIRectangle UserControl.hdc, ucRT, GetSysColor(COLOR_BTNSHADOW)
            APIRectangle UserControl.hdc, rtIn, GetSysColor(COLOR_WINDOW)
        Else
            UserControl.Cls
            If iState = Normal Then
                txtText.ForeColor = m_FontColor
                APIRectangle UserControl.hdc, rtIn, m_Backcolor
            Else
                txtText.ForeColor = m_FontHighlightColor
                APIRectangle UserControl.hdc, rtIn, m_HoverColor
            End If
            APIRectangle UserControl.hdc, ucRT, m_WINXPBorderColor 'RGB(127, 157, 185)
        End If
        '' This is too Complex, so I decided Put the Drawing Code in another sub.
        DrawWinXPButton tmpState
    End Select
End Sub

'' Restore Original Colors

Public Sub RestoreOriginalColors()
    Me.Backcolor = m_def_BackColor
    Me.HoverColor = m_def_HoverColor
    Me.MSOXPColor = m_def_MSOXPColor
    Me.MSOXPHoverColor = m_def_MSOXPHoverColor
    Me.WINXPColor = m_def_WINXPColor
    Me.WINXPHoverColor = m_def_WINXPHoverColor
    Me.FontColor = m_def_FontColor
    Me.FontHighlightColor = m_def_FontHighlightColor
    Me.WINXPBorderColor = m_def_WINXPBorderColor
End Sub

'' Remove all Items In the List
Public Sub Clear()
    Dim Item
    For Each Item In m_Items
        m_Items.Remove (Item)
        m_Images.Remove (Item)
    Next Item
    m_SelectedItem = 0
End Sub

Public Sub Remove(Item)
    m_Images.Remove (Item)
    m_Items.Remove (Item)
End Sub

'' Add a new Item to the Combo List
Public Sub AddItem(text As String, Optional Index As Integer, Optional iImage As Picture)
    Dim ImageTemp As Picture
    If IsMissing(iImage) Then
        Set ImageTemp = LoadPicture()
    Else
        Set ImageTemp = iImage
    End If
    m_Items.Add text, text
    m_Images.Add ImageTemp, text
End Sub


