#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <_HttpRequest.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiButton.au3>
#include <EditConstants.au3>
#include <File.au3>

Global $_COOOKIE, $__VIEWSTATE, $MAX_TIMES = 50, $_LISTSUB
Global $_SLEEP = 50, $_VER = "0.1"

Global $LoginGUI = GUICreate("Tool Auto Register", 562, 305, -1, -1, -1, -1)
GUISetIcon(@ScriptDir & "\icon.ico")
GUISetBkColor(0x595959, $LoginGUI)
Global $acclb = GUICtrlCreateLabel("Account:", 20, 15, 52, 20, $SS_CENTERIMAGE, -1)
GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "-2")
Global $acc = GUICtrlCreateInput("", 75, 15, 150, 20, -1, $WS_EX_CLIENTEDGE)
GUICtrlSetBkColor(-1, "0x595959")
GUICtrlSetColor(-1, "0xFFFFFF")
Global $passlb = GUICtrlCreateLabel("Password:", 238, 15, 55, 20, $SS_CENTERIMAGE, -1)
GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "-2")
Global $pass = GUICtrlCreateInput("", 295, 15, 150, 20, $ES_PASSWORD, $WS_EX_CLIENTEDGE)
GUICtrlSetBkColor(-1, "0x595959")
GUICtrlSetColor(-1, "0xFFFFFF")
Global $login = GUICtrlCreateLabel("LOGIN", 460, 15, 77, 20, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
GUICtrlSetColor(-1, "0x595959")
GUICtrlSetFont(-1, 10, 600, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, "0xFFFFFF")
GUICtrlSetCursor(-1, 0)
Global $command = GUICtrlCreateInput("", 20, 267, 430, 24, -1, $WS_EX_CLIENTEDGE)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "0x595959")
Global $cmdbtn = GUICtrlCreateLabel("GỬI CMD", 460, 267, 80, 24, BitOR($SS_CENTER, $SS_CENTERIMAGE), -1)
GUICtrlSetColor(-1, "0x595959")
GUICtrlSetBkColor(-1, "0xFFFFFF")
GUICtrlSetFont(-1, 10, 600, 0, "MS Sans Serif")
GUICtrlSetCursor(-1, 0)

Global $edittxt = GUICtrlCreateEdit("", 20, 55, 521, 202, BitOR($ES_AUTOVSCROLL, $ES_READONLY, $WS_VSCROLL), -1)

GUICtrlSetColor(-1, "0xFFFFFF")
GUICtrlSetBkColor(-1, "0x595959")

GUISetState(@SW_SHOW, $LoginGUI)

_DisableInput()
_DisableInput(3)

If Not _Captcha() Then
	GUICtrlSetData($login, "CAPTCHA")
EndIf


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $login
			GUICtrlSetState($login, $GUI_DISABLE)

			If GUICtrlRead($login) = "LOGIN" Then

				_Login()
			ElseIf GUICtrlRead($login) = "CAPTCHA" Then
				If Not _Captcha() Then
					GUICtrlSetData($login, "CAPTCHA")
				EndIf
			Else
				_Logout()
			EndIf
			GUICtrlSetState($login, $GUI_ENABLE)
		Case $GUI_EVENT_CLOSE
			Exit
		Case $cmdbtn
			
			If (GUICtrlRead($command) == 'check') Then
			 _Check()
			
			Else 
				$cmd = StringSplit(GUICtrlRead($command), '@')
			
			
			If ($cmd[0] > 1) Then
				If ($cmd[1] == "list") Then
					_Text("[LIST] Đang lấy list vui lòng đợi")
					If _Find($cmd[2]) == True Then
						_Text("[LIST] Lấy list thành công")
					Else
						_Text("[LIST] Lấy list thất bại")
					EndIf

				ElseIf ($cmd[1] == "reg") Then
					If ($cmd[0] >= 2) Then
						$stringSplit = StringSplit($cmd[2], '|')
						If ($stringSplit[0] > 2) Then
							_Reg($stringSplit[1], $stringSplit[2], $stringSplit[3])
						Else
							_Reg($stringSplit[1], $stringSplit[2])
						EndIf
					Else
						_Text("[CMD] Lệnh không đầy đủ (cấu trúc lệnh reg@<NMH>|<NMH>|<TTH>)")
					EndIf
				
				EndIf
			Else
				_Text("[CMD] Lệnh không chính xác")
			EndIf
			EndIf
			

	EndSwitch
