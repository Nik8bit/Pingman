#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Pingman.ico
#AutoIt3Wrapper_Res_Description=Pingman 1.0
#AutoIt3Wrapper_Res_ProductName=Pingman
#AutoIt3Wrapper_Res_ProductVersion=1.0
#AutoIt3Wrapper_Res_CompanyName=ZEDNA
#AutoIt3Wrapper_Res_LegalCopyright=ZEDNA
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiIPAddress.au3>
#include <GUIListBox.au3>
#include <SliderConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>


#Region ### START Koda GUI section ### Form=D:\PROJECTS\Pingman\GUI_MGMT.kxf
$GUI_MGMT = GUICreate("Pingman", 368, 454, -1, -1)
$IPAddress = _GUICtrlIpAddress_Create($GUI_MGMT, 32, 32, 226, 21)
;~ _GUICtrlIpAddress_Set($IPAddress, "0.0.0.0")
$List1 = GUICtrlCreateList("", 32, 64, 225, 305)
;~ GUICtrlSetData(-1, "192.168.1.1|8.8.4.4|8.8.8.8")
$Button_Add = GUICtrlCreateButton("&Add", 272, 30, 75, 25)
$Button_Delete = GUICtrlCreateButton("&Delete", 272, 80, 75, 25)
$Input_Timeout = GUICtrlCreateInput("250", 112, 376, 73, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_NUMBER))
$Label1 = GUICtrlCreateLabel("Timeout [in ms] :", 32, 378, 81, 17)
$Input_Interval = GUICtrlCreateInput("1000", 256, 376, 73, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_NUMBER))
$Label2 = GUICtrlCreateLabel("Ping Interval:", 191, 378, 66, 17)
$Button_Start = GUICtrlCreateButton("&Start", 272, 128, 75, 25)
$Label3 = GUICtrlCreateLabel("Transparency", 32, 408, 69, 17)
$Label4 = GUICtrlCreateLabel("Coded by Nikhil[ZEDNA]", 216, 432, 121, 17)
$Slider_TP = GUICtrlCreateSlider(112, 402, 150, 29, BitOR($GUI_SS_DEFAULT_SLIDER,$TBS_NOTICKS))
GUICtrlSetLimit(-1, 255, 55)
GUICtrlSetData(-1, 128)
Dim $GUI_MGMT_AccelTable[1][2] = [["{enter}", $Button_Add]]
GUISetAccelerators($GUI_MGMT_AccelTable)
;Ini Read Start
$ini_Timeout = IniRead("Settings.ini","Main","Timeout","250")
$ini_Interval = IniRead("Settings.ini","Main","Interval","1000")
$ini_Transparency = IniRead("Settings.ini","Main","Transparency","128")
GUICtrlSetData($Input_Timeout,$ini_Timeout)
GUICtrlSetData($Input_Interval,$ini_Interval)
GUICtrlSetData($Slider_TP,$ini_Transparency)
;Ini Read End

;IP Read Start
	Local $aArray = FileReadToArray("IP.txt")
	Local $iLineCount = @extended
	If @error Then
	Else
		For $i = 0 To $iLineCount - 1
			If _IsIP4($aArray[$i]) Then
				GUICtrlSetData($List1,$aArray[$i])
			EndIf
		Next
	EndIf
;IP Read End


GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


Dim $aIplist [1]
Dim $aLabel[1][2]
Dim $aLabelOut[1][1]
Global $iInterval,$iTimeout
$iTimeout = 100

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			$iInterval = GUICtrlRead($Input_Interval)
			$iTimeout = GUICtrlRead($Input_Timeout)
			$iTransparency = GUICtrlRead($Slider_TP)
			IniWrite("Settings.ini","Main","Timeout",$iTimeout)
			IniWrite("Settings.ini","Main","Interval",$iInterval)
			IniWrite("Settings.ini","Main","Transparency",$iTransparency)
			FileDelete("IP.txt")
			Local $hFileOpen = FileOpen("IP.txt", $FO_APPEND)
