; Actual Automation Script
; Author: James F

#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <Date.au3>
#include <Excel.au3>
#include <Array.au3>
#include <AutoItConstants.au3>
#include <Clipboard.au3>

Global $g_bPaused = False

HotKeySet("{PAUSE}", "TogglePause")

Func TogglePause()
    $g_bPaused = Not $g_bPaused
    While $g_bPaused
        Sleep(100)
        ToolTip('Script is "Paused"', 0, 0)
    WEnd
    ToolTip("")
EndFunc   ;==>TogglePause

; Variable declaration
Global $GastroPlus, $GastroPlustext, $GastroPlusclass
Dim $flag = False

;Sets hotkey for resume
Hotkeyset("{HOME}", "a2")

;Timeout function
Local $time = TimerInit()
AdlibRegister("_Timeout", 1000)

Func _Timeout()
	If TimerDiff($time) > 100 * 1000 Then; wait for 100 seconds
		ConsoleWrite("Error 000")
		Kill()
	Else
	;nah
	EndIf
EndFunc

;For ending process
Func Kill()
		;empty clipboard (in case it can't handle thousands of simulations of data)
		_ClipBoard_Empty()

		;minimize GastroPlus if it is open
		;Find handle for GastroPlus
		$GastroPlus = "GastroPlus(TM):"
		$GastroPlustext = "Population Simulator"
		$GastroPlusclass = "ThunderRT6FormDC"
		Local $GastroPlus_handle = Window_Handle($GastroPlus, $GastroPlusclass, $GastroPlustext)
		;minimize it
		If WinExists($GastroPlus_handle) Then
		WinSetState($GastroPlus_handle, "", @SW_MINIMIZE)
		EndIf

		Exit
EndFunc

;Generates window handle
Func Window_Handle($title, $class, $text)
	Local $handle = WinGetHandle("[TITLE:" & $title & ";CLASS:" & $class & ";]", $text)
	Return $handle
EndFunc

;For pressing HOME to resume or whatever
	Func a2()
		$flag= Not $flag
	EndFunc

;Find handle for GastroPlus
$GastroPlus = "GastroPlus(TM):"
$GastroPlustext = "Population Simulator"
$GastroPlusclass = "ThunderRT6FormDC"
Local $GastroPlus_handle = Window_Handle($GastroPlus, $GastroPlusclass, $GastroPlustext)

;Check if GastroPlus is open
If WinExists($GastroPlus_handle) Then
	;You good, just activate it
	WinActivate($GastroPlus_handle)
	;Local $a = 0
Else
	;Send error code 002
	ConsoleWrite("Error 002" & @CRLF)

	Kill()
EndIf

;Activate window
WinActivate($GastroPlus_handle)
;Find window location
Local $Win_pos1 = WinGetPos($GastroPlus_handle)

;;;;;;;;;;;;;;;;;;;;;;;;Pre-sim;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;4) Upload ACAT file
If $CmdLine[4] <> "0" Then
	Local $__filename = $CmdLine[4]
	Local $filename = @ScriptDir & $__filename
	Local $output4 = four($filename)

EndIf

;5) PK parameters
If $CmdLine[5] <> "0" Then
	Local $output5 = five($CmdLine[5])
EndIf

;6) Upload .dsd file
If $CmdLine[6] <> "0" Then
	Local $_dsd_filename = $CmdLine[6]
	Local $dsd_filename = @ScriptDir & $_dsd_filename
	Local $output6 = six($dsd_filename)
EndIf

;7) Enterohepatic circulation parameters
If $CmdLine[7] <> "0" Then
	Local $output7 = seven($CmdLine[7])
EndIf

;8) Upload drug table
If $CmdLine[8] <> "0" Then
	Local $_drug_filename = $CmdLine[8]
	Local $drug_filename = @ScriptDir & $_drug_filename
	Local $output8 = eight($drug_filename)
EndIf

;9) Upload pka table
If $CmdLine[9] <> "0" Then
	Local $_pka_filename = $CmdLine[9]
	Local $pka_filename = @ScriptDir & $_pka_filename
	Local $output9 = nine($pka_filename)
EndIf

;;;;;;;;;;;;;;;;;;;;;;;;;sim;;;;;;;;;;;;;;;;;;;;;;;

;1)Run simulation
If $CmdLine[1] <> "0" Then
	Local $output1 = one()
EndIf

