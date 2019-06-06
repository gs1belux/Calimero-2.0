**************************************
* Calimero 2.0: HO2C validation tool *
**************************************

1) Prerequirement
-----------------
In order to use this tool, you need to have:
- Java (JRE) installed on your computer. If it is not, get it on http://www.java.com
- 'curl.exe' to get updates of the tool. Windows 10 version 1803 or later has curl installed by default and ready to use. If it is not available, get it on http://www.confusedbycode.com/curl/#downloads

2) Two programs
---------------
EDI2XML-V3: transform all the .edi or .txt files of a repository into an ISO/TS 20625:2002 xml file.
Validation-V3: get XML files and validate according to XSD and Schematron files.

3) Howto use
------------
Multiple Run GitHub:
- Unzip the file locally (ex: c:/Calimero20). After unzipping, rename the file curl._xe to curl.exe (was renamed to avoid mail problems and this tool is needed to update installation - if using windows 10 version 1803 or later, this might be skipped).
- Copy all the .edi and .txt you want to validate in the subfolder 'files'. ONLY VERSION 3 HO2C CAN BE VALIDATED. Version 2 and earlier will be reported as error (warning).
- Dubble click on RunMultipleGitHub.bat (most recent jar-, xsd-, sch- and codelistfiles will be updated first from GS1 Belgium & Luxembourg GitHub by using curl).
- We provided an example.edi file you may copy to the 'files' subfolder to test your setup. Don't forget to cleanup the subfolder since all .edi and .txt files present will be validated again on your next execution.
- For every .edi and .txt file, 2 files are created (or overwritten). An .err file holding the same messages as reported on the screen and an .xml file holding the transformed .edi/.txt file to xml.
- Leave all jar-, xsd-, sch- and codelistfiles untouched. Report errors and/or malfunction to edi@gs1belu.org