WEnd


Func _Find($find_what, $type = 0)
	$post = '{"dkLoc":"' & $find_what & '"}'
	$http = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", $post, $_COOOKIE, 'https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method:LocTheoMonHoc')
	
	$http = _HttpRequest_ParseJSON($http)

	If $http.get('error.Message') == 'Object reference not set to an instance of an object.' Then Return False

	$data = StringReplace($http.get('value'), '\r\n', '')
	$data = StringReplace($data, '\"', '"')

	$_LISTSUB = StringRegExp($data, 'value="(.*?)"', 3)

	If UBound($_LISTSUB) == 0 Then Return False
	If $type == 0 Then _HttpRequest_Test($data)
	Return True
EndFunc   ;==>_Find


Func _Check()
	$http = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc", '', $_COOOKIE)
	If @error Then
		_Text("[CHECK] Không lấy được nội dung trang dkmh.hcmuaf.edu.vn")
		Return False
	EndIf
	
	If (StringInStr($http, "ctl00_ContentPlaceHolder1_ctl00_lblCapcha") > 0 Or StringInStr($http, 'ctl00_ContentPlaceHolder1_ctl00_lblquenmk') > 0) Then
		_Text("[CHECK] Phiên đăng nhập hết hạn, đang lấy lại captcha và đăng nhập lại")
		If (_Captcha()) Then
			If (_Login()) Then
				_Reg($m, $id, $th)
			Else
				_Text("[CHECK] Đăng nhập thất bại, hãy tắt chương trình và mở lại")
			EndIf
		EndIf
		Return
	EndIf
	
		
	Local $mmh = StringRegExp($http,  "<td style='width: 42px;' valign='middle' align='center'>(.*?)</td>",  3)
	Local $resuft[UBound($mmh)][2]
	
	Local $name = StringRegExp($http,  "<td style='width: 180px;' valign='middle' align='left'>&nbsp;(.*?)</td>",  3)
	Local $tth = StringRegExp($http,  "<td style='width: 45px;' valign='middle' align='center'>(.*?)</td>",  3)
	
	For $i = 0 To UBound($mmh) -1
		$resuft[$i][0] = $mmh[$i]
		$resuft[$i][1] = $name[$i]
		;$resuft[$i][2] = $tth[$i]
	Next
	_Text("[CHECK] Lấy thành công")
	_ArrayDisplay($resuft)
	
EndFunc   ;==>_Check