;;;;;;;;;;;;;;;;;;;;;;;;;Post-sim;;;;;;;;;;;;;;;;;;;;;;;

;2) Copy plasma conc data (cmax, tmax, auc_0_inf, auc_0_t)
If $CmdLine[2] <> "0" Then
	;Find excel file
	Local $__excel_file = $CmdLine[2]
	Local $excel_file = @ScriptDir & $__excel_file
	Local $output2 = two($excel_file)
EndIf

;3) Copy plasma conc profile
If $CmdLine[3] <> "0" Then
	;Find excel file
	Local $__excel_file = $CmdLine[3]
	Local $excel_file = @ScriptDir & $__excel_file
	Local $output3 = three($excel_file)
EndIf

;10) Copy regional absorption
If $CmdLine[10] <> "0" Then
	;Find excel file
	Local $__excel_file = $CmdLine[10]
	Local $excel_file = @ScriptDir & $__excel_file
	Local $output3 = ten($excel_file)
EndIf

;;;;;;;;;;Modules;;;;;;;;;;;

;1)Run simulation
Func one()


;Activate GastroPlus
WinActivate($GastroPlus_handle)

;Click start simulation
ControlClick($GastroPlus_handle, "", 55, "primary")

;Switch tabs
Local $Ctrl_pos1 = ControlGetPos($GastroPlus_handle, "", "SSTabCtlWndClass1")
ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.6975*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])

;Click OK on Start Sim check if it comes up. Might need to expand on this later
$_title6 = "Start Simulation Check"
$win_exists6 = WinWaitActive($_title6, "", 1.5) ;Waits up to 1.5 seconds for the popup to come up

If $win_exists6 <> 0 Then
	;Find popup handle
	$_text6 = "&OK"
	$_class6 = "ThunderRT6FormDC"
	Local $_handle6 = Window_Handle($_title6, $_class6, $_text6)
	;Click Yes
	ControlClick($_handle6, "", 2, "primary")
EndIf


;Checking if sim is done by seeing if the button says Start or Pause. Check is every .5 seconds
Local $c = 0
Local $d = 0
Local $it = 0 ;Just in case this goes forever, it will end the check at 30 secs
While $d <> 2
	;Read control Text
	$c = ControlGetText($GastroPlus_handle, "", 55)
	;Check if it says Pause yet
	If $d = 0 Then
		If $c = "Pause" Then
			$d = 1
		EndIf
	EndIf

	;Once it says Pause, check if it says Start
	If $d = 1 Then
		If $c = "S&tart" Then
			$d = 2
		EndIf
	EndIf

	;Every 5 seconds, check if error about convergence happens
	If $d = 1 AND Mod($it, 5) = 0 Then

		;Find error window handle
		$error1 = "GastroPlus"
		$error1text = "Integration cannot converge"
		$error1class = "#32770"
		Local $error1_handle = Window_Handle($error1, $error1class, $error1text)

		;Check if the handle exists. If it does, kill everything and send error
		If WinExists($error1_handle) Then

			;Click OK
			ControlClick($error1_handle, "", 2, "primary")

			;end script

			;Send error code 001
			ConsoleWrite("Error 001" & @CRLF)

			Kill()
			Exit

		EndIf

	EndIf

	;End after 30 secs
	If $it = 60 Then
		$d = 2
	EndIf

	;Wait .5 seconds
	Sleep(500)
	$it = $it + 1
WEnd

;Activate GastroPlus
WinActivate($GastroPlus_handle)
EndFunc

