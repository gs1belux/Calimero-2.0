@echo off

Echo **********************************
Echo Get updates from github ...
curl -Os "https://raw.githubusercontent.com/gs1belux/calimero-2.0/master/EDI2XML-V3.jar"
curl -Os "https://raw.githubusercontent.com/gs1belux/calimero-2.0/master/Validation-V3.jar"
curl -Os "https://raw.githubusercontent.com/gs1belux/calimero-2.0/master/HO2C-V3-INVOIC-XML.xsd"
curl -Os "https://raw.githubusercontent.com/gs1belux/calimero-2.0/master/HO2C-V3-INVOIC-XML.sch"
curl -Os "https://raw.githubusercontent.com/gs1belux/calimero-2.0/master/HO2C-V3-INVOIC-Calculation.sch"
curl -Os "https://raw.githubusercontent.com/gs1belux/calimero-2.0/master/tee.exe"

Echo Start validation of folder "files" ...
FOR %%G in ("files/*.edi") DO (
	Echo "%%~nxG" : Transformation in progress ...
	java -jar EDI2XML-V3.jar "files/%%~nxG" | tee "files/%%~nG.err"
	if exist "files/%%~nG.xml" (
		Echo "%%~nxG" : Validation in progress ...
		java -jar Validation-V3.jar "HO2C-V3-INVOIC-XML.xsd" "HO2C-V3-INVOIC-XML.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
		java -jar Validation-V3.jar "HO2C-V3-INVOIC-XML.xsd" "HO2C-V3-INVOIC-Calculation.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
	)
)

FOR %%G in ("files/*.txt") DO (
	Echo "%%~nxG" : Transformation in progress ...
	java -jar EDI2XML-V3.jar "files/%%~nxG" | tee "files/%%~nG.err"
	if exist "files/%%~nG.xml" (
		Echo "%%~nxG" : Validation in progress ...
		java -jar Validation-V3.jar "HO2C-V3-INVOIC-XML.xsd" "HO2C-V3-INVOIC-XML.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
		java -jar Validation-V3.jar "HO2C-V3-INVOIC-XML.xsd" "HO2C-V3-INVOIC-Calculation.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
	)
)

Echo Done !
Echo End validation
Echo **********************************
pause

