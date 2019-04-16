@echo off

Echo **********************************
Echo Start validation of folder "files"
FOR %%G in ("files/*.edi") DO (
	Echo "%%~nxG" : Transformation in progress ...
	java -jar EDI2XML.jar "files/%%~nxG" | tee "files/%%~nG.err"
	if exist "files/%%~nG.xml" (
		Echo "%%~nxG" : Validation in progress ...
		java -jar Validation.jar "HO2C - V2 - INVOIC - XML.xsd" "HO2C - V2 - INVOIC - XML.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
		java -jar Validation.jar "HO2C - V2 - INVOIC - XML.xsd" "HO2C - V2 - INVOIC - Calculation.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
	)
)

FOR %%G in ("files/*.txt") DO (
	Echo "%%~nxG" : Transformation in progress ...
	java -jar EDI2XML.jar "files/%%~nxG" | tee "files/%%~nG.err"
	if exist "files/%%~nG.xml" (
		Echo "%%~nxG" : Validation in progress ...
		java -jar Validation.jar "HO2C - V2 - INVOIC - XML.xsd" "HO2C - V2 - INVOIC - XML.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
		java -jar Validation.jar "HO2C - V2 - INVOIC - XML.xsd" "HO2C - V2 - INVOIC - Calculation.sch" "files/%%~nG.xml" | tee -a "files/%%~nG.err"
	)
)

Echo Done !
Echo End validation
Echo **********************************
pause