;2) Copy plasma conc data (cmax, tmax, auc_0_inf, auc_0_t)
Func two($excel_file)

	;Activate GastroPlus
	WinActivate($GastroPlus_handle)

	;Switch tabs to sim tab
	Local $Ctrl_pos1 = ControlGetPos($GastroPlus_handle, "", "SSTabCtlWndClass1")
	ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.6975*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])

	;Right click and copy sim data to clipbaord
	;Just saying right click the control doesn't always work. Using ControlGetPos to find where to move mouse first.
	Local $Ctrl_pos2 = ControlGetPos($GastroPlus_handle, "", 173)
	MouseMove($Win_pos1[0] + $Ctrl_pos2[0] + .5*$Ctrl_pos2[2], $Win_pos1[1] + $Ctrl_pos2[1] + .5*$Ctrl_pos2[3], 0)
	ControlClick($GastroPlus_handle, "", 173, "secondary")

	;Being sneaky here because it is not clear what the best way to click within the menu is
	Send("{DOWN}""{ENTER}")

	;Wait so that program pastes the correct data
	Sleep(400)

	;Find handle for Excel
	$Excel = "data_collection"
	$Exceltext = "data_collection"
	$Excelclass = "XLMAIN"
	Global $Excel_handle = Window_Handle($Excel, $Excelclass, $Exceltext)

	;Activate window
	WinActivate($Excel_handle)
	;Waits for Excel to active for 5 secs.
	WinWaitActive($Excel_handle, "", 5)

	;Click in the spreadsheet area to make sure it is active
	$excel_top = WinGetPos($Excel_handle, "") ;Directly clicking the spreadsheet is iffy so I'm doing it harder just to make it more likely to work
	MouseClick("primary", $excel_top[0] + $excel_top[2]*.5, $excel_top[1] + $excel_top[3]*.5, 1, 3);Click right in the middle of the window. Hopefully this is the spreadsheet
	Sleep(50)

	;Paste data
	;Click A2
	$oWorkbook = _Excel_BookAttach($excel_file)
	If @error Then ConsoleWrite(@error)
	$oWorkbook.ActiveSheet.Range("A2").Select
	;Paste
	Send("^v")

	;Copy cell values and send to MATLAB
	;Drug name
	Local $drug = _Excel_RangeRead($oWorkbook, Default, "B4")
	ConsoleWrite("Drug: " & $drug & @CRLF)
	;Cmax
	Local $Cmax = _Excel_RangeRead($oWorkbook, Default, "C13")
	ConsoleWrite("Cmax: " & $Cmax & @CRLF)
	;Tmax
	Local $Tmax = _Excel_RangeRead($oWorkbook, Default, "C14")
	ConsoleWrite("Tmax: " & $Tmax & @CRLF)
	;AUC 0-inf
	Local $AUC0i = _Excel_RangeRead($oWorkbook, Default, "C15")
	ConsoleWrite("AUC (0-inf): " & $AUC0i & @CRLF)
	;AUC 0-t
	Local $AUC0t = _Excel_RangeRead($oWorkbook, Default, "C16")
	ConsoleWrite("AUC (0-t): " & $AUC0t & @CRLF)
	;Fa%
	Local $AUC0t = _Excel_RangeRead($oWorkbook, Default, "C10")
	ConsoleWrite("Fa %: " & $AUC0t & @CRLF)
	;FDp%
	Local $AUC0t = _Excel_RangeRead($oWorkbook, Default, "C11")
	ConsoleWrite("FDp %: " & $AUC0t & @CRLF)
	;F%
	Local $AUC0t = _Excel_RangeRead($oWorkbook, Default, "C12")
	ConsoleWrite("F %: " & $AUC0t & @CRLF)


	;minimize excel
	WinSetState($Excel_handle, "", @SW_MINIMIZE)

	;Activate GastroPlus
	WinActivate($GastroPlus_handle)

EndFunc

;3) Copy plasma conc profile
Func three($excel_file)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

;Switch to graph tab
Local $Ctrl_pos1 = ControlGetPos($GastroPlus_handle, "", "SSTabCtlWndClass1")
ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.8572*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])

;Open Cp time
ControlClick($GastroPlus_handle, "", 17)
Sleep(50)

;Cp-Time button location
Local $Ctrl_pos3 = ControlGetPos($GastroPlus_handle, "", 17)
;Go to Cp-Time button location, then go 3 Cp-Time buttons to the right
Local $Ctrl_pos2 = ControlGetPos($GastroPlus_handle, "", 173)
MouseMove($Win_pos1[0] + $Ctrl_pos3[0] + 3*$Ctrl_pos3[2], $Win_pos1[1] + $Ctrl_pos2[1], 0)
Sleep(200)
MouseClick($MOUSE_CLICK_RIGHT)
Sleep(200)

;Being sneaky here because it is not clear what the best way to click within the menu is
Send("{DOWN}")
Sleep(300)
Send("{DOWN}")
Sleep(300)
Send("{ENTER}")

;Wait so that program pastes the correct data
Sleep(500)

;Find handle for Excel
$Excel = "data_collection"
$Exceltext = "data_collection"
$Excelclass = "XLMAIN"
Global $Excel_handle = Window_Handle($Excel, $Excelclass, $Exceltext)