Func _Reg($m, $id, $th = '  ')
	Sleep($_SLEEP)

	_Text("[REG] Đang tiến hành đăng ký môn " & $m & '-' & $id & '-' & $th)

	$http = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc", '', $_COOOKIE)

	If @error Then
		_Text("[REG] Không lấy được nội dung trang dkmh.hcmuaf.edu.vn")
		Return False
	EndIf

	If (StringInStr($http, "ctl00_ContentPlaceHolder1_ctl00_lblCapcha") > 0 Or StringInStr($http, 'ctl00_ContentPlaceHolder1_ctl00_lblquenmk') > 0) Then
		_Text("[REG] Phiên đăng nhập hết hạn, đang lấy lại captcha và đăng nhập lại")
		If (_Captcha()) Then
			If (_Login()) Then
				_Reg($m, $id, $th)
			Else
				_Text("[REG] Đăng nhập thất bại, hãy tắt chương trình và mở lại")
			EndIf
		EndIf
		Return
	EndIf

	Local $stringRq = ''
	Local $stringCompare = $m & $id & '  ' & $th
	_Find($m, 1)

	For $element In $_LISTSUB
		If StringInStr($element, $stringCompare) > 0 Then
			$stringRq = $element
			ExitLoop
		EndIf
	Next
	If ($stringRq == '') Then
		_Text("[REG] Không tìm thấy môn này")
		Return
	EndIf
	_Text("[REG] Đã tìm thấy môn này")
	_Text("[REG] Đang tiến hành gửi lệnh đăng kí")
	Local $split_db = StringSplit($stringRq, '|')
	Local $DangKySelectedChange = '{"check":true,"maDK":"' & $split_db[1] & '","maMH":"' & $split_db[2] & '","tenMH":"' & $split_db[3] & '","maNh":"' & $split_db[4] & '","sotc":"' & $split_db[5] & '","strSoTCHP":"' & $split_db[6] & '","ngaythistr":"' & $split_db[7] & '","tietbd":"' & $split_db[8] & '","sotiet":"' & $split_db[9] & '","soTCTichLuyToiThieuMonYeuCau":"' & $split_db[10] & '","choTrung":"' & $split_db[11] & '","soTCMinMonYeuCau":"' & $split_db[12] & '","maKhoiSinhVien":"' & $split_db[13] & '"}'
	$http = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", $DangKySelectedChange, $_COOOKIE, 'https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc', 'Accept: */*|Accept-Encoding: gzip, deflate|Host:dkmh.hcmuaf.edu.vn|X-AjaxPro-Method: DangKySelectedChange')
	Local $return = StringSplit($http, '|')

	If $return[0] <= 30 Then
		_Text("[REG] Tách dữ liệu đăng ký thất bại")
		Return
	EndIf

	If Number($return[10]) == 0 Then

		If $return[7] == "" And $return[8] == "" And $return[11] == "" Then

			Local $LuuVaoKetQuaDangKy = '{"isValidCoso":false,"isValidTKB":false,"maDK":"' & $split_db[1] & '","maMH":"' & $split_db[2] & '","sotc":"' & $split_db[5] & '","tenMH":"' & $split_db[3] & '","maNh":"' & $split_db[4] & '","strsoTCHP":"' & $split_db[6] & '","isCheck":"true","oldMaDK":"' & $return[5] & '","strngayThi":"' & $split_db[7] & '","tietBD":"' & $split_db[8] & '","soTiet":"' & $split_db[9] & '","isMHDangKyCungKhoiSV":"' & $return[36] & '"}'
			$a = _HttpRequest(1, "https://dkmh.hcmuaf.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", $LuuVaoKetQuaDangKy, $_COOOKIE, 'https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method: LuuVaoKetQuaDangKy')
			$b = _HttpRequest(1, "https://dkmh.hcmuaf.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", '{}', $_COOOKIE, 'https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method: KiemTraTrungNhom')
			$c = _HttpRequest(1, "https://dkmh.hcmuaf.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", '{}', $_COOOKIE, 'https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method:LuuDanhSachDangKy')
			$d = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/ajaxpro/EduSoft.Web.UC.DangKyMonHoc,EduSoft.Web.ashx", '{"isCheckSongHanh":false,"ChiaHP":false}', $_COOOKIE, 'https://dkmh.hcmuaf.edu.vn/Default.aspx?page=dkmonhoc', 'X-AjaxPro-Method: LuuDanhSachDangKy_HopLe')

			If StringInStr($d, 'error') == 0 Then
				_Text("[REG] Đăng ký hoàn tất, kết quả ")
				TrayTip("Đăng ký môn học", "Đã đăng ký hoàn tất", 5)
			Else
				_Text("[REG] Lỗi, không đăng kí được")
			EndIf
		Else
			If ($return[7] <> "") Then _Text("[REG] Lỗi " & $return[7])
			If ($return[8] <> "") Then _Text("[REG] Lỗi " & $return[8])
			If ($return[11] <> "") Then _Text("[REG] Lỗi môn này ko thể tự đăng ký do phần tử 11 = " & $return[11])
		EndIf
	Else
		_Text("[REG] Bạn bị trùng lịch môn học này")
	EndIf


EndFunc   ;==>_Reg

