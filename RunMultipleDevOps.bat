@echo off

Echo **********************************
Echo Get updates from GS1Belux ...
curl -s -o EDI2XML-V3.jar "https://dev.azure.com/gs1belgilux/Calimero/_apis/git/repositories/Calimero/items?path=/EDI2XML-V3.jar&download=true&api-version=5.0"
curl -s -o Validation-V3.jar "https://dev.azure.com/gs1belgilux/Calimero/_apis/git/repositories/Calimero/items?path=/Validation-V3.jar&download=true&api-version=5.0"
curl -s -o HO2C-V3-INVOIC-XML.xsd "https://dev.azure.com/gs1belgilux/Calimero/_apis/git/repositories/Calimero/items?path=/HO2C-V3-INVOIC-XML.xsd&download=true&api-version=5.0"
curl -s -o HO2C-V3-INVOIC-XML.sch "https://dev.azure.com/gs1belgilux/Calimero/_apis/git/repositories/Calimero/items?path=/HO2C-V3-INVOIC-XML.sch&download=true&api-version=5.0"
curl -s -o HO2C-V3-INVOIC-Calculation.sch "https://dev.azure.com/gs1belgilux/Calimero/_apis/git/repositories/Calimero/items?path=/HO2C-V3-INVOIC-Calculation.sch&download=true&api-version=5.0"
curl -s -o sub\HO2C-V3-INVOIC-XML-CodeList.xml "https://dev.azure.com/gs1belgilux/Calimero/_apis/git/repositories/Calimero/items?path=/HO2C-V3-INVOIC-XML-CodeList.xml&download=true&api-version=5.0"
curl -s -o tee.exe "https://dev.azure.com/gs1belgilux/Calimero/_apis/git/repositories/Calimero/items?path=/tee.exe&download=true&api-version=5.0"

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