;Activate excel window
WinActivate($Excel_handle)
;Waits for Excel to open for 10 secs.
WinWaitActive($Excel_handle, "", 10)

;Click in the spreadsheet area to make sure it is active
$excel_top = WinGetPos($Excel_handle, "") ;Directly clicking the spreadsheet is iffy so I'm doing it harder just to make it more likely to work
MouseClick("primary", $excel_top[0] + $excel_top[2]*.5, $excel_top[1] + $excel_top[3]*.5, 1, 3);Click right in the middle of the window. Hopefully this is the spreadsheet
Sleep(100)

;Click E2
$oWorkbook = _Excel_BookAttach($excel_file)
$oWorkbook.ActiveSheet.Range("E2").Select
Sleep(200)

;Paste
Send("^v")

;Check if paste worked properly
$oWorkbook.ActiveSheet.Range("E2").Select
$paste_check = $oWorkbook.ActiveSheet.Range("E2").Text

If $paste_check <> "SimTime (h)" Then
	;try copy and pasting again

	;Minimize excel
	WinSetState($Excel_handle, "", @SW_MINIMIZE)

	;Copy data
	ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.8572*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])
	;Cp-Time button location
	Local $Ctrl_pos3 = ControlGetPos($GastroPlus_handle, "", 17)
	;Go to Cp-Time button location, then go 3 Cp-Time buttons to the right
	Local $Ctrl_pos2 = ControlGetPos($GastroPlus_handle, "", 173)
	MouseMove($Win_pos1[0] + $Ctrl_pos3[0] + 3*$Ctrl_pos3[2], $Win_pos1[1] + $Ctrl_pos2[1], 0)
	Sleep(300)
	MouseClick($MOUSE_CLICK_RIGHT)
	Sleep(300)

	;Being sneaky here because it is not clear what the best way to click within the menu is
	Send("{DOWN}")
	Sleep(200)
	Send("{DOWN}")
	Sleep(200)
	Send("{ENTER}")

	;Wait so that program pastes the correct data
	Sleep(750)

	;Find handle for Excel
	$Excel = "data_collection"
	$Exceltext = "data_collection"
	$Excelclass = "XLMAIN"
	Global $Excel_handle = Window_Handle($Excel, $Excelclass, $Exceltext)

	;Activate excel window
	WinActivate($Excel_handle)
	;Waits for Excel to open for 5 secs.
	WinWaitActive($Excel_handle, "", 5)

	;Click E2
	$oWorkbook = _Excel_BookAttach($excel_file)
	$oWorkbook.ActiveSheet.Range("E2").Select
	Sleep(100)

	;Paste
	Send("^v")

	;Check if paste worked properly, again
	$oWorkbook.ActiveSheet.Range("E2").Select
	$paste_check2 = $oWorkbook.ActiveSheet.Range("E2").Text
	If $paste_check <> "SimTime (h)" Then
		;try copy and pasting again

		;Minimize excel
		WinSetState($Excel_handle, "", @SW_MINIMIZE)

		;Copy data
		ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.8572*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])
		;Cp-Time button location
		Local $Ctrl_pos3 = ControlGetPos($GastroPlus_handle, "", 17)
		;Go to Cp-Time button location, then go 3 Cp-Time buttons to the right
		Local $Ctrl_pos2 = ControlGetPos($GastroPlus_handle, "", 173)
		MouseMove($Win_pos1[0] + $Ctrl_pos3[0] + 3*$Ctrl_pos3[2], $Win_pos1[1] + $Ctrl_pos2[1], 0)
		Sleep(300)
		MouseClick($MOUSE_CLICK_RIGHT)
		Sleep(300)

		;Being sneaky here because it is not clear what the best way to click within the menu is
		Send("{DOWN}")
		Sleep(300)
		Send("{DOWN}")
		Sleep(300)
		Send("{ENTER}")

		;Wait so that program pastes the correct data
		Sleep(1000)

		;Find handle for Excel
		$Excel = "data_collection"
		$Exceltext = "data_collection"
		$Excelclass = "XLMAIN"
		Global $Excel_handle = Window_Handle($Excel, $Excelclass, $Exceltext)

		;Activate excel window
		WinActivate($Excel_handle)
		;Waits for Excel to open for 5 secs.
		WinWaitActive($Excel_handle, "", 5)

		;Click E2
		$oWorkbook = _Excel_BookAttach($excel_file)
		$oWorkbook.ActiveSheet.Range("E2").Select
		Sleep(100)

		;Paste
		Send("^v")

	EndIf