Func _Login($times = 0)

	Sleep($_SLEEP)
	GUICtrlSetBkColor($acclb, "-2")
	GUICtrlSetBkColor($passlb, "-2")
	_DisableInput()
	_Text("[LOGIN] Tiến hành đăng nhập")

	Local $aForm = [['__EVENTTARGET', ''], ['__EVENTARGUMENT', ''], ['ctl00$ContentPlaceHolder1$ctl00$txtTaiKhoa', GUICtrlRead($acc)], ['ctl00$ContentPlaceHolder1$ctl00$txtMatKhau', GUICtrlRead($pass)], ['ctl00$ContentPlaceHolder1$ctl00$btnDangNhap', 'Đăng Nhập']]
	Local $sDataToSend = _HttpRequest_DataFormCreate($aForm)

	$http = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/default.aspx?page=dangnhap", $sDataToSend, $_COOOKIE)

	If @error Then
		_Text("[LOGIN] Không lấy được nội dung trang dkmh.hcmuaf.edu.vn")
		Return False
	EndIf

	$__VIEWSTATE = StringRegExp($http, 'name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)"', 3)[0]

	If (StringInStr($http, "ctl00_ContentPlaceHolder1_ctl00_lblError") > 0) Then

		If (StringInStr($http, "Chào em") > 0) Then
			If ($times >= $MAX_TIMES) Then
				_Text("[LOGIN] Hệ thống quá tải, hãy thử lại sau")
				TrayTip("Đăng nhập", "Hệ thống quá tải, hãy thử lại sau", 5)
				_DisableInput(1)
			Else
				_Text("[LOGIN] Hệ thống quá tải, đang thử lại lần " & $times + 1 & "/" & $MAX_TIMES)
				_Login($times + 1)
			EndIf
		ElseIf (StringInStr($http, "Không được phép đăng nhập") > 0) Then
			TrayTip("Đăng nhập", "Không được phép đăng nhập", 5)
			_Text("[LOGIN] Không được phép đăng nhập")

		ElseIf (StringInStr($http, "Sai thông tin đăng nhập") > 0) Then
			TrayTip("Đăng nhập", "Sai thông tin đăng nhập", 5)
			_Text("[LOGIN] Sai thông tin đăng nhập")
			GUICtrlSetBkColor($acclb, "0xf4564d")
			GUICtrlSetBkColor($passlb, "0xf4564d")
			_DisableInput(1)
		Else
			TrayTip("Đăng nhập", "Lỗi không xác định", 5)
			_Text("[LOGIN] Lỗi không xác định")
			_DisableInput(1)
		EndIf

	ElseIf (StringInStr($http, "ctl00_Header1_Logout1_lbtnChangePass") > 0) Then
		$tach = StringRegExp($http, 'style="color:#FF3300;font-size:12px;font-weight:bold;">Chào (.*?)<', 3)
		
		If (UBound($tach) <= 0) Then Return _Login()
		$name = $tach[0]
		GUICtrlSetData($edittxt, '')
		_Text("[LOGIN] ĐĂNG NHẬP THÀNH CÔNG")
		_Text("[LOGIN] Xin chào " & $name)
		_Text("-------------------------------------------------------")
		_Text("- Lệnh ' check ' để kiểm tra môn đã đăng kí thành công")
		_Text("- Lệnh ' list@<Mã MH> ' lấy ra list mã môn học")
		_Text("- Lệnh ' reg@<MMH>|<NMH>|<TTH> ' đăng ký môn học theo yêu cầu")
		_Text("-------------------------------------------------------")
		WinSetTitle($LoginGUI, '', 'Xin chào ' & $name)
		TrayTip("Đăng nhập", "Xin chào " & $name, 5)
		_DisableInput(2)
		Return True
	ElseIf (StringInStr($http, "ctl00_ContentPlaceHolder1_ctl00_lblCapcha") > 0 Or StringInStr($http, 'XÁC THỰC ĐĂNG NHẬP WEBSITE ĐĂNG KÝ MÔN HỌC') > 0) Then
		_Text("[LOGIN] Phiên đăng nhập hết hạn, đang lấy lại captcha và đăng nhập lại")
		If (_Captcha()) Then Return _Login()
	ElseIf ($http = "The service is unavailable.") Then
		_Text("[LOGIN] Trang dkmh.hcmuaf.edu.vn hiện không còn hoạt động")
	Else
		If ($times < $MAX_TIMES) Then
			_Text("[LOGIN] Đang đăng nhập lần " & $times + 1 & " / " & $MAX_TIMES)
			_Login($times + 1)
		Else
			_Text("[LOGIN] Đã dừng")
			_Text("[LOGIN] Bạn đăng nhập lại đi nha")
			_DisableInput(1)
		EndIf
	EndIf

	Return False
EndFunc   ;==>_Login