;~ 			If $hFileOpen = -1 Then
;~ 				MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the file.")
;~ 			EndIf
			$Ipcount = _GUICtrlListBox_GetCount($List1)
			If $Ipcount > 0 Then
				For $i = 0 To $Ipcount - 1
					 FileWriteLine($hFileOpen, _GUICtrlListBox_GetText($List1,$i) & @CRLF)
				Next
			EndIf
			FileClose($hFileOpen)

			Exit


		Case $Button_Add
			$Ipcount = _GUICtrlListBox_GetCount($List1)
			$bIpExist = 0
			If $Ipcount > 0 Then
				For $i = 0 To $Ipcount
					If _GUICtrlListBox_GetText($List1,$i) =  _GUICtrlIpAddress_Get($IPAddress) Then
						$bIpExist = 1
						MsgBox(0,"","IP Already Exist","",$GUI_MGMT)
						ExitLoop
					EndIf
				Next
			If $bIpExist = 0 Then GUICtrlSetData($List1, _GUICtrlIpAddress_Get($IPAddress)&"|")
			ElseIf $Ipcount = 0 Then
				GUICtrlSetData($List1, _GUICtrlIpAddress_Get($IPAddress)&"|")
			EndIf
			_GUICtrlIpAddress_ClearAddress($IPAddress)
			_GUICtrlIpAddress_SetFocus($IPAddress,0)
		Case $Button_Delete
			$iSelectedindex = _GUICtrlListBox_GetCurSel($List1)
			If $iSelectedindex >= 0 Then
				$Answer = MsgBox(4,"Aare you sure?", "Do you want to delete " & _GUICtrlListBox_GetText($List1,$iSelectedindex) &"?","",$GUI_MGMT)
				If $Answer = 6 Then
					_GUICtrlListBox_DeleteString($List1,$iSelectedindex)
				EndIf
			EndIf

		Case $Button_Start
			$Ipcount = _GUICtrlListBox_GetCount($List1)
			If $Ipcount > 0 Then
				ReDim $aIplist[$Ipcount + 1]
				$aIplist[0] = $Ipcount
				For $i = 0 To $Ipcount - 1
					 $aIplist[$i + 1] = _GUICtrlListBox_GetText($List1,$i)
				Next
			$iInterval = GUICtrlRead($Input_Interval)
			$iTimeout = GUICtrlRead($Input_Timeout)
			$iTransparency = GUICtrlRead($Slider_TP)
			$iTransparency = Abs($iTransparency - 255 -55)

			_OverlayGui($aIplist,$iTimeout,$iInterval,$iTransparency)
			EndIf
	EndSwitch
WEnd