EndIf


;Click E3
$oWorkbook.ActiveSheet.Range("E3").Select

;Shift+Ctrl+-->, Shift+Ctrl+[down arrow]
Send("^+{RIGHT}")
Sleep(200)
Send("^+{DOWN}")
Sleep(300)

;Copy plasma conc data
Send("^c")
Sleep(300)

;Get data from clipboard
Local $profile = _ClipBoard_GetData($CF_TEXT)
Sleep(300)

;Clear plasma conc data. Weirdly I have to paste before doing this
Send("{DEL}")

;Send plasma conc profile
ConsoleWrite("pc start" & $profile & "pc end")

;minimize excel
WinSetState($Excel_handle, "", @SW_MINIMIZE)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc

;4) Upload ACAT file
Func four($filename)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

;Click Compound tab, wait a little for switch to happen
Local $Ctrl_pos1 = ControlGetPos($GastroPlus_handle, "", "SSTabCtlWndClass1")
ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.1*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])
Sleep(200)

;File > Load > A Load User-defined ACAT model (.cat)
WinMenuSelectItem($GastroPlus_handle, "", "&File", "&Load", "  &A Load User-defined ACAT Model (.cat)")

;Paste given file location
Send($filename)

;Click Open
Local $popup1 = Window_Handle("Load User-defined ACAT Model", "#32770" ,"")
ControlClick($popup1, "", 1, "primary")

;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc

;5) Upload PK parameters (later)
Func five($PK_params)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

;String of values is sent with hyphens inbetween to keep all the values in one variable while passed
;Separate string into a bunch of values
$PK_params_input = StringSplit($PK_params, "+")

$Body_weight = $PK_params_input[1]
$Blood_Plasma_Conc_Ratio = $PK_params_input[2]
$Exp_Plasma_Fup = $PK_params_input[3]
$CL = $PK_params_input[4]
$Vc = $PK_params_input[5]
$K12 = $PK_params_input[6]
$K21 = $PK_params_input[7]
$K13 = $PK_params_input[8]
$K31 = $PK_params_input[9]
$Renal_clearance = $PK_params_input[10]
$FPE_intestinal = $PK_params_input[11]
$FPE_liver = $PK_params_input[12]

;Click Pharmacokinetics tab, wait a little for switch
Local $Ctrl_pos1 = ControlGetPos($GastroPlus_handle, "", "SSTabCtlWndClass1")
ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.5*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])
Sleep(200)

;If the value isn't 54875 then change the value

If $Body_weight <> 54875 Then
;Body_weight
ControlSetText($GastroPlus_handle, "", 111, $Body_weight)
EndIf

If $Blood_Plasma_Conc_Ratio <> 54875 Then
;Blood_Plasma_Conc_Ratio
ControlSetText($GastroPlus_handle, "", 100, $Blood_Plasma_Conc_Ratio)
EndIf

If $Exp_Plasma_Fup <> 54875 Then
;Exp_Plasma_Fup
ControlSetText($GastroPlus_handle, "", 104, $Exp_Plasma_Fup)
EndIf

If $CL <> 54875 Then
;CL
ControlSetText($GastroPlus_handle, "", 109, $CL)
EndIf

If $Vc <> 54875 Then
;Vc
ControlSetText($GastroPlus_handle, "", 108, $Vc)
EndIf

If $k12 <> 54875 Then
;K12
ControlSetText($GastroPlus_handle, "", 107, $K12)
EndIf

If $K21 <> 54875 Then
;K21
ControlSetText($GastroPlus_handle, "", 110, $K21)
EndIf

If $K13 <> 54875 Then
;K13
ControlSetText($GastroPlus_handle, "", 113, $K13)
EndIf

If $K31 <> 54875 Then
;K31
ControlSetText($GastroPlus_handle, "", 112, $K31)
EndIf

If $Renal_clearance <> 54875 Then
;Renal_clearance
ControlSetText($GastroPlus_handle, "", 106, $Renal_clearance)
EndIf

If $FPE_intestinal <> 54875 Then
;FPE_intestinal
ControlSetText($GastroPlus_handle, "", 89, $FPE_intestinal)
EndIf

If $FPE_liver <> 54875 Then
;FPE_liver
ControlSetText($GastroPlus_handle, "", 91, $FPE_liver)
EndIf


;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc

;6) Upload .dsd file
Func six($dsd_filename)
;Activate GastroPlus
WinActivate($GastroPlus_handle)

;File > Load > A Load User-defined ACAT model (.cat)
WinMenuSelectItem($GastroPlus_handle, "", "&File", "&Load", "  &4 Load In Vitro Dissolution/Release vs Time Profile (.dsd)")

;Click OK on possible annoying popup
$_title4 = "GastroPlus - Support File"
$win_exists4 = WinWaitActive($_title4, "", 1.5) ;Waits up to 1.5 seconds for the popup to come up

If $win_exists4 <> 0 Then
	;Find popup handle
	$_text4 = "The highest percent"
	$_class4 = "#32770"
	Local $_handle4 = Window_Handle($_title4, $_class4, $_text4)
	;Click Yes
	ControlClick($_handle4, "", 2, "primary")
	Sleep(500) ;Chill for half a sec
EndIf

;Find window handle
$_title = "Tabulated Data Input"
$_text = "&OK"
$_class = "ThunderRT6FormDC"
Local $_handle = Window_Handle($_title, $_class, $_text)

;File > Open
WinMenuSelectItem($_handle, "", "&File", "&Open")

;Paste given file location
Send($dsd_filename)

;Click Open
Local $popup1 = Window_Handle("Load In Vitro Dissolution Data", "#32770" ,"")
ControlClick($popup1, "", 1, "primary")

;Click OK on possible annoying popup
$win_exists4 = WinWaitActive($_title4, "", 1.5) ;Waits up to 1.5 seconds for the popup to come up

If $win_exists4 <> 0 Then
	;Find popup handle
	Local $_handle4 = Window_Handle($_title4, $_class4, $_text4)
	;Click Yes
	ControlClick($_handle4, "", 2, "primary")
	Sleep(500) ;Chill for half a sec
EndIf


;Click OK
ControlClick($_handle, "", 7)

;Wait for popup
$_title2 = "Save changes?"
$win_exists2 = WinWaitActive($_title2, "", 1.5) ;Waits up 1.5 seconds for the popup to come up

If $win_exists2 <> 0 Then
	;Find popup handle
	$_text2 = "&Yes"
	$_class2 = "#32770"
	Local $_handle2 = Window_Handle($_title2, $_class2, $_text2)
	;Click Yes
	ControlClick($_handle2, "", 6, "primary")
	;Chill for a sec
	Sleep(350)
EndIf

;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc

;7) Enterohepatic circulation parameters
Func seven($EC_params)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

;String of values is sent with hyphens inbetween to keep all the values in one variable while passed
;Separate string into a bunch of values
$EC_params_input = StringSplit($EC_params, "+")

$check = $EC_params_input[1]
$Biliary_Cl = $EC_params_input[2]
$Gall_Empty = $EC_params_input[3]
$Gall_Div = $EC_params_input[4]

If $check = 1 Then ;On

;Simulation Setup > 9 Enterohepatic circulation > On
WinMenuSelectItem($GastroPlus_handle, "", "&Simulation Setup", "&9 Enterohepatic Circulation", "O&n") ;Use Alt to see underlined letters

;Wait until window opens
$EC_title = "Enterohepatic Circulation Parameters"
$EC_text = "Physiological EHC Parameters"
$EC_class = "ThunderRT6FormDC"
WinWaitActive($EC_title, $EC_text, 40)
;Get window handle
Local $EC_handle = Window_Handle($EC_title, $EC_class, $EC_text)

;Input values: If the value isn't 54875 then change it
If $Biliary_Cl <> 54875 Then
ControlSetText($EC_handle, "", 12, $Biliary_Cl)
EndIf

If $Gall_Empty <> 54875 Then
ControlSetText($EC_handle, "", 2, $Gall_Empty)
EndIf

If $Gall_Div <> 54875 Then
ControlSetText($EC_handle, "", 5, $Gall_Div)
EndIf

;Click OK
ControlClick($EC_handle, "", 3, "primary")

ElseIf $check = 0 Then ;Off
	;Simulation Setup > 9 Enterohepatic circulation > Off
WinMenuSelectItem($GastroPlus_handle, "", "&Simulation Setup", "&9 Enterohepatic Circulation", "O&ff")
EndIf

;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc

;8) Upload drug table
Func eight($drug_filename)
;Activate GastroPlus
WinActivate($GastroPlus_handle)