Func _Captcha($times = 0)
	If $_SLEEP > 0 Then Sleep($_SLEEP)
	_Text("[CAPTCHA] Đang lấy captcha và cookie")
	$http = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/")

	If @error Then
		_Text("[CAPTCHA] Không lấy được nội dung trang dkmh.hcmuaf.edu.vn")
		Return False
	EndIf
	$_COOOKIE = _GetCookie($http)
	If StringInStr($http, 'ctl00_ContentPlaceHolder1_ctl00_lblCapcha') == 0 Then

		_Text("[CAPTCHA] Không có captcha để vượt")
		_Text("[LOGIN] Bạn hãy đăng nhập")
		_DisableInput(1)
		Return True
	EndIf
	If ($http = "The service is unavailable.") Then
		_Text("[CAPTCHA] Trang dkmh.hcmuaf.edu.vn hiện không còn hoạt động")
		Return False
	ElseIf ($http = "") Then
		_Text("[CAPTCHA] Không nhận được phản hồi từ dkmh.hcmuaf.edu.vn")
		Return False
	EndIf
	$captcha = StringRegExp($http, 'font-style:italic;">(.*?)</span>', 3)
	If UBound($captcha) > 0 Then

		$__VIEWSTATE = StringRegExp(StringReplace($http, @CRLF, ""), 'name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)"', 3)[0]
		_Text("[CAPTCHA] Đã tách được captcha " & $captcha[0])
		_Text("[CAPTCHA] Đang vượt captcha")

		Local $aForm = [['__EVENTTARGET', ''], ['__EVENTARGUMENT', ''], ['__VIEWSTATE', $__VIEWSTATE], ['ctl00$ContentPlaceHolder1$ctl00$txtCaptcha', $captcha[0]], ['ctl00$ContentPlaceHolder1$ctl00$btnXacNhan', 'Vào website']]
		$sDataToSend = _HttpRequest_DataFormCreate($aForm)

		$http = _HttpRequest(2, "https://dkmh.hcmuaf.edu.vn/default.aspx", $sDataToSend, $_COOOKIE)
		If (StringInStr($http, "ctl00_ContentPlaceHolder1_ctl00_lblTenDangNhap") > 0) Then
			$__VIEWSTATE = StringRegExp(StringReplace($http, @CRLF, ""), 'name="__VIEWSTATE" id="__VIEWSTATE" value="(.*?)"', 3)[0]

			GUICtrlSetData($edittxt, '')
			_Text("[CAPTCHA] Vượt captcha thành công")
			_Text("[CAPTCHA] MỜI BẠN TIẾN HÀNH ĐĂNG NHẬP")
			_DisableInput(1)
			Return True
		Else
			_Text("[CAPTCHA] Vượt captcha thất bại")
		EndIf
	Else
		If ($times >= 5) Then
			_Text("[CAPTCHA] Tách captcha thất bại, ngưng tiến trình")
		Else
			_Text("[CAPTCHA] Tách captcha thất bại, đang thực hiện lại lần " & $times + 1 & "/5")
			Return _Captcha($times + 1)
		EndIf
	EndIf
	Return False
EndFunc   ;==>_Captcha


Func _Text($txt)
	GUICtrlSetData($edittxt, "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $txt & @CRLF, 1)
EndFunc   ;==>_Text

Func _Logout()
	Sleep($_SLEEP)
	_Text("[LOGOUT] Đang logout và lấy lại captcha")

	Local $aForm = [['__EVENTTARGET', 'ctl00$Header1$Logout1$lbtnLogOut'], ['__EVENTARGUMENT', '']]
	Local $sDataToSend = _HttpRequest_DataFormCreate($aForm)

	$http = _HttpRequest(1, "https://dkmh.hcmuaf.edu.vn/default.aspx?page=dangnhap", $sDataToSend, $_COOOKIE)

	If @error Then
		_Text("[LOGOUT] Không lấy được nội dung trang dkmh.hcmuaf.edu.vn")
		Return False
	EndIf
	If _Captcha() Then
		_Text("[LOGOUT] Đã logout thành công, mời login lại")
		GUICtrlSetData($acc, '')
		GUICtrlSetData($pass, '')
		WinSetTitle($LoginGUI, "", "Tool Auto Register")
	Else
		_Text("[LOGOUT] Logout thất bại, hãy tắt và mở lại chương trình")
	EndIf
EndFunc   ;==>_Logout


Func _DisableInput($id = 0)
	If ($id = 0) Then
		GUICtrlSetState($acc, $GUI_DISABLE)
		GUICtrlSetState($pass, $GUI_DISABLE)
		GUICtrlSetData($login, 'LOGOUT')
	ElseIf ($id = 1) Then
		GUICtrlSetState($acc, $GUI_ENABLE)
		GUICtrlSetState($pass, $GUI_ENABLE)
		GUICtrlSetData($login, 'LOGIN')
	EndIf
	If ($id = 2) Then
		GUICtrlSetState($command, $GUI_ENABLE)
		GUICtrlSetState($cmdbtn, $GUI_ENABLE)
	ElseIf ($id = 3) Then
		GUICtrlSetState($command, $GUI_DISABLE)
		GUICtrlSetState($cmdbtn, $GUI_DISABLE)
	EndIf
EndFunc   ;==>_DisableInput