Func _OverlayGui($aInArray, $fniTimeout, $fniInterval, $fniTransp)

	If $fniInterval < 500 Then
		MsgBox(0,"Error","Interval cannot be less than 500ms","",$GUI_MGMT)
		Return
	EndIf
	If $fniTimeout < 1 Then
		MsgBox(0,"Error","Timout cannot be less than 1ms","",$GUI_MGMT)
		Return
	EndIf
	_EnableControls(False)

	#Region ### START Koda GUI section ### Form=D:\PROJECTS\Pingman\GUI_OL.kxf
	$iOVGUI_Height = 66
	$ini_OLguiX = IniRead("Settings.ini","OverlayWin","Xpos","-1")
	$ini_OLguiY = IniRead("Settings.ini","OverlayWin","Ypos","-1")
	$GUI_OL = GUICreate("Pingman", 250, $iOVGUI_Height, $ini_OLguiX, $ini_OLguiY, $WS_SYSMENU, BitOR($WS_EX_TOOLWINDOW,$WS_EX_TOPMOST))

	$iInarrayCount = $aInArray[0]
	Dim $aLabel[$iInarrayCount][2]
	Dim $aLabelOut[$iInarrayCount][1]

	$iCurTop = 16

	For $i = 0 to $aInArray[0] - 1
		$aLabel[$i][0] = GUICtrlCreateLabel($aInArray[$i+1], 16, $iCurTop, 110, 17, $SS_CENTER)
		GUICtrlSetBkColor(-1, 0xFF0000)
		$aLabel[$i][1] = $aInArray[$i+1]
		$aLabelOut[$i][0] = GUICtrlCreateLabel("Pending...", 136, $iCurTop, 189, 17)
		$iCurTop += 16
		$iOVGUI_Height += 16
	Next
	WinMove($GUI_OL,"",$ini_OLguiX, $ini_OLguiY,250,$iOVGUI_Height)
	WinSetTrans($GUI_OL,"",$fniTransp)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###
	AdlibRegister("_PingThread",$iInterval)
	While 1
		$nMsg2 = GUIGetMsg()
		Switch $nMsg2
			Case $GUI_EVENT_CLOSE
				AdlibUnRegister("_PingThread")
				$aWinpos = WinGetPos($GUI_OL)
				IniWrite("Settings.ini","OverlayWin","Xpos",$aWinpos[0])
				IniWrite("Settings.ini","OverlayWin","Ypos",$aWinpos[1])
				GUIDelete($GUI_OL)
				_EnableControls(True)

				Return
			Case $Slider_TP
				$iTransparency = GUICtrlRead($Slider_TP)
				$iTransparency = Abs($iTransparency - 255 -55)
				WinSetTrans($GUI_OL,"",$iTransparency)
		EndSwitch
	WEnd
	EndFunc

Func _PingThread()
	AdlibUnRegister("_PingThread")
	For $i = 0 to $aIplist[0] - 1
		$ipRead = GUICtrlRead($aLabel[$i][0])
		$iPing = Ping($ipRead,$iTimeout)
		If $iPing Then
			GUICtrlSetBkColor($aLabel[$i][0], 0x00FF00)
			GUICtrlSetData($aLabelOut[$i][0],$iPing & " ms." )
		Else
			If @error = 1 Then	GUICtrlSetData($aLabelOut[$i][0],"Host is offline" )
			If @error = 2 Then	GUICtrlSetData($aLabelOut[$i][0],"Host is unreachable" )
			If @error = 3 Then	GUICtrlSetData($aLabelOut[$i][0],"Bad destination" )
			If @error = 4 Then	GUICtrlSetData($aLabelOut[$i][0]," Other errors " )
			GUICtrlSetBkColor($aLabel[$i][0], 0xFF0000)

		EndIf
	Next
AdlibRegister("_PingThread",$iInterval)
EndFunc

Func _EnableControls($fnB_input)
	If $fnB_input = False Then
		GUICtrlSetState($Button_Add,$GUI_DISABLE)
		GUICtrlSetState($Button_Delete,$GUI_DISABLE)
		GUICtrlSetState($Button_Start,$GUI_DISABLE)
		GUICtrlSetState($Input_Interval,$GUI_DISABLE)
		GUICtrlSetState($Input_Timeout,$GUI_DISABLE)
	ElseIf $fnB_input = True Then
		GUICtrlSetState($Button_Add,$GUI_ENABLE)
		GUICtrlSetState($Button_Delete,$GUI_ENABLE)
		GUICtrlSetState($Button_Start,$GUI_ENABLE)
		GUICtrlSetState($Input_Interval,$GUI_ENABLE)
		GUICtrlSetState($Input_Timeout,$GUI_ENABLE)
	EndIf
EndFunc

Func _IsIP4($sIP4)
    Return StringRegExp($sIP4, '^(?:(?:2(?:[0-4]\d|5[0-5])|1?\d{1,2})\.){3}(?:(?:2(?:[0-4]\d|5[0-5])|1?\d{1,2}))$')
EndFunc