;File > Import > 1 Import Drug Table
WinMenuSelectItem($GastroPlus_handle, "", "&File", "&Import", "&1 Import Drug Table")
Sleep(200)

;Type file name
Send($drug_filename)

;Find window handle
$_title5 = "Name of Text Drugs Data File to Import."
$_text5 = "&Open"
$_class5 = "#32770"
Local $_handle5 = Window_Handle($_title5, $_class5, $_text5)

;Click Open
ControlClick($_handle5, "", 1, "primary")

;Find window handle
$_title3 = "GastroPlus"
$_text3 = ""
$_class3 = "#32770"
Sleep(200) ;wait a sec to make sure the window opened
Local $_handle3 = Window_Handle($_title3, $_class3, $_text3)

;Click OK
ControlClick($_handle3, "", 2, "primary")

;Wait for possible popup
$_title3 = "GastroPlus: Import Table"
$win_exists = WinWaitActive($_title3, "", 1.5) ;Waits up to 1.5 seconds for the popup to come up

If $win_exists <> 0 Then
	;Find popup handle
	$_text3 = "Some of the records"
	$_class3 = "#32770"
	Local $_handle3 = Window_Handle($_title3, $_class3, $_text3)
	;Click Yes
	ControlClick($_handle3, "", 6, "primary")
EndIf

;Wait for another possible popup
$_title7 = "Save changes?"
$win_exists7 = WinWaitActive($_title7, "", 1.5) ;Waits up to 1.5 seconds for the popup to come up

If $win_exists7 <> 0 Then
	;Find popup handle
	$_text7 = "&Yes"
	$_class7 = "#32770"
	Local $_handle7 = Window_Handle($_title7, $_class7, $_text7)
	;Click Yes
	ControlClick($_handle7, "", 7, "primary")
EndIf

;Chill for a sec
Sleep(350)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc


;9) Upload pka table
Func nine($pka_filename)
;Activate GastroPlus
WinActivate($GastroPlus_handle)

;File > Import > 2 Import pKa Table
WinMenuSelectItem($GastroPlus_handle, "", "&File", "&Import", "&2 Import pKa Table")
Sleep(200)

;Type file name
Send($pka_filename)

;Find window handle
$_title5 = "Name of Text AcidBase Data File to Import."
$_text5 = "&Open"
$_class5 = "#32770"
Local $_handle5 = Window_Handle($_title5, $_class5, $_text5)

;Click Open
ControlClick($_handle5, "", 1, "primary")

;Find window handle
$_title3 = "GastroPlus"
$_text3 = "OK"
$_class3 = "#32770"
WinWaitActive($_title3, $_text3, 1)
Local $_handle3 = Window_Handle($_title3, $_class3, $_text3)

;Click OK. Had to make this all weird because the normal way to do this (ControlClick) wasn't working
ControlClick($_handle3, "", 2, "primary")

;Wait for possible popup
$_title3 = "GastroPlus: Import Table"
$win_exists = WinWaitActive($_title3, "", 1.5) ;Waits up to 1.5 seconds for the popup to come up

If $win_exists <> 0 Then
	;Find popup handle
	$_text3 = "Some of the records"
	$_class3 = "#32770"
	Local $_handle3 = Window_Handle($_title3, $_class3, $_text3)
	;Click Yes
	ControlClick($_handle3, "", 6, "primary")
EndIf

;Chill for a sec
Sleep(350)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc

;10) Copy regional absorption
Func ten($excel_file)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

;Copy data
;Graph tab
Local $Ctrl_pos1 = ControlGetPos($GastroPlus_handle, "", "SSTabCtlWndClass1")
ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.8572*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])

;Open regional absorption
ControlClick($GastroPlus_handle, "", 16)
Sleep(100)

;Cp-Time button location
Local $Ctrl_pos3 = ControlGetPos($GastroPlus_handle, "", 17)
;Go to Cp-Time button location, then go 3 Cp-Time buttons to the right
Local $Ctrl_pos2 = ControlGetPos($GastroPlus_handle, "", 173)
MouseMove($Win_pos1[0] + $Ctrl_pos3[0] + 3*$Ctrl_pos3[2], $Win_pos1[1] + $Ctrl_pos2[1], 0)
Sleep(200)
MouseClick($MOUSE_CLICK_RIGHT)
Sleep(200)

;Being sneaky here because it is not clear what the best way to click within the menu is
Send("{DOWN}")
Sleep(300)
Send("{DOWN}")
Sleep(300)
Send("{ENTER}")

;Wait so that program pastes the correct data
Sleep(500)

;Find handle for Excel
$Excel = "data_collection"
$Exceltext = "data_collection"
$Excelclass = "XLMAIN"
Global $Excel_handle = Window_Handle($Excel, $Excelclass, $Exceltext)

;Activate excel window
WinActivate($Excel_handle)
;Waits for Excel to open for 10 secs.
WinWaitActive($Excel_handle, "", 10)

;Click in the spreadsheet area to make sure it is active
$excel_top = WinGetPos($Excel_handle, "") ;Directly clicking the spreadsheet is iffy so I'm doing it harder just to make it more likely to work
MouseClick("primary", $excel_top[0] + $excel_top[2]*.5, $excel_top[1] + $excel_top[3]*.5, 1, 3);Click right in the middle of the window. Hopefully this is the spreadsheet


;Click I2
$oWorkbook = _Excel_BookAttach($excel_file)
$oWorkbook.ActiveSheet.Range("I2").Select
Sleep(200)

;Paste
Send("^v")

;Check if paste worked properly
$oWorkbook.ActiveSheet.Range("I2").Select
$paste_check = $oWorkbook.ActiveSheet.Range("I2").Text

If $paste_check <> "Compartmental Absorption" Then
	;try copy and pasting again

	;Minimize excel
	WinSetState($Excel_handle, "", @SW_MINIMIZE)

	;Copy data
	ControlClick($GastroPlus_handle, "", "[CLASS:SSTabCtlWndClass; INSTANCE:1]", "primary", 1, 0.8572*$Ctrl_pos1[2], .025*$Ctrl_pos1[3])

	;Open regional absorption
	ControlClick($GastroPlus_handle, "", 16)
	Sleep(100)

	;Cp-Time button location
	Local $Ctrl_pos3 = ControlGetPos($GastroPlus_handle, "", 17)
	;Go to Cp-Time button location, then go 3 Cp-Time buttons to the right
	Local $Ctrl_pos2 = ControlGetPos($GastroPlus_handle, "", 173)
	MouseMove($Win_pos1[0] + $Ctrl_pos3[0] + 3*$Ctrl_pos3[2], $Win_pos1[1] + $Ctrl_pos2[1], 0)
	Sleep(300)
	MouseClick($MOUSE_CLICK_RIGHT)
	Sleep(300)

	;Being sneaky here because it is not clear what the best way to click within the menu is
	Send("{DOWN}")
	Sleep(200)
	Send("{DOWN}")
	Sleep(200)
	Send("{ENTER}")

	;Wait so that program pastes the correct data
	Sleep(750)

	;Find handle for Excel
	$Excel = "data_collection"
	$Exceltext = "data_collection"
	$Excelclass = "XLMAIN"
	Global $Excel_handle = Window_Handle($Excel, $Excelclass, $Exceltext)

	;Activate excel window
	WinActivate($Excel_handle)
	;Waits for Excel to open for 5 secs.
	WinWaitActive($Excel_handle, "", 5)

	;Click E2
	$oWorkbook = _Excel_BookAttach($excel_file)
	$oWorkbook.ActiveSheet.Range("I2").Select
	Sleep(100)

	;Paste
	Send("^v")

EndIf


;Click I3
$oWorkbook.ActiveSheet.Range("I3").Select

;Shift+Ctrl+-->, Shift+Ctrl+[down arrow]
Send("^+{RIGHT}")
Sleep(200)
Send("^+{DOWN}")
Sleep(300)

;Copy regional absorption data
Send("^c")
Sleep(300)

;Get data from clipboard
Local $profile = _ClipBoard_GetData($CF_TEXT)
Sleep(300)

;Clear regional absoprtion data. Weirdly I have to paste before doing this
;Send("{DEL}")

;Send regional absorption profile
ConsoleWrite("ra start" & $profile & "ra end")

;minimize excel
WinSetState($Excel_handle, "", @SW_MINIMIZE)

;Activate GastroPlus
WinActivate($GastroPlus_handle)

EndFunc


;empty clipboard (in case it can't handle thousands of simulations of data)
_ClipBoard_Empty()
;minimize GastroPlus
WinSetState($GastroPlus_handle, "", @SW_MINIMIZE)
WinSetState($Excel_handle, "", @SW_MINIMIZE)