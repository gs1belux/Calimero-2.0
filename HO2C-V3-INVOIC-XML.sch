<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" schemaVersion="iso" queryBinding="xslt2"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<ns uri="functions:1.0" prefix="f"/>
	<ns uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
	<ns uri="utils" prefix="u"/>
	
	<!--	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<report test="1 = 1">
				Killroy was here!   
			</report>
		</rule>
	</pattern>-->

	<!-- Reference documents and variables -->
	<let name="codelist" value="doc(&apos;sub/HO2C-V3-INVOIC-XML-CodeList.xml&apos;)"/>
	<let name="allSegment" value="//*[starts-with(name(), 'S_') or starts-with(name(), 'G_')]"/>

	<let name="emptyGLN" value="'0000000000000'"/>
	<let name="orderType" value="xs:string(/INTERCHANGE/M_INVOIC/S_BGM/C_C002/D_1001)"/>
	<let name="bebatCode" value="014"/>
	<!--<let name="isBackhauling" value="exists(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'SF'])"/> -->
	<let name="isHomeDeliveryCase1"
    value="
      exists(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'UC']/C_C082[D_3039 = $emptyGLN]) and
      exists(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'UC']/C_C059/D_3042) and
      exists(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'DP']/C_C082[D_3039 = $emptyGLN])"/>
	<let name="isHomeDeliveryCase3"
    value="
      exists(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'UC']/C_C082[D_3039 = $emptyGLN]) and
      exists(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'DP']/C_C082[D_3039 != $emptyGLN])"/>
	<!--<let name="isHierarchicalDescription" value="/INTERCHANGE/M_INVOIC/G_SG10/S_CPS[D_7164 = 1]/D_7075 = '4'"/>-->

	<!-- Functions -->
	<function xmlns="http://www.w3.org/1999/XSL/Transform" name="u:gln" as="xs:boolean">
		<param name="val"/>
		<variable name="length" select="string-length($val) - 1"/>
		<variable name="digits" select="reverse(for $i in string-to-codepoints(substring($val, 0, $length + 1)) return $i - 48)"/>
		<variable name="weightedSum" select="sum(for $i in (0 to $length - 1) return $digits[$i + 1] * (1 + ((($i + 1) mod 2) * 2)))"/>
		<value-of select="10 - ($weightedSum mod 10) = number(substring($val, $length + 1, 1))"/>
	</function>
	<function xmlns="http://www.w3.org/1999/XSL/Transform" name="u:mod97" as="xs:boolean">
		<param name="val"/>
		<variable name="digits" select="number(substring($val, 1, string-length($val) - 2))"/>
		<variable name="chkdgt" select="97 - ($digits mod 97)"/>
		<value-of select="number($chkdgt) = number(substring($val, string-length($val) - 1))"/>
	</function>

	<title>Schema for HO2C-V3-INVOIC-XML; 2002; EAN</title>

	<!-- UNB -->
	<pattern>
		<rule context="/INTERCHANGE/S_UNB/C_S002/D_0004">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<assert test="number(.)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S002/0004] The value <value-of select="."/> is a GLN must be a
        number composed by 13 digits. </assert>
		</rule>
	</pattern>
	<!-- Validation of GLN -->
	<pattern>
		<rule context="/INTERCHANGE/S_UNB/C_S002/D_0004">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<assert	test="matches(normalize-space(), '^[0-9]+$') and u:gln(normalize-space())">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S002/0004] The value <value-of select="."/> has an invalid GLN checkdigit provided.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/S_UNB/C_S003/D_0010">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<assert test="number(.)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S003/0010] The value <value-of select="."/> is a GLN must be a
        number composed by 13 digits. </assert>
		</rule>
	</pattern>
	<!-- Validation of GLN -->
	<pattern>
		<rule context="/INTERCHANGE/S_UNB/C_S003/D_0010">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<assert	test="matches(normalize-space(), '^[0-9]+$') and u:gln(normalize-space())">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S002/0010] The value <value-of select="."/> has an invalid GLN checkdigit provided.</assert>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/S_UNB/C_S004/D_0017">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="validDate"
        value="concat('20', substring(., 1, 2), '-', substring(., 3, 2), '-', substring(., 5, 2))"/>
			<!-- Validate date -->
			<assert test="string-length(normalize-space(.)) &lt;= 6"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S004/0017] Length of value of
        'D_0017' must be equal to 6 (YYMMDD). </assert>
			<assert test="matches(., '^\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$')"> [UNB/S004/0017]
          ('<value-of select="."/>') isn't a valid date ('YYYYMMDD') </assert>
			<assert test="xs:date($validDate) &lt;= current-date()"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S004/0017] The value of element
        is not a correct: '<value-of select="xs:date($validDate)"/>' is in the future.</assert>
		</rule>
	</pattern>
	<pattern>

		<rule context="/INTERCHANGE/S_UNB/C_S004/D_0019">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- Validate hour -->
			<assert test="string-length(normalize-space(.)) = 4"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S004/0019]: Length of value of
        'D_0019' must be equal to 4 (HHMM). </assert>
			<assert test="matches(., '^([0-9]|0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$')"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNB/S004/0019]:
          ('<value-of select="."/>') isn't a valid hour ('HHMM') </assert>
		</rule>
	</pattern>

	<!-- BGM -->
	<let name="isCreditNote" value="exists(/INTERCHANGE/M_INVOIC/S_BGM[C_C002/D_1001 = '381'])"/>
	
	<!-- DTM -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/S_DTM/C_C507/D_2005">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'DTM_2005']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The value '<value-of select="$codeValue"/>' for DTM qualifier('2005') is
        not correct. The value should be 1, 35, 137, 263 or 454. </assert>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="if (exists(./S_DTM))
          then
            (./S_DTM[last()])
          else
            (./S_BGM[last()])"/>
			<report test="count(./S_DTM/C_C507[D_2005 = '137']) != 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The DTM+137 must
        occur exactly 1 time.</report>
			<report test="count(./S_DTM/C_C507[D_2005 = '454']) != 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The DTM+454 must
        occur exactly 1 time.</report>
			<report test="count(./S_DTM/C_C507[D_2005 = '1']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The DTM+1 can occur
        maximum 1 time.</report>
			<report test="count(./S_DTM/C_C507[D_2005 = '35']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The DTM+35 can occur
        maximum 1 time.</report>
			<report test="count(./S_DTM/C_C507[D_2005 = '263']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The DTM+263 can
        occur maximum 1 time.</report>
			<report
        test="count(./S_DTM/C_C507[D_2005 = '35']) != 1 and count(./S_DTM/C_C507[D_2005 = '1']) != 1"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The DTM+35 (Actual delivery date/time) or the DTM+1 (Actual service
        completion date/time) is required.</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/S_DTM">
			<let name="qual" value="./C_C507/D_2005"/>
			<let name="format" value="./C_C507/D_2379"/>
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="$qual = '263' and $format != '718'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The format code '<value-of
          select="$format"/>' for DTM qualifier('<value-of select="$qual"/>') is not correct. The
        DTM+263 (Invoicing period) should be used with format code '718'. </report>
			<report test="$format = '718' and $qual != '263'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: The format code '<value-of
          select="$format"/>' for DTM qualifier('<value-of select="$qual"/>') is not correct. The
        format code '718' can be used only with DTM+263 (Invoicing period). </report>
			<report test="$format = '203'" role="information"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[DTM/C507/2005]: It's recommended to use
        date format '102', instead of '203'. </report>
		</rule>
	</pattern>

	<!-- ALI -->
	<let name="isAdjustment" value="exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E'])"/>
	
	<!-- FTX -->
	<let name="isFreeTextPresent" value="exists(/INTERCHANGE/M_INVOIC/S_FTX[D_4451 = 'TXD'])"/>
		
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/S_FTX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="qual" value="./D_4451"/>
			<report test="$qual != 'TXD' and count(./C_C108/D_4440) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[FTX/C108/4440]: The element
        4440 (Free text value) can appear only once when you use it with FTX+<value-of
          select="$qual"/>.</report>
			<report test="$qual != 'TXD' and count(./D_3453) > 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[FTX/3453]: The element 3453 (Language
        name code) under the segment FTX+<value-of select="$qual"/> is not correct. This element can
        appears with FTX+TXD.</report>
<!--			<report
        test="$qual = 'PMT' and ./C_C108/D_4440 != 'INDEMNITE FORFAITAIRE POUR FRAIS DE RECOUVREMENT DE 40 EUROS' and count(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'SU'][D_3207 = 'FR']) > 0"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[FTX/3453]: The element 4440 (Free text value) under the segment FTX+<value-of
          select="$qual"/> is not correct. The value of this element, if relevent - supplier comes from France, should be
        exactly: 'INDEMNITE FORFAITAIRE POUR FRAIS DE RECOUVREMENT DE 40 EUROS'.</report>-->
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="./S_FTX[1]"/>
			<report test="count(./S_FTX[D_4451 = 'TXD']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[FTX/4451]: The FTX+TXD can occur maximum
        one time </report>
			<report test="count(./S_FTX[D_4451 = 'AAC']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[FTX/4451]: The FTX+AAC can occur maximum
        one time </report>
<!--			<report test="count(./S_FTX[D_4451 = 'PMT']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[FTX/4451]: The FTX+PMT can occur maximum
        one time </report>-->
<!--			<report
        test="count(./S_FTX[D_4451 = 'PMT']) != 1 and count(/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'SU'][D_3207 = 'FR']) > 0"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[FTX/4451]: The FTX+PMT is mandatory whe the supplier comes from France (Value 'Country
        code', SG2/NAD+SU/3207 = 'FR').</report>-->
		</rule>
	</pattern>
		
	<!-- Check presence of FTX+TXD allowed -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/S_FTX[D_4451 = 'TXD']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="$orderType = '380' and count(/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_TAX/C_C243[D_5279 = 'FTXHD']) = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[S_TAX] When using FTX+TXD, 'FTXHD' should be present in at least one S_TAX/C_C243/D_5279 segment.</report>
		</rule>
	</pattern>

	<!-- SG1/RFF -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG1/S_RFF/C_C506/D_1153">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="count($codelist//Code[@id = 'SG1_RFF_1153_Invoic']/enumeration[@value = $codeValue]) = 0 and $orderType = '380'"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG1/RFF/C506/1153]: The value '<value-of select="$codeValue"/>' for RFF qualifier('1153')
        is not correct. The accepted values for an Invoice message (BGM+380) are 'AAK', 'IV', 'ON' or
        'PQ'. </report>
			<report
        test="count($codelist//Code[@id = 'SG1_RFF_1153_Credit']/enumeration[@value = $codeValue]) = 0 and $orderType = '381'"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG1/RFF/C506/1153]: The value '<value-of select="$codeValue"/>' for RFF qualifier('1153')
        is not correct. The accepted values for an Credit note message (BGM+381) are 'AAK', 'DL',
        'IV', 'ALQ', 'ACE', 'ON', 'ALO', 'CD' or 'PQ'.</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="./G_SG1/S_RFF"/>
			<!-- Mandatory element -->
<!--			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'AAK']) != 1 and $orderType = '380' and not(exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E']))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG1/RFF] The segment RFF+AAK should occur exactly one time in case of Invoice message
        (BGM+380) when no adjustment. </report>-->
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'ON']) != 1 and $orderType = '380' and not(exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E']))">
        { }[SG1/RFF] The segment RFF+ON should occur exactly one time in case of Invoice message
        (BGM+380) when no adjustment.</report>
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'IV']) != 1 and $orderType = '381'">
        { }[SG1/RFF] The segment RFF+IV should occur exactly one time in case of Credit note message
        (BGM+381). </report>
			<!-- Duplicated elements -->
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'DL']) > 1"> { }[SG1/RFF] The segment RFF+DL
        should occur maximum one time. </report>
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'ALQ']) > 1"> { }[SG1/RFF] The segment RFF+ALQ
        should occur maximum one time. </report>
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'ACE']) > 1"> { }[SG1/RFF] The segment RFF+ACE
        should occur maximum one time. </report>
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'ALO']) > 1"> { }[SG1/RFF] The segment RFF+ALO
        should occur maximum one time. </report>
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'CD']) > 1"> { }[SG1/RFF] The segment RFF+CD
        should occur maximum one time. </report>
			<report test="count(./G_SG1/S_RFF/C_C506[D_1153 = 'PQ']) > 1"> { }[SG1/RFF] The segment RFF+PQ
        should occur maximum one time. </report>
		</rule>
	</pattern>


	<!-- SG1/DTM -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG1/S_DTM/C_C507/D_2005">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG1_DTM_2005']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG1/C507/2005]: The value '<value-of select="$codeValue"/>' for SG1/DTM qualifier('2005')
        is not correct. The value should be 171. </assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG1/S_DTM/C_C507/D_2379">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG1_DTM_2379']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG1/C507/2379]: The value '<value-of select="$codeValue"/>' for SG1/DTM qualifier('2379')
        is not correct. The value should be 102. </assert>
		</rule>
	</pattern>

	<!-- SG2/NAD -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD/D_3035">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG2_NAD_3035']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/3035]: The value '<value-of select="$codeValue"/>' for SG2/NAD qualifier ('3035')
        is not correct. The value should be 'AB','BY','DP','II','IV','SR','SU','SF','UC'. </assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD/C_C082/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG2_NAD_3055']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C082/3055]: The value '<value-of select="$codeValue"/>' for SG2/NAD agency code
        ('3055') is not correct. The value should be 9 (=GS1). </assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD/C_C082/D_3039">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != $emptyGLN">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C082/3039] The value <value-of select="."/> is a GLN must be
        a number composed by 13 digits.</report>
		</rule>
	</pattern>
	<!-- Validation of GLN -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2">
			<let name="actualSegment" value="./S_NAD"/>
			<assert	test="matches(normalize-space(./S_NAD/C_C082/D_3039), '^[0-9]+$') and (u:gln(normalize-space(./S_NAD/C_C082/D_3039)) or ./S_NAD/C_C082/D_3039 = '0000000000000')">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C082/3039] The value <value-of select="./S_NAD/C_C082/D_3039"/> has an invalid GLN checkdigit provided. <value-of select="u:gln(normalize-space(./S_NAD/C_C082/D_3039))"/></assert>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- Mandatory element -->
			<report test="count(./G_SG2/S_NAD[D_3035 = 'IV']) != 1">{ }[SG2/NAD] The segment NAD+IV should
        occur exactly one time. </report>
			<report test="count(./G_SG2/S_NAD[D_3035 = 'BY']) != 1">{ }[SG2/NAD] The segment NAD+BY should
        occur exactly one time. </report>
			<report test="count(./G_SG2/S_NAD[D_3035 = 'SU']) != 1">{ }[SG2/NAD] The segment NAD+SU should
        occur exactly one time. </report>
			<!-- Duplicated elements -->
			<report test="count(./G_SG2/S_NAD[D_3035 = 'AB']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+AB should
        not occur more than once. </report>
			<report test="count(./G_SG2/S_NAD[D_3035 = 'DP']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+DP should
        not occur more than once. </report>
			<report test="count(./G_SG2/S_NAD[D_3035 = 'II']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+II should
        not occur more than once. </report>
			<report test="count(./G_SG2/S_NAD[D_3035 = 'SR']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+SR should
        not occur more than once. </report>
			<report test="count(./G_SG2/S_NAD[D_3035 = 'SF']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+SF should
        not occur more than once. </report>
			<report test="count(./G_SG2/S_NAD[D_3035 = 'UC']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+UC should
        not occur more than once. </report>
		</rule>
	</pattern>
	<!-- Check that GLN for NAD+AB or NAD+DP are different than NAD+BY-->
<!--	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'AB' or D_3035 = 'DP']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="glnBuyer" value="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'BY']/C_C082/D_3039"/>
			<report test="./C_C082/D_3039 = $glnBuyer"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+<value-of
          select="./D_3035"/> with GLN value '<value-of select="./C_C082/D_3039"/>' should not be
        present. The segment should be present only if the GLN of this one is different than the one
        in NAD+BY ('<value-of select="$glnBuyer"/>')</report>
		</rule>
	</pattern>-->
	<!-- Check that GLN for NAD+II or NAD+SR are different than NAD+SU-->
<!--	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'II' or D_3035 = 'SR']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="glnSup" value="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'SU']/C_C082/D_3039"/>
			<report test="./C_C082/D_3039 = $glnSup"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+<value-of
          select="./D_3035"/> with GLN value '<value-of select="./C_C082/D_3039"/>' should not be
        present. The segment should be present only if the GLN of this one is different than the one
        in NAD+SU ('<value-of select="$glnSup"/>')</report>
		</rule>
	</pattern>-->
	<!-- Check that NAD+UC is present with an empty GLN (=Home Delivery Order)-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'UC']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="./C_C082/D_3039 != $emptyGLN"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD] The segment NAD+<value-of
          select="./D_3035"/> can only be used with a dummy GLN ('<value-of select="$emptyGLN"
        />').</report>
		</rule>
	</pattern>
	
	<!-- Check presence of RFF+VA or RFF+XA (in case no RFF+VA) on NAD+SU -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'SU']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'VA']) and count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'XA'])"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+SU] The
        segment NAD+SU must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. Not both.</report>
		</rule>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2[S_NAD/D_3035 = 'SU']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'G_')]"/>
			<report test="count(./G_SG3/S_RFF[C_C506/D_1153 = 'VA' or C_C506/D_1153 = 'XA']) = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+SU] The
        segment NAD+SU must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. One should be present.</report>
		</rule>
	</pattern>
	
		<!-- Check presence of RFF+VA or RFF+XA (in case no RFF+VA) on NAD+IV -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'IV']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'VA']) and count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'XA'])"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+IV] The
        segment NAD+IV must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. Not both.</report>
		</rule>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2[S_NAD/D_3035 = 'IV']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'G_')]"/>
			<report test="count(./G_SG3/S_RFF[C_C506/D_1153 = 'VA' or C_C506/D_1153 = 'XA']) = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+IV] The
        segment NAD+IV must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. One should be present.</report>
		</rule>
	</pattern>
	
		<!-- Check presence of RFF+VA or RFF+XA (in case no RFF+VA) on NAD+BY -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'BY']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'VA']) and count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'XA'])"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+BY] The
        segment NAD+BY must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. Not both.</report>
		</rule>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2[S_NAD/D_3035 = 'BY']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'G_')]"/>
			<report test="count(./G_SG3/S_RFF[C_C506/D_1153 = 'VA' or C_C506/D_1153 = 'XA']) = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+BY] The
        segment NAD+BY must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. One should be present.</report>
		</rule>
	</pattern>
	
		<!-- Check presence of RFF+VA or RFF+XA (in case no RFF+VA) on NAD+II -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 = 'II']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'VA']) and count(/INTERCHANGE/M_INVOIC/G_SG3/S_RFF[C_C506/D_1153 = 'XA'])"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+II] The
        segment NAD+II must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. Not both.</report>
		</rule>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2[S_NAD/D_3035 = 'II']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'G_')]"/>
			<report test="count(./G_SG3/S_RFF[C_C506/D_1153 = 'VA' or C_C506/D_1153 = 'XA']) = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD+II] The
        segment NAD+II must be followed by RFF+VA or RFF+XA (in case not VAT viable) segment. One should be present.</report>
		</rule>
	</pattern>

	<!-- Check that every element of the address are in plain text when it's mandatory according to Belgian's law -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 != 'SF']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="element" value="./C_C080/D_3036"/>
			<let name="qual" value="./D_3035"/>
			<report test="empty($element) and ($qual != 'DP' and $qual != 'UC')"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C080/3036] The
        segment NAD+<value-of select="$qual"/> doesn't have any 'Party name' element.</report>
			<report test="empty($element) and $qual = 'DP' and not($isHomeDeliveryCase1)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C080/3036] The segment NAD+<value-of select="$qual"/> doesn't have any 'Party name'
        element and we are not in a case of Home Delivery Order.</report>
			<report test="empty($element) and $qual = 'UC' and not($isHomeDeliveryCase3)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C080/3036] The segment NAD+<value-of select="$qual"/> doesn't have any 'Party name'
        element and we are not in a case of Home Delivery Order.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 != 'SF']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="element" value="./C_C059/D_3042"/>
			<let name="qual" value="./D_3035"/>
			<report test="empty($element) and ($qual != 'DP' and $qual != 'UC')"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C059/3042] The
        segment NAD+<value-of select="$qual"/> doesn't have any 'Party street' element.</report>
			<report test="empty($element) and $qual = 'DP' and not($isHomeDeliveryCase1)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C059/3042] The segment NAD+<value-of select="$qual"/> doesn't have any 'Party
        street' element and we are not in a case of Home Delivery Order.</report>
			<report test="empty($element) and $qual = 'UC' and not($isHomeDeliveryCase3)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/C059/3042] The segment NAD+<value-of select="$qual"/> doesn't have any 'Party
        street' element and we are not in a case of Home Delivery Order.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 != 'SF']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="element" value="./D_3164"/>
			<let name="qual" value="./D_3035"/>
			<report test="empty($element) and ($qual != 'DP' and $qual != 'UC')"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/3164] The
        segment NAD+<value-of select="$qual"/> doesn't have any 'City Name' element.</report>
			<report test="empty($element) and $qual = 'DP' and not($isHomeDeliveryCase1)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/3164]
        The segment NAD+<value-of select="$qual"/> doesn't have any 'City Name' element and we are
        not in a case of Home Delivery Order.</report>
			<report test="empty($element) and $qual = 'UC' and not($isHomeDeliveryCase3)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/3164]
        The segment NAD+<value-of select="$qual"/> doesn't have any 'City Name' element and we are
        not in a case of Home Delivery Order.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 != 'SF']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="element" value="./D_3251"/>
			<let name="qual" value="./D_3035"/>
			<report test="empty($element) and ($qual != 'DP' and $qual != 'UC')"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/D_3251] The
        segment NAD+<value-of select="$qual"/> doesn't have any 'Postal identification code'
        element.</report>
			<report test="empty($element) and $qual = 'DP' and not($isHomeDeliveryCase1)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/D_3251] The segment NAD+<value-of select="$qual"/> doesn't have any 'Postal
        identification code' element and we are not in a case of Home Delivery Order.</report>
			<report test="empty($element) and $qual = 'UC' and not($isHomeDeliveryCase3)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/D_3251] The segment NAD+<value-of select="$qual"/> doesn't have any 'Postal
        identification code' element and we are not in a case of Home Delivery Order.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_NAD[D_3035 != 'SF']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="element" value="./D_3207"/>
			<let name="qual" value="./D_3035"/>
			<report test="empty($element) and ($qual != 'DP' and $qual != 'UC')"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/D_3207] The
        segment NAD+<value-of select="$qual"/> doesn't have any 'Country name code'
        element.</report>
			<report test="empty($element) and $qual = 'DP' and not($isHomeDeliveryCase1)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/D_3207] The segment NAD+<value-of select="$qual"/> doesn't have any 'Country name
        code' element and we are not in a case of Home Delivery Order.</report>
			<report test="empty($element) and $qual = 'UC' and not($isHomeDeliveryCase3)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/NAD/D_3207] The segment NAD+<value-of select="$qual"/> doesn't have any 'Country name
        code' element and we are not in a case of Home Delivery Order.</report>
		</rule>
	</pattern>

	<!-- SG2/FII-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_FII/D_3035">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG2_FII_3035']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3035]: The value '<value-of select="$codeValue"/>' for SG2/FII qualifier ('3035')
        is not correct. The value should be 'RB'.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_FII/C_C088/D_1131">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG2_FII_1131']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/1131]: The value '<value-of select="$codeValue"/>' for SG2/FII code list
        identification code ('1131') is not correct. The value should be '25'.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_FII/C_C088/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG2_FII_3055']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3055]: The value '<value-of select="$codeValue"/>' for SG2/FII agency code ('3055')
        is not correct. The value should be '5'.</assert>
		</rule>
	</pattern>
	<!-- Check that we always have a IBAN and BIC under SU or II-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="./G_SG2/S_FII"/>
			<let name="suFII" value="count(./G_SG2[S_NAD/D_3035 = 'SU'][S_FII])"/>
			<let name="iiFII" value="count(./G_SG2[S_NAD/D_3035 = 'II'][S_FII])"/>
			<report test="$suFII = 0 and $iiFII = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/C078/3194]: The FII segment (contains IBAN
        and BIC) at least under one of those two NAD: NAD+SU or NAD+IV. </report>
		</rule>
	</pattern>
<!--	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_FII/C_C088/D_3434">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="translate(normalize-space(.), ' ', '')"/>
			<let name="iban" value="translate(normalize-space(/INTERCHANGE/M_INVOIC/G_SG2/S_FII/C_C078/D_3194), ' ', '')"/>
			<let name="ibanBank" value="substring($iban, 5, 3)"/>
			<let name="ibanBic" value="concat($ibanBank, $codeValue)"/>
			<assert test="$codelist//Code[@id = 'BIC']/enumeration[@value = $codeValue]">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3434]: The value '<value-of select="$codeValue"/>' for BIC identification code is not valid in 'BE'.</assert>
			<assert test="$codelist//Code[@id = 'IBANBIC']/enumeration[@value = $ibanBic]">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3434]: The combination of bank identification '<value-of select="$ibanBank"/>' and BIC '<value-of select="$codeValue"/>' is not valid.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_FII/C_C088/D_3434">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="translate(normalize-space(.), ' ', '')"/>
			<report	test="string-length($codeValue) != 8">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3434] BIC number <value-of select="$codeValue"/> is not 8 meaningfull characters.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/S_FII/C_C078/D_3194">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="translate(normalize-space(.), ' ', '')"/>
			<let name="length" value="string-length($codeValue)"/>
			<let name="digits" value="if (string-length($codeValue) >= 16) then xs:decimal(number(substring($codeValue, 5, 10))) else 0"/>
			<let name="chkdgt" value="$digits mod 97"/>
			<let name="dummyValue" value="concat(substring($codeValue, string-length($codeValue) - 1),substring($codeValue, string-length($codeValue) - 1),'111400')"/>
			<let name="ibanChkdgt" value="if (string-length($codeValue) >=16) then (98 - (number($dummyValue) mod 97)) else 0"/>
			<report	test="number($chkdgt) != 0 and number($chkdgt) != number(substring($codeValue, string-length($codeValue) - 1))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3194] The IBANnr <value-of select="$codeValue"/> has an invalid checkdigit provided. Calculated MOD97 checkdigit = <value-of select="$chkdgt"/>. digits = <value-of select="$digits"/> orig = <value-of select="number(substring($codeValue, string-length($codeValue) - 1))"/> mod97 = <value-of select="$digits mod 97"/> </report>
			<report	test="number($chkdgt) = 0 and 97 != number(substring($codeValue, string-length($codeValue) - 1))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3194] The IBANnr <value-of select="$codeValue"/> has an invalid checkdigit provided. Calculated MOD97 checkdigit = 0 (97). digits = <value-of select="$digits"/> orig = <value-of select="number(substring($codeValue, string-length($codeValue) - 1))"/> mod97 = <value-of select="$digits mod 97"/> </report>
			<report	test="string-length($codeValue) != 16">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3194] IBAN number <value-of select="$codeValue"/> is not 16 alphanumerical characters.</report>
			<report	test="number($ibanChkdgt) != number(substring($codeValue, 3, 2)) and substring($codeValue, 1, 2) = 'BE'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/FII/3194] The checkdigits of IBANnr <value-of select="$codeValue"/> after 'BE' has an invalid value provided. Calculated MOD97 checkdigits = <value-of select="$ibanChkdgt"/> </report>
		</rule>
	</pattern>-->

	<!-- SG2/SG3/RFF -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/G_SG3/S_RFF/C_C506/D_1153">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG3_RFF_1153']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF/C506/1153]: The value '<value-of select="$codeValue"/>' for SG3/RFF with
        qualifier ('1153') is not correct. The value should be 'VA', 'XA' or 'YC1'.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2">
			<let name="nadQual" value="./S_NAD/D_3035"/>
			<let name="actualSegment" value="./G_SG3/S_RFF"/>
			<!-- Mandatory element -->
			<report
        test="($nadQual = 'IV' or $nadQual = 'II' or $nadQual = 'SU' or $nadQual = 'BY') and count(./G_SG3/S_RFF[C_C506/D_1153 = 'VA' or 'XA']) = 0"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF] The segment RFF+VA(Vat number) or the RFF+XA(Company/place registration
        number) should always appear exactly one time under those NAD segments: NAD+IV, NAD+II,
        NAD+SU, NAD+BY. </report>
			<!-- Exclusive element -->
			<report
        test="($nadQual = 'SU' or $nadQual = 'BY') and count(./G_SG3/S_RFF[C_C506/D_1153 = 'VA']) >= 1 and count(./G_SG3/S_RFF[C_C506/D_1153 = 'XA']) >= 1"
        > {<value-of select="f:getEdifactPosition($actualSegment[1])"/>}[SG2/SG3/RFF] The segment RFF+VA(Vat number) or the RFF+XA(Company/place registration
        number) should not appear both under those NAD segments: NAD+SU, NAD+BY. </report>
			<!-- Duplicated elements -->
			<report test="count(./G_SG3/S_RFF[C_C506/D_1153 = 'VA']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF] The segment
        RFF+VA should not occur more than once. </report>
			<report test="count(./G_SG3/S_RFF[C_C506/D_1153 = 'XA']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF] The segment
        RFF+XA should not occur more than once. </report>
			<report test="count(./G_SG3/S_RFF[C_C506/D_1153 = 'YC1']) > 1"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF] The segment
        RFF+YC1 should not occur more than once. </report>
		</rule>
	</pattern>
	<!-- Validation of CBE and VAT numbers -->
<!--	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/G_SG3/S_RFF[C_C506/D_1153 = 'VA']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="length" value="string-length(./C_C506/D_1154)"/>
			<let name="vatnr" value="./C_C506/D_1154"/>
			<let name="cbenr" value="substring(./C_C506/D_1154, 3)"/>
			<let name="digits" value="number(substring($cbenr, 1, string-length($cbenr) - 2))"/>
			<let name="chkdgt" value="97 - ($digits mod 97)"/>
			<report	test="number($chkdgt) != number(substring($cbenr, string-length($cbenr) - 1))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF/C506/1154] The value <value-of select="$vatnr"/> has an invalid VAT checkdigit provided. Calculted MOD97 checkdigit = <value-of select="$chkdgt"/>.</report>
			<report	test="string-length($vatnr) != 12 or (substring($vatnr, 1,2) != 'BE' and substring($vatnr, 1,2) != 'LU')">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF/C506/1154] VAT number <value-of select="$cbenr"/> is not 'BE'/'LU' followed by 10 digits.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG2/G_SG3/S_RFF[C_C506/D_1153 = 'XA']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="length" value="string-length(./C_C506/D_1154)"/>
			<let name="cbenr" value="./C_C506/D_1154"/>
			<let name="digits" value="number(substring($cbenr, 1, string-length($cbenr) - 2))"/>
			<let name="chkdgt" value="97 - ($digits mod 97)"/>
			<report	test="number($chkdgt) != number(substring($cbenr, string-length($cbenr) - 1))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF/C506/1154] The value <value-of select="$cbenr"/> has an invalid CBE checkdigit provided. Calculted MOD97 checkdigit = <value-of select="$chkdgt"/>.</report>
			<report	test="string-length($cbenr) != 10">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG2/SG3/RFF/C506/1154] CBE number <value-of select="$cbenr"/> is not 10 digits.</report>
		</rule>
	</pattern>-->

	<!-- SG7/CUX -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG7/S_CUX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="./C_C504[1]/D_6345 = ./C_C504[2]/D_6345"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX]: The second composite of
        the segment SG7/CUX can be removed. The reference currency ('<value-of
          select="./C_C504[1]/D_6345"/>') and the target currency ('<value-of
          select="./C_C504[2]/D_6345"/>') are the same value.</report>
			<report test="exists(./C_C504[2]) and not(exists(./D_5402))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX]: There is a Target
        Currency element but there is no Rate of Exchange element (CUX/5402).</report>
			<report test="not(exists(./C_C504[2])) and exists(./D_5402)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX]: There is a Rate of
        Exchange element but there is no Target Currency element (CUX/C504[2]).</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG7/S_CUX/D_5402">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(translate(., ',', '.')))  and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX/D_5402]: The Rate of Exchange element in the SG7/CUX
        segment is not a number. </report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG7/S_CUX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./C_C504[2]) and count(/INTERCHANGE/M_INVOIC/G_SG50[S_MOA/C_C516/D_5025 = '176']) = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX/D_6245(2)]: Target currency specified without MOA+176 present. </report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG7/S_CUX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="./C_C504[1]/D_6347 != '2'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX/C504/6347]: The value Currency usage code
        qualifier '<value-of select="./C_C504[1]/D_6347"/>' for the first Currency Details composite
        of SG7/CUX is not correct. The value must be '2'.</report>
			<report test="./C_C504[1]/D_6343 != '4'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX/C504/6343]: The value Currency type code
        qualifier '<value-of select="./C_C504[1]/D_6343"/>' for the first Currency Details composite
        of SG7/CUX is not correct. The value must be '4'.</report>
			<report test="./C_C504[2]/D_6347 != '3'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX/C504/6347]: The value Currency usage code
        qualifier '<value-of select="./C_C504[2]/D_6347"/>' for the second Currency Details
        composite of SG7/CUX is not correct. The value must be '3'.</report>
			<report test="./C_C504[2]/D_6343 != '10E'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/S_CUX/C504/6343]: The value Currency type
        code qualifier '<value-of select="./C_C504[2]/D_6343"/>' for the second Currency Details
        composite of SG7/CUX is not correct. The value must be '10E'.</report>
		</rule>
	</pattern>

	<!-- SG7/DTM -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG7/S_DTM/C_C507/D_2005">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG7_DTM_2005']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/DTM/C507/2005]: The value '<value-of select="$codeValue"/>' for SG7/DTM with qualifier
        ('2005') is not correct. The value should be '134' for Rate of exchange date/time.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG7/S_DTM/C_C507/D_2379">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG7_DTM_2379']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/DTM/C507/2379]: The value '<value-of select="$codeValue"/>' for SG7/DTM with format
        code ('2379') is not correct. The value should be '102' for CCYYMMDD.</assert>
		</rule>
	</pattern>
	
	<!-- Dependencies with SG7/CUX segment -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG7/S_CUX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="(count(./S_CUX/C_C504/D_6347) = 1) and exists(./S_DTM)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/DTM]: The SG7/DTM segment should not
        be present if there is no Target Currency in the CUX segment.</report>
			<report test="(count(./S_CUX/C_C504/D_6347) gt 1) and not(exists(./S_DTM))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG7/DTM]: The SG7/DTM segment should be
        present if there is a Target Currency in the CUX segment.</report>
		</rule>
	</pattern>

	<!-- SG8 - Global logic element present or not -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<report test="./S_DTM/C_C507/D_2005 = '12' and ./S_PAT/D_4279 != '22'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/DTM/C507/2005]:
        The qualifier '12' for SG8/DTM can be used only with SG8/PAT+22 segment.</report>
			<report test="./S_DTM/C_C507/D_2005 = '13' and ./S_PAT/D_4279 != '3' and ./S_PAT/D_4279 != '20'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/DTM/C507/2005]:
        The qualifier '13' for SG8/DTM can be used only with SG8/PAT+3 or SG8/PAT+20 segment.</report>
			<report test="./S_PCD/C_C501/D_5245 = '12' and ./S_PAT/D_4279 != '22'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD/C501/5245]:
        The qualifier '12' for SG8/PCD can be used only with SG8/PAT+22 segment.</report>
			<report test="./S_PCD/C_C501/D_5245 = '15' and ./S_PAT/D_4279 != '20'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD/C501/5245]:
        The qualifier '15' for SG8/PCD can be used only with SG8/PAT+20 segment.</report>
			<report test="./S_MOA/C_C516/D_5025 = '52'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/MOA/C516/5025]:
        The qualifier '52' for SG8/MOA can not be used with this segment.</report>
			<report test="./S_MOA/C_C516/D_5025 = '201' and ./S_PAT/D_4279 != '20'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/MOA/C516/5025]:
        The qualifier '201' for SG8/MOA can be used only with SG8/PAT+20 segment.</report>
			<report test="count(./S_MOA) + count(./S_PCD) = 2">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8]: You can't have a SG8/MOA and a
        SG8/PCD segment if the SG8/PAT segment is present. You have to choose between penalty
        percent (PCD) or penalty amount (MOA). </report>
<!--			<report test="count(./S_MOA) + count(./S_PCD) = 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8]: You must have a SG8/MOA or a
        SG8/PCD segment if the SG8/PAT segment is present. You have to choose between penalty
        percent (PCD) or penalty amount (MOA). </report>-->
		</rule>
	</pattern>

	<!-- SG8/PAT-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
<!--			<report test="./S_PAT/D_4279 = '3' and ./S_PAT/C_C112/D_2475 = '5' and not(exists(./S_PAT/C_C112/D_2009))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PAT/C112/2009]:
        The segment 'PAT+3++5' must have a terms time relation code.</report>-->
<!--			<report test="./S_PAT/D_4279 = '3' and ./S_PAT/C_C112/D_2475 = '5' and not(exists(./S_PAT/C_C112/D_2151))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PAT/C112/2151]:
        The segment 'PAT+3++5' must have a period type code 'D' (days).</report>-->
<!--			<report test="./S_PAT/D_4279 = '3' and ./S_PAT/C_C112/D_2475 = '5' and not(exists(./S_PAT/C_C112/D_2152))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PAT/C112/2152]:
        The segment 'PAT+3++5' must have a period count quantity (days).</report>-->
			<report test="./S_PAT/D_4279 = '22' and not(exists(/INTERCHANGE/M_INVOIC/G_SG16/S_ALC[C_C214/D_7161 = 'EAB']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PAT/4279]:
        The segment 'PAT+22' must only be used in combination with (#31) 'ALC+A++++EAB'.</report>
			<report test="./S_PAT/D_4279 = '20' and not(exists(./S_PAT[C_C112/D_2475 = '5'])) and not(exists(/INTERCHANGE/M_INVOIC/G_SG8/S_DTM[C_C507/D_2005 = '13']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PAT]:The segment 'PAT+20' must have a relative or absolute date.</report>
			<report test="./S_PAT/D_4279 = '3' and not(exists(./S_PAT[C_C112/D_2475 = '5'])) and not(exists(/INTERCHANGE/M_INVOIC/G_SG8/S_DTM[C_C507/D_2005 = '13']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PAT]:The segment 'PAT+3' must have a relative date.</report>
		</rule>
	</pattern>
	
	<!-- SG8/DTM-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_DTM/C_C507/D_2005">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG8_DTM_2005']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/DTM/C507/2005]: The value '<value-of select="$codeValue"/>' for SG8/DTM with qualifier
        ('2005') is not correct. The value should be '12' or '13'.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_DTM[C_C507/D_2005 = '13']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(exists(/INTERCHANGE/M_INVOIC/G_SG8/S_PAT[D_4279 = '20']))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/DTM/C507/2005]: SG8/DTM+13 can only be used with PAT+20.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_DTM/C_C507/D_2379">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG8_DTM_2379']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/DTM/C507/2379]: The value '<value-of select="$codeValue"/>' for SG8/DTM with format
        code ('2379') is not correct. The value should be '102' for CCYYMMDD.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_DTM">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(/INTERCHANGE/M_INVOIC/G_SG8/S_PAT/C_C112)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/DTM]: SG8/DTM must be used to express an absolute date but never when C112 of #18 PAT 
        is used to express a relative date.</report>
		</rule>
	</pattern>

	<!-- SG8/PCD-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_PCD/C_C501/D_5245">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG8_PCD_5245']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD/C501/5245]: The value '<value-of select="$codeValue"/>' for SG8/PCD with Percentage
        type code qualifier ('5245') is not correct. The value should can be '12' or '15'.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_PCD">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="count(./C_C501/D_5245 = '12') and not(exists(/INTERCHANGE/M_INVOIC/G_SG8/S_PAT/D_4279 = '22'))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD]: Code value SG8/PCD+12 can only be used if DE 4279 of the preceding PAT segment (#18)  
        has code value 22 (= discount).</report>
			<report test="count(./C_C501/D_5245 = '15') and not(exists(/INTERCHANGE/M_INVOIC/G_SG8/S_PAT/D_4279 = '20'))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD]: Code value SG8/PCD+15 can only be used if DE 4279 of the preceding PAT segment (#18)  
        has code value 20 (= penalty terms).</report>
		</rule>
	</pattern>

	<!-- Ignore element used on other PCD segments -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_PCD/C_C501">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_1131)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD/C501/1131]: The element Code list identification
        code with value '<value-of select="./D_1131"/>' can't be used in this context.</report>
			<report test="exists(./D_3055)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD/C501/3055]: The element Code list identification
        code with value '<value-of select="./D_3055"/>' can't be used in this context.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_PCD/C_C501">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="count(./D_5482) = 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD/C501/5482]: The value 'Percentage basis
        indication code' is mandatory and doesn't appears under SG8/ALC segment.</report>
			<report test="count(./D_5249) = 0 or not(exists(./D_5249 = '13'))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/PCD]: Code value SG8/PCD/C501/5249 must be '13' to indicate percentage basis (13 = invoice value).</report>
		</rule>
	</pattern>


	<!-- SG8/MOA -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG8_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG8/MOA with Monetary
        amount type code qualifier ('5025') is not correct. The value should can be '52' or
        '201'.</assert>
		</rule>
	</pattern>
	<!-- Ignore element used on other MOA segments -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG8/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG8/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- SG12/TOD -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG12/S_TOD/C_C100/D_1131">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG12_TOD_1131']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG12/TOD/C100/1131]: The value '<value-of select="$codeValue"/>' for SG12/TOD with Code
        list identification code ('1131') is not correct. The value should can be '3E' for Incoterms
        2010.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG12/S_TOD">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="./D_4055 = '4' and ./C_C100/D_4053 != 'EXW'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG12/TOD]: The value 'Delivery or
        Transport terms code' with value '4' should be used with the C100/4053 value 'EXW'. </report>
			<report test="./D_4055 = '6' and ./C_C100/D_4053 != 'DDP'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG12/TOD]: The value 'Delivery or
        Transport terms code' with value '6' should be used with the C100/4053 value 'DDP'. </report>
			<report test="true()" role="information"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG12/TOD]: The SG12/TOD segment should be handle in
        the master data and not through EDI. </report>
		</rule>
	</pattern>

	<!-- SG16 - Global present validation -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<let name="alcQual" value="./S_ALC/D_5463"/>
			<report test="./S_PCD/C_C501/D_5245 = '1' and $alcQual != 'A'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG19/PCD/C501/5245]: The PCD+1 element Charge can only be present with SG16/ALC+A. </report>
			<report test="./S_PCD/C_C501/D_5245 = '2' and $alcQual != 'C'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG19/PCD/C501/5245]: The PCD+2 element Allowance can only be present with SG16/ALC+C.
			</report>
<!--			<report test="./S_MOA/C_C516/D_5025 = '204' and $alcQual != 'A'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG20/MOA/C516/5025]: The MOA+204 element Allowance Amount can only be present with SG16/ALC+A.
			</report>
			<report test="./S_MOA/C_C516/D_5025 = '23' and $alcQual != 'C'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG20/MOA/C516/5025]: The MOA+23 element Charge Amount can only be present with SG16/ALC+C.
			</report>-->
			<report test="./G_SG20/S_MOA/C_C516/D_5025 = '204' and $alcQual != 'A'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG20/MOA/C516/5025]: The MOA+204 element Allowance Amount can only be present with SG16/ALC+A.
			</report>
			<report test="./G_SG20/S_MOA/C_C516/D_5025 = '23' and $alcQual != 'C'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG20/MOA/C516/5025]: The MOA+23 element Charge Amount can only be present with SG16/ALC+C.
			</report>
			<report test="./G_SG22/S_MOA/C_C516/D_5025 = '52' and ($alcQual != 'A' or ./S_ALC/C_C214/D_7161 != 'EAB')">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/MOA/C516/5025]: The MOA+23 element Charge Amount can only be present with SG16/ALC+A with Special service description code = 'EAB'.
			</report>
			<report test="count(./G_SG20/S_MOA) + count(./G_SG19/S_PCD) ge 2">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16]: You can't have a SG16/SG20/MOA and a
        SG16/SG19/PCD segment if the SG16/ALC segment is present. You have to choose between penalty percent (PCD) or penalty amount (MOA). </report>
			<!--<report test="count(./G_SG20/S_MOA) + count(./G_SG19/S_PCD) = 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16]: You must have a SG16/SG20/MOA or a
        SG16/SG19/PCD segment if the SG16/ALC segment is present. You have to choose between penalty percent (PCD) or penalty amount (MOA). </report>-->
		</rule>
	</pattern>


	<!-- SG16/ALC -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/S_ALC">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(exists(./C_C214/D_7161))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/C214/7146]: The element 'Special service description code' is mandatory for SG16/ALC segment.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/S_ALC/D_1227">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="(not(number(.)) or contains(., '.')) and  . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/1227]: The value 'Calculation
        sequence code' is not an integer.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/S_ALC/C_C214/D_7161">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG16_ALC_7161']/enumeration[@value = $codeValue]) and not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/C214/7161]: The value '<value-of select="$codeValue"/>' for SG16/ALC with
        Special service description code ('7161') is not correct. The value can be 'EAB', 'FC',
        'HD', 'DI' or a code fom te EBL001 code list.</report>
			<report test=". = 'EAB' and /INTERCHANGE/M_INVOIC/G_SG8/S_PAT/D_4279 != '22'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/C214/7161]: The value '<value-of select="$codeValue"/>' can only be used with the
        SG8/PAT+22 segment. It allows to link the ALC group (SG16) to the PAT segment (in SG8).
			</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/S_ALC/C_C214">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="./D_7161"/>
			<report
        test="$codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue] and not(exists(./D_3055))"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/C214/3055]: One EBL001 code has been used in C214/7161 element so the C214/3055
        element must be present.</report>
			<report
        test="not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue]) and exists(./D_3055)"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/C214/3055]: The element 'Agency code' with value '281' should not be present if
        the 'Special service description code' is not equals to an EBL001 code ('<value-of
          select="./D_7161"/>').</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/S_ALC/C_C214/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG16_ALC_3055']/enumeration[@value = $codeValue]">
       {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/C214/3055]: The value '<value-of select="$codeValue"/>' for Agency code is not
        correct. The only possible value is '281' in this context. </assert>
		</rule>
	</pattern>

	<!-- SG16/SG19/PCD-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG19/S_PCD/C_C501/D_5245">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<let name="parentSegment" value="position()"/>
			<assert test="$codelist//Code[@id = 'SG19_PCD_5245']/enumeration[@value = $codeValue]">
          {<value-of select="$parentSegment"/>}{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG19/PCD/C501/5245]: The value '<value-of
          select="$codeValue"/>' for Percentage type code qualifier is not correct. The only
        possible value is '1' for Allowance or '2' for Charges. </assert>
		</rule>
	</pattern>

	<!-- SG16/SG20/MOA -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG20/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG20_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG20/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG16/SG20/MOA with
        qualifier ('5025') is not correct. The value should be '23' or '204'.</assert>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG20/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG20/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG20/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- SG16/SG22-->
	<!-- Check presence of the MOA segment -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<report test="exists(./S_TAX/C_C243/D_5278) and not(exists(./S_MOA))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/MOA]: The SG16/SG22/MOA segment is mandatory if this is a case 'VAT is due' (SG16/SG22/TAX/C243/5278 Duty or tax or fee rate is present) </report>
			<report test="count(./S_MOA) lt 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16]: You must have a SG16/SG22/MOA 
        segment if the SG16/SG22/TAX segment is present. <value-of select="count(./S_MOA)"/>
			</report>
		</rule>
	</pattern>

	<!-- SG16/SG22/TAX-->
	<!-- Values check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_TAX/C_C243/D_5279">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG22_TAX_5279']/enumeration[@value = $codeValue]) and not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/TAX/C243/5279]: The value '<value-of select="$codeValue"/>' for SG16/SG22/TAX with
        Duty or tax or fee rate code ('5279') is not correct. The value can be 'FTXHD' or a code fom te EBL001 code list.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_TAX/C_C243/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG22_TAX_3055']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/TAX/C243/3055]: The value '<value-of select="$codeValue"/>' for SG16/SG22/TAX with
        AgencyCode ('3055') is not correct. The value can be '281'for GS1 Belgium &amp; Luxembourg.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_TAX/D_5305">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG22_TAX_5305']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/TAX/5305]: The value '<value-of select="$codeValue"/>' for SG16/SG22/TAX with
        Duty or tax or fee category code ('5305') is not correct. The value can be 'AE'for VAT reverse charge.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_TAX/C_C243/D_5278">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/TAX/C243/5278]: The value 'Duty or tax or free rate' is not a number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG16/SG22/TAX/C243/5278]:  The value 'Duty or tax or free rate' has more than 2 digits '<value-of select="."/>'.</report>
		  	<report test="string-length(substring-after(., '.')) != 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG16/SG22/TAX/C243/5278]:  The value 'Duty or tax or free rate' must have exactly 2 digits '<value-of select="."/>'.</report>
		</rule>
	</pattern>
	<!-- Business check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_TAX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- DE 3055 -->
			<report test="./C_C243/D_5279 = 'FTXHD' and exists(./C_C243/D_3055)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG16/SG22/TAX/C243]: The  AgencyCode ('3055') for SG16/SG22/TAX should not be present if the Duty or tax or fee rate code = 'FTXHD'.</report>
			<report test="./C_C243/D_5279 != 'FTXHD' and not(exists(./C_C243/D_3055))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG16/SG22/TAX/C243]: The  AgencyCode ('3055') for SG16/SG22/TAX should be present if the Duty or tax or fee rate code comes from the EBL001 list.</report>
			<!-- DE 5278 -->
			<report test="exists(./C_C243/D_5278) and exists(./C_C243/D_5279)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG16/SG22/TAX/C243]: The Duty or tax or fee rate code ('5279') for SG16/SG22/TAX should not be present if the Duty or tax or fee rate is present '<value-of select="./C_C243/D_5279"/>'.</report>
			<report test="not(exists(./C_C243/D_5278)) and not(exists(./C_C243/D_5279))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG16/SG22/TAX/C243]: The Duty or tax or fee rate code ('5279') or Duty or tax or fee rate ('5278') the for SG16/SG22/TAX should be present. None of them are actually present.</report>
		</rule>
	</pattern>

	<!-- SG16/SG22/MOA-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG22_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG16/SG22/MOA with
        qualifier ('5025') is not correct. The value should be '23' or '204'.</assert>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/SG22/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- SG26/LIN -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="./S_LIN"/>
			<let name="current" value="./S_LIN/D_1082"/>
			<let name="prev_sibling" value="preceding-sibling::*[1]/S_LIN/D_1082"/>
			<let name="prev_parent_sibling" value="parent::*[1]/preceding-sibling::*/.[G_SG26[last()]]/G_SG26[last()]/S_LIN/D_1082"/>
			<let name="currNumber" value="if(number($current)) then (number($current)) else (0)"/>
			<let name="prevNumber" value="if(number($prev_sibling)) then (number($prev_sibling)) else (0)"/>
			<let name="prevParentNumber" value="if(number($prev_parent_sibling[last()])) then number($prev_parent_sibling[last()]) else (0)"/>
			<report test="not($currNumber = $prevNumber + 1 or $currNumber = $prevParentNumber + 1)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/LIN/1082]:The value for LIN+<value-of select="$currNumber"/> is not correctly
        following sequence (1,2,3,4,5...etc).</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_LIN/C_C212/D_7143">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG26_LIN_7143']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/LIN/C212/7143]: The value '<value-of select="$codeValue"/>' for element item type
        identification code in LIN. This one should be equal to 'SRV'. </assert>
		</rule>
	</pattern>
	<!-- Check empty RTI cases vs no GTIN -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="./S_LIN"/>
			<let name="count_C212" value="count(./S_LIN/C_C212)"/>
			<report test="$count_C212 = 0 and not(exists(./S_PIA[C_C212/D_7143 = 'SUE']))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/LIN/C212/7140]: The LIN+<value-of select="./S_LIN/D_1082"/> segment should always
        have a GTIN except in case of empty RTI (PIA+5+&lt;ngrai&gt;:SUE'). </report>
			<report test="$count_C212 = 1 and exists(./S_PIA[C_C212/D_7143 = 'SUE'])"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[[SG26/PIA]:
        The PIA+5+&lt;<value-of select="./S_PIA/C_C212/D_7140"/>&gt;:SUE' segment should not be
        present if there is a valid GTIN under the previous LIN segment. </report>
		</rule>
	</pattern>

	<!-- SG26/PIA -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_PIA/C_C212/D_7143">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG26_PIA_7143']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/7143]: The value '<value-of select="$codeValue"/>' for element Item type identification code. This one should be equal to 'HS','IN','SA' or 'SUE'. </assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_PIA">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="./D_4347 != '1' and (./C_C212/D_7143 = 'HS' or ./C_C212/D_7143 = 'IN' or ./C_C212/D_7143 = 'SA')">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA]: The Item type identifiaction code with value '<value-of select="./C_C212/D_7143"/>' must be used with code qualifier PIA+1.</report>
			<report test="./D_4347 != '5' and ./C_C212/D_7143 = 'SUE'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA]: The Item type identifiaction code with value '<value-of select="./C_C212/D_7143"/>' must be used with code qualifier PIA+5.</report>
		</rule>
	</pattern>
	<!-- Check Duplicate SG26 -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./S_PIA))
          then
            (./S_PIA[last()])
          else
            (./S_LIN[last()])"/>
			<!-- PIA -->
			<report test="count(./S_PIA[C_C212/D_7143 = 'HS']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/4347]: The PIA+HS
        must occur maximum 1 time.</report>
			<report test="count(./S_PIA[C_C212/D_7143 = 'IN']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/4347]: The PIA+IN must
        occur maximum 1 time.</report>
			<report test="count(./S_PIA[C_C212/D_7143 = 'SA']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/4347]: The PIA+SA must
        occur maximum 1 time.</report>
			<report test="count(./S_PIA[C_C212/D_7143 = 'SUE']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/4347]: The PIA+SUE must
        occur maximum 1 time.</report>
			<report test="count(./S_PIA[C_C212/D_7143 = 'SUE']) != 1 and not(exists(./S_LIN/C_C212))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/4347]: The PIA+SUE must
        occur exactly 1 time in case of RTI /assets.</report>
		</rule>
	</pattern>
	<!-- IMD -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./S_IMD))
          then
            (./S_IMD[last()])
          else
            (./S_LIN[last()])"/>
			<report test="count(./S_IMD[/C_C273/D_7009 = 'RD']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/IMD]: The IMD with Item description code 'RD' must
        occur maximum 1 time.</report>
			<report test="count(./S_IMD[/C_C273/D_7009 = 'IN']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/IMD]: The IMD with Item description code 'IN' must
        occur maximum 1 time.</report>
			<report test="count(./S_IMD[/C_C273/D_1131 = 'OAG']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/IMD]: The IMD with Code list identification code 'OAG' must
        occur maximum 1 time.</report>
			<report test="count(./S_IMD/C_C273[D_7009 = 'RD' or D_7009 = 'IN' or D_1131 = 'OAG']) = 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/IMD]: The IMD is mandatory 
			per Belgian law to provide a description as free text of the trade items.</report>
		</rule>
	</pattern>
	<!-- QTY -->
<!--	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./S_QTY))
          then
            (./S_QTY[last()])
          else
            (./S_LIN[last()])"/>
			<report test="1 = 1">
				<value-of select="count(./S_QTY[C_C186/D_6063 = '47'])"/> <value-of select="count(./S_QTY/C_C186[D_6063 = '46' or D_6063 = '194'])"/> <value-of select="$isAdjustment"/>  
			</report>
		</rule>
	</pattern>-->
	
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./S_QTY))
          then
            (./S_QTY[last()])
          else
            (./S_LIN[last()])"/>
			<report test="count(./S_QTY[C_C186/D_6063 = '46']) > 2">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+46
        must occur maximum 1 time.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '47']) > 2">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+47
        must occur maximum 1 time.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '61']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+61
        must occur maximum 1 time.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '124']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+124
        must occur maximum 1 time.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '192']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+192
        must occur maximum 1 time.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '194']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+194
        must occur maximum 1 time.</report>
			<!-- At least one of those quantity should be present -->
			<report test="count(./S_QTY/C_C186[D_6063 = '47' or D_6063 = '61' or D_6063 = '124']) = 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[SG26/QTY/C186/6063]: QTY+47 must occur on each line of an initial invoice or additional invoice or credit note. Except if returned trade items, consumer empties or RTIs are mentioned (QTY+61) or destructed trade items are mentioned (QTY+124).</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '47']) = 1 and count(./S_QTY/C_C186[D_6063 = '46' or D_6063 = '194']) = 0 and $orderType != '381' and not(exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: QTY+46 (or QTY+194 in case of invoice based on RECADV), must occur on each invoice line of the initial invoice
			(except if returned consumer empties or RTIs are mentioned).</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '46']) > 0 and exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E'])">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: QTY+46 must not occur on each line of an additional invoice or credit note.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '46']) > 0 and exists(/INTERCHANGE/M_INVOIC/G_SG1/S_RFF[C_C506/D_1153 = 'ALO'])">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: QTY+46 must not occur on invoice based on receiving advice (RECADV). QTY+46 must be replaced by QTY+194.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '124']) = 1 and ($orderType != '381' or exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E']) or exists(/INTERCHANGE/M_INVOIC/G_SG1/S_RFF[C_C506/D_1153 = 'ALQ']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+124 (damaged goods) can only be used in case of corrective Credit Note "over invoicing" (BGM+381 and no ALI+++79E and RFF+ALQ present).</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '192']) = 1 and (exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E']) or exists(/INTERCHANGE/M_INVOIC/G_SG1/S_RFF[C_C506/D_1153 = 'ALQ']) or exists(/INTERCHANGE/M_INVOIC/G_SG1/S_RFF[C_C506/D_1153 = 'ACE']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+192 (free goods) can only be used in case non-corrective Invoice or Credit Note (no ALI+++79E and RFF+ALQ and RFF+ACE present).</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '61']) = 1 and ($orderType != '381' or exists(/INTERCHANGE/M_INVOIC/S_ALI[D_4183 = '79E']) or exists(/INTERCHANGE/M_INVOIC/G_SG1/S_RFF[C_C506/D_1153 = 'ACE']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+61 (RTI goods) can only be used in case of return Credit Note (BGM+381 and no ALI+++79E and RFF+ACE present).</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '61']) = 1 and not(exists(./S_IMD/C_C273[D_7009 = 'RD'])) and $orderType = '380'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+61 (returned goods) can only be used in case of IMD+F++RD (refundable deposit items).</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '61']) = 1 and exists(./S_QTY/C_C186[D_6063 = '46' or D_6063 = '47'])">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+61 (returned goods) can not be used in combination with QTY+46 and QTY+47.</report>
			<report test="count(./S_QTY[C_C186/D_6063 = '124']) = 1 and $orderType = '381' and exists(./S_QTY/C_C186[D_6063 = '46' or D_6063 = '47'])">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+124 (damaged goods) can not be used in combination with QTY+46 and QTY+47 when credit note.</report>
		</rule>
	</pattern>

	<!-- DTM -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./S_DTM))
          then
            (./S_DTM[last()])
          else
            (./S_LIN[last()])"/>
			<report test="count(./S_DTM[C_C507/D_2005 = '1']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/DTM/C507/2005]: The DTM+1
        must occur maximum 1 time.</report>
			<report test="count(./S_DTM[C_C507/D_2005 = '35']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/DTM/C507/2005]: The DTM+35
        must occur maximum 1 time.</report>
		</rule>
	</pattern>

	<!-- FTX -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./S_FTX))
          then
            (./S_FTX[last()])
          else
            (./S_LIN[last()])"/>
			<report test="count(./S_FTX[D_4451 = 'TXD']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/FTX/4451]: The FTX+TXD
        must occur maximum 1 time.</report>
		</rule>
	</pattern>

	<!-- Not used part -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_PIA[D_4347 = 5]">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./C_C212/D_1131)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C212/1131]: The PIA/C212/1131 element is not used in this context.</report>
			<report test="exists(./C_C212/D_3055)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C212/3055]: The PIA/C212/3055 element is not used in this context.</report>
			<report test="count(./C_C212) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C212]: The PIA/C212 composite cannot appears twice in this context.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_PIA[C_C212/D_7143 = 'SUE']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="./C_C212/D_7140"/>
			<assert test="$codelist//Code[@id = 'RTI_GRAI']/enumeration[@value = $codeValue]">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C212/7140]: The PIA/C212/7140 element with value '<value-of select="./C_C212/D_7140"/>' is not a valid GRAI.</assert>
		</rule>
	</pattern>

	<!-- SG26/IMD -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_PIA/C_C273/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG26_IMD_3055']/enumeration[@value = $codeValue]">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C273/3055]: The PIA/C273/3055 element with value '<value-of select="./C_C212/D_7140"/>' is not correct. The accepted values are '2' for CEC or '9' for GS1.</assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_IMD">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="(./C_C273/D_7009 = 'IN' or ./C_C273/D_7009 = 'RD') and exists./C_C273/D_3055 != 9">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA]: The PIA/C273/7009 element with value 'IN' or 'RD' must be used with the Agency code GS1 ('9').</report>
			<report test="./C_C273/D_1131 = 'OAG' and exists./C_C273/D_3055 != 2">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA]: The PIA/C273/1131 element with value 'OAG' must be used with the Agency code CEC ('2').</report>
		</rule>
	</pattern>
	<!-- Not used part -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_IMD">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="./C_C273/D_1131 = 'OAG' and exists(./C_C273/D_3453)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C273/3453]: The PIA/C273/3453 element is not used when element '1131' element Code list identification code = 'OAG'.</report>
			<report test="./C_C273/D_7009 = 'IN' and exists(./C_C273/D_1131)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C273/1131]: The PIA/C273/1131 element is not used when element '7009' element Item description code = 'IN'.</report>
			<report test="./C_C273/D_7009 = 'RD' and exists(./C_C273/D_1131)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/PIA/C273/1131]: The PIA/C273/1131 element is not used when element '7009' element Item description code = 'RD'.</report>
		</rule>
	</pattern>

	<!-- SG26/MEA -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_MEA/C_C174/D_6314">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/MEA/C174/6314]: The value '<value-of select="."/> is not a valid number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 3" role="warning">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/MEA/C174/6314]: The EANCOM recommends max. 3 digits for the value '<value-of select="."/>'.</report>
		</rule>
	</pattern>

	<!-- SG26/QTY -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_QTY/C_C186/D_6060">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6060]: The value '<value-of select="."/> is not a valid number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 3" role="warning">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6060]: The EANCOM recommends max. 3 digits for the value '<value-of select="."/>'.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_QTY[C_C186/D_6063 = '124']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="./C_C186/D_6063 = '124' and $orderType != '381'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/QTY/C186/6063]: The QTY+124 can be only use in case og damaged goods in a Credit Note (BGM+381).</report>
		</rule>
	</pattern>

	<!-- SG26/DTM -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_DTM/C_C507/D_2005">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG26_DTM_2005']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/DTM/C507/2005]: The value '<value-of select="$codeValue"/>' for SG26/DTM qualifier('2005')
        is not correct. The value should be 1 - Service completion date/time actual or 35 - Delivery date/time actual. </assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_DTM/C_C507/D_2379">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG26_DTM_2379']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/DTM/C507/2379]: The value '<value-of select="$codeValue"/>' for SG26/DTM qualifier('2379')
        is not correct. The value should be 102. </assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_DTM">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="hdrDTM" value="exists(/INTERCHANGE/M_INVOIC/S_DTM[C_C507/D_2005 = '1' or C_C507/D_2005 = '35'])"/>
			<let name="qual" value="./C_C507/D_2005"/>
			<report test="not($hdrDTM)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/DTM]: The SG26/DTM segment with qualifier '<value-of select="$qual"/>' cannot appear if there is no DTM+1 or DTM+35 at header level.</report>
		</rule>
	</pattern>

	<!-- SG26/FTX -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_FTX/D_4451">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG26_FTX_4451']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/FTX/4451]: The value '<value-of select="$codeValue"/>' for SG26/FTX
        is not correct. The value should be TXD - Tax declaration. </assert>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/S_FTX/D_4451">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_TAX/C_C243/D_5279 = 'FTXLN' or /INTERCHANGE/M_INVOIC/G_SG26/G_SG39/G_SG44/S_TAX/C_C243/D_5279 = 'FTXLN')">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/FTX]: The SG26/FTX segment with qualifier 'TXD' cannot appears if there is no SG26/SG34/TAX or SG26/SG39/SG44/TAX segment, with TAX/C243/5279 with value 'FTXLN'.</report>
		</rule>
	</pattern>

	<!-- SG26/SG27/MOA -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG27/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG27_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG27/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG26/SG27/MOA with
        qualifier ('5025') is not correct. The value should be '203' or '496'.</assert>

		</rule>
	</pattern>
		
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./G_SG26/S_MOA/C_C516[D_5025 = '496']))
          then
            (./G_SG26/S_MOA)
          else
            (./S_LIN)"/>
			<let name="MOA_496" value="if (exists(./G_SG27)) then exists(./G_SG27/S_MOA/C_C516[D_5025 = '496']) else exists(./G_SG26/S_MOA/C_C516[D_5025 = '496'])"/>
			<let name="isRTI" value="exists(./S_IMD/C_C273[D_7009 = 'RD'])"/>
			<report test="$isRTI and not($MOA_496)">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG27/MOA]: The SG26/SG27/MOA segment with qualifier '496' must appear in case of RTI/assets and/or consumer empties.</report>
			<report test="not($isRTI) and $MOA_496">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG27/MOA]: The SG26/SG27/MOA segment with qualifier '496' can only appear in case of RTI/assets and/or consumer empties.</report>
		</rule>
	</pattern>
	
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="(./S_LIN)"/>
				<report
		test="count(./G_SG27/S_MOA/C_C516[D_5025 = '203' or '496']) = 0"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG27/MOA] The segment SG26/SG27/MOA segment with qualifier '203' or '496' is mandatory. </report>
		</rule>
	</pattern>

	<!-- Duplicate SG26/SG27/MOA --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./G_SG27[last()]/S_MOA))
          then
            (./G_SG27[last()]/S_MOA)
          else
            (./S_LIN[last()])"/>
			<!-- Position in actual segment not really correct here, but impossible to distinguish two identic segment -->
			<report test="count(./G_SG27/S_MOA[C_C516/D_5025 = '496']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG27/MOA]: The MOA+496
        must occur maximum 1 time.</report>
			<report test="count(./G_SG27/S_MOA[C_C516/D_5025 = '203']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG27/MOA]: The MOA+203
        must occur maximum 1 time.</report>
		</rule>
	</pattern>

	<!-- SG26/SG29/PRI -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG29/S_PRI/C_C509/D_5125">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG29_PRI_5125']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG29/PRI/C509/5125]: The value '<value-of select="$codeValue"/>' for SG26/SG29/PRI with
        qualifier ('5125') is not correct. The value should be 'AAA' - Calculation net or 'AAB' - Calculation gross.</assert>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG29/S_PRI/C_C509/D_5118">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[PRI/C509/5118]: The value '<value-of select="."/>' is not a real decimal number.
			</report>
			<report test="string-length(substring-after(., '.')) &gt; 4" role="warning">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[PRI/C509/5118]: The EANCOM recommends max. 4 digits for the value '<value-of select="."/>'.
			</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG29/S_PRI/C_C509/D_5284">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[PRI/C509/5284]: The value '<value-of select="."/>' is not a real decimal number.
			</report>
			<report test="string-length(substring-after(., '.')) &gt; 3" role="warning">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[PRI/C509/5284]: The EANCOM recommends max. 3 digits for the value '<value-of select="."/>'.
			</report>
		</rule>
	</pattern>

	<!-- Duplicate SG26/SG29/PRI --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./G_SG29[last()]/S_PRI))
          then
            (./G_SG29[last()]/S_PRI)
          else
            (./S_LIN[last()])"/>
			<report test="count(./G_SG29/S_PRI[C_C509/D_5125 = 'AAA']) != 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG29/PRI]: The PRI+AAA
        must occur exactly 1 time by Item Line.</report>
			<report test="count(./G_SG29/S_PRI[C_C509/D_5125 = 'AAB']) != 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG29/PRI]: The PRI+AAB
        must occur exactly 1 time by Item Line.</report>
		</rule>
	</pattern>

	<!-- SG26/SG30/RFF -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG30/S_RFF/C_C506/D_1153">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG30_RFF_1153']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG30/RFF/C506/1153]: The value '<value-of select="$codeValue"/>' for SG26/SG30/RFF with
        qualifier ('1153') is not correct. The value should be 'ALO' - Receiving advice number or 'ON' - Order Number.</assert>
		</rule>
	</pattern>

	<!-- Duplicate SG26/SG30/RFF --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./G_SG30[last()]/S_RFF))
          then
            (./G_SG30[last()]/S_RFF)
          else
            (./S_LIN[last()])"/>
			<report test="count(./G_SG30/S_RFF[C_C506/D_1153 = 'ON']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG30/RFF]: The RFF+ALO
        must occur maximum 1 time by Item Line.</report>
			<report test="count(./G_SG30/S_RFF[C_C506/D_1153 = 'ALO']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG30/RFF]: The RFF+ON
        must occur maximum 1 time by Item Line.</report>
		</rule>
	</pattern>

	<!-- SG26/SG33/LOC -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG33/S_LOC/C_C517/D_3225">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'Country_ISO']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG33/LOC/C517/3225]: The value '<value-of select="$codeValue"/>' for SG26/SG33/LOC with
        is not correct. The value should be a valid ISO 3166 Country code.</assert>
		</rule>
	</pattern>

	<!-- Duplicate SG26/SG33/LOC -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./G_SG33[last()]/S_LOC))
          then
            (./G_SG33[last()]/S_LOC)
          else
            (./S_LIN[last()])"/>
			<report test="count(./G_SG33/S_LOC[D_3227 = '5']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG33/LOC]: The LOC+5
        must occur maximum 1 time by Item Line.</report>
			<report test="count(./G_SG33/S_LOC[D_3227 = '7']) > 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG33/LOC]: The LOC+7
        must occur maximum 1 time by Item Line.</report>
			<report test="./G_SG33/S_LOC[D_3227 = '5']/C_C517/D_3225 = ./G_SG33/S_LOC[D_3227 = '7']/C_C517/D_3225">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG33/LOC]: The LOC+5 Country code value ('<value-of select="./G_SG33/S_LOC[D_3227 = '5']/C_C517/D_3225"/>')
			and the LOC+7 Country code value ('<value-of select="./G_SG33/S_LOC[D_3227 = '7']/C_C517/D_3225"/>') can't be the same.</report>
		</rule>
	</pattern>

	<!-- SG26/SG34-->
	<!-- Check presence of the MOA segment -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<report test="exists(./S_TAX/C_C243/D_5278) and not(exists(./S_MOA))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/MOA]: The SG26/SG34/MOA segment is mandatory if this is a case 'VAT is due' (SG26/SG34/TAX/C243/5278 Duty or tax or fee rate is present) </report>
		</rule>
	</pattern>

	<!-- SG26/SG34/TAX -->
	<!-- Values check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_TAX/C_C243/D_5279">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG34_TAX_5279']/enumeration[@value = $codeValue]) and not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX/C243/5279]: The value '<value-of select="$codeValue"/>' for SG26/SG34/TAX with
        Duty or tax or fee rate code ('5279') is not correct. The value can be 'FTXLN' or a code fom te EBL001 code list.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_TAX/C_C243/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG34_TAX_3055']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX/C243/3055]: The value '<value-of select="$codeValue"/>' for SG26/SG34/TAX with
        AgencyCode ('3055') is not correct. The value can be '281'for GS1 Belgium &amp; Luxembourg.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_TAX/D_5305">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG34_TAX_5305']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX/5305]: The value '<value-of select="$codeValue"/>' for SG26/SG34/TAX with
        Duty or tax or fee category code ('5305') is not correct. The value can be 'AE'for VAT reverse charge.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_TAX/C_C243/D_5278">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX/C243/5278]: The value 'Duty or tax or free rate' is not a number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG26/SG34/TAX/C243/5278]:  The value 'Duty or tax or free rate' has more than 2 digits '<value-of select="."/>'.</report>
		</rule>
	</pattern>
	<!-- Check presence of SG26/SG34/TAX -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="if (exists(./G_SG34[last()]/S_TAX))
          then
            (./G_SG34[last()]/S_TAX)
          else
            (./S_LIN[last()])"/>
			<report test="count(./G_SG34/S_TAX) = 1 and not(exists(./S_LIN/C_C212))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX]: The SG34/TAX must not occur for RTI/assets and consumer empties case.</report>
			<report test="count(./G_SG34/S_TAX) = 0 and not(exists(./S_IMD/C_C273[D_7009 = 'RD']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX]: The SG34/TAX must occur 1 time for Trade Items (except for RTI/assets and consumer empties)</report>
			<report test="count(./G_SG34/S_TAX) = 1 and not(exists(./S_IMD/C_C273[D_7009 = 'RD'])) and ./G_SG34/S_TAX/C_C241/D_5153 = 'VAT' and exists(./G_SG34/S_TAX/C_C243/D_5278) and format-number(./G_SG34/S_TAX/C_C243/D_5278,'0.00') != '6.00'and format-number(./G_SG34/S_TAX/C_C243/D_5278,'0.00') != '12.00'and format-number(./G_SG34/S_TAX/C_C243/D_5278,'0.00') != '21.00'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX]: Invalid SG34/TAX rate for 'VAT'. Must be '6.00', '12.00' or '21.00' for Trade Items.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_TAX/C_C243/D_5278">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/TAX/C243/5278]: The value 'Duty or tax or free rate' is not a number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG26/SG34/TAX/C243/5278]:  The value 'Duty or tax or free rate' has more than 2 digits '<value-of select="."/>'.</report>
		  	<report test="string-length(substring-after(., '.')) != 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG26/SG34/TAX/C243/5278]:  The value 'Duty or tax or free rate' must have exactly 2 digits '<value-of select="."/>'.</report>
		</rule>
	</pattern>
	<!-- Business check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_TAX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- DE 3055 -->
			<report test="./C_C243/D_5279 = 'FTXLN' and exists(./C_C243/D_3055)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG26/SG34/TAX/C243]: The  AgencyCode ('3055') for SG26/SG34/TAX should not be present if the Duty or tax or fee rate code = 'FTXLN'.</report>
			<report test="./C_C243/D_5279 != 'FTXLN' and not(exists(./C_C243/D_3055))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG26/SG34/TAX/C243]: The  AgencyCode ('3055') for SG26/SG34/TAX should be present if the Duty or tax or fee rate code comes from the EBL001 list.</report>
			<!-- DE 5278 -->
			<report test="exists(./C_C243/D_5278) and exists(./C_C243/D_5279)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG26/SG34/TAX/C243]: The Duty or tax or fee rate code ('5279') for SG26/SG34/TAX should not be present if the Duty or tax or fee rate is present '<value-of select="./C_C243/D_5279"/>'.</report>
			<report test="not(exists(./C_C243/D_5278)) and not(exists(./C_C243/D_5279))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG26/SG34/TAX/C243]: The Duty or tax or fee rate code ('5279') or Duty or tax or fee rate ('5278') the for SG26/SG34/TAX should be present. None of them are actually present.</report>
		</rule>
	</pattern>

	<!-- SG26/SG34/MOA-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG34_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG26/SG34/MOA with
        qualifier ('5025') is not correct. The value should be '125' - Taxable Amount.</assert>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26/G_SG34/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26">
			<let name="actualSegment" value="./S_LIN"/>
			<report test="count(./G_SG34/S_MOA[C_C516/D_5025 = '125']) gt 1">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG26/SG34/MOA]: The segment MOA+125 must occur exactly one time per Line Item.</report>
		</rule>
	</pattern>

	<!-- SG39 - Global present validation -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<let name="alcQual" value="./S_ALC/D_5463"/>
			<report test="./G_SG41/S_PCD/C_C501/D_5245 = '1' and $alcQual != 'A'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG41/PCD/C501/5245]: The PCD+1 element Charge can only be present with SG39/ALC+A. </report>
			<report test="./G_SG41/S_PCD/C_C501/D_5245 = '2' and $alcQual != 'C'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG41/PCD/C501/5245]: The PCD+2 element Allowance can only be present with SG39/ALC+C.
			</report>
			<report test="./G_SG42/S_MOA/C_C516/D_5025 = '204' and $alcQual != 'A'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG42/MOA/C516/5025]: The MOA+204 element Allowance Amount can only be present with SG39/ALC+A.
			</report>
			<report test="./G_SG42/S_MOA/C_C516/D_5025 = '23' and $alcQual != 'C'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG42/MOA/C516/5025]: The MOA+23 element Charge Amount can only be present with SG39/ALC+C.
			</report>
			<report test="./G_SG43/S_RTE and ./S_ALC/C_C214/D_7161 != '$bebatCode'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG42/RTE]: The SG39/SG43/RTE can only be present in case of "milieubijdrage/cotisation environnementale".
			</report>
			<report test="./G_SG44/S_MOA/C_C516/D_5025 = '204' and $alcQual != 'A'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/MOA/C516/5025]: The MOA+204 element Allowance Amount can only be present with SG39/ALC+A.
			</report>
			<report test="./G_SG44/S_MOA/C_C516/D_5025 = '23' and $alcQual != 'C'">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/MOA/C516/5025]: The MOA+23 element Charge Amount can only be present with SG39/ALC+C.
			</report>
			<report test="count(./G_SG42/S_MOA) + count(./G_SG41/S_PCD) = 2">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39]: You can't have a SG39/SG42/MOA and a
        SG39/SG41/PCD segment if the SG39/ALC segment is present. You have to choose between penalty percent (PCD) or penalty amount (MOA). </report>
			<report test="count(./G_SG42/S_MOA) + count(./G_SG41/S_PCD) = 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39]: You must have a SG39/SG42/MOA or a
        SG39/SG41/PCD segment if the SG39/ALC segment is present. You have to choose between penalty percent (PCD) or penalty amount (MOA). </report>
		</rule>
	</pattern>

	<!-- SG26/SG39/ALC-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/S_ALC">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(exists(./C_C214/D_7161))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG16/ALC/C214/7146]: The element 'Special service description code' is mandatory for SG16/ALC segment.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/S_ALC/D_1227">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="(not(number(.)) or contains(., '.')) and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/ALC/1227]: The value 'Calculation
        sequence code' is not an integer.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/S_ALC/C_C214/D_7161">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG39_ALC_7161']/enumeration[@value = $codeValue]) and not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/ALC/C214/7161]: The value '<value-of select="$codeValue"/>' for SG39/ALC with
        Special service description code ('7161') is not correct. The value can be 'DI' or a code fom te EBL001 code list.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/S_ALC/C_C214">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="./D_7161"/>
			<report
        test="$codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue] and not(exists(./D_3055))"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/ALC/C214/3055]: One EBL001 code has been used in C214/7161 element so the C214/3055
        element must be present.</report>
			<report
        test="not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue]) and exists(./D_3055)"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/ALC/C214/3055]: The element 'Agency code' with value '281' should not be present if
        the 'Special service description code' is not equals to an EBL001 code ('<value-of
          select="./D_7161"/>').</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/S_ALC/C_C214/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG39_ALC_3055']/enumeration[@value = $codeValue]">
       {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/ALC/C214/3055]: The value '<value-of select="$codeValue"/>' for Agency code is not
        correct. The only possible value is '281' in this context. </assert>
		</rule>
	</pattern>

	<!-- SG26/SG39/SG41/PCD-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG41/S_PCD/C_C501/D_5245">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<let name="parentSegment" value="position()"/>
			<assert test="$codelist//Code[@id = 'SG41_PCD_5245']/enumeration[@value = $codeValue]">
          {<value-of select="$parentSegment"/>}{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG41/PCD/C501/5245]: The value '<value-of
          select="$codeValue"/>' for Percentage type code qualifier is not correct. The only
        possible value is '1' for Allowance or '2' for Charges. </assert>
		</rule>
	</pattern>

	<!-- SG39/SG42/MOA -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG42/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG42_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG42/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG39/SG42/MOA with
        qualifier ('5025') is not correct. The value should be '23' or '204'.</assert>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG42/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG42/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG42/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- SG39/SG43/RTE -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG42/S_RTE/C_C128/D_5420">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[RTE/C128/5420]: The value '<value-of select="."/>' is not a real decimal number.
			</report>
			<report test="string-length(substring-after(., '.')) &gt; 3" role="warning">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[RTE/C128/5420]: The EANCOM recommends max. 3 digits for the value '<value-of select="."/>'.
			</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG42/S_RTE/C_C128/D_5484">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="(not(number(.)) or contains(., '.')) and . != 0 "> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[RTE/C128/5484]: The value 'Unit price basis value' is not an integer.</report>
		</rule>
	</pattern>



	<!-- SG39/SG44-->
	<!-- Check presence of the MOA segment -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<report test="exists(./S_TAX/C_C243/D_5278) and not(exists(./S_MOA))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/MOA]: The SG39/SG44/MOA segment is mandatory if this is a case 'VAT is due' (SG39/SG44/TAX/C243/5278 Duty or tax or fee rate is present) </report>
		</rule>
	</pattern>

	<!-- SG39/SG44/TAX-->
	<!-- Values check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_TAX/C_C243/D_5279">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG44_TAX_5279']/enumeration[@value = $codeValue]) and not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/TAX/C243/5279]: The value '<value-of select="$codeValue"/>' for SG39/SG44/TAX with
        Duty or tax or fee rate code ('5279') is not correct. The value can be 'FTXLN' or a code fom te EBL001 code list.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_TAX/C_C243/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG44_TAX_3055']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/TAX/C243/3055]: The value '<value-of select="$codeValue"/>' for SG39/SG44/TAX with
        AgencyCode ('3055') is not correct. The value can be '281'for GS1 Belgium &amp; Luxembourg.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_TAX/D_5305">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG44_TAX_5305']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/TAX/5305]: The value '<value-of select="$codeValue"/>' for SG39/SG44/TAX with
        Duty or tax or fee category code ('5305') is not correct. The value can be 'AE'for VAT reverse charge.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_TAX/C_C243/D_5278">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/TAX/C243/5278]: The value 'Duty or tax or free rate' is not a number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG39/SG44/TAX/C243/5278]:  The value 'Duty or tax or free rate' has more than 2 digits '<value-of select="."/>'.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_TAX/C_C243/D_5278">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/TAX/C243/5278]: The value 'Duty or tax or free rate' is not a number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG39/SG44/TAX/C243/5278]:  The value 'Duty or tax or free rate' has more than 2 digits '<value-of select="."/>'.</report>
		  	<report test="string-length(substring-after(., '.')) != 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG39/SG44/TAX/C243/5278]:  The value 'Duty or tax or free rate' must have exactly 2 digits '<value-of select="."/>'.</report>
		</rule>
	</pattern>
	<!-- Business check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_TAX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- DE 3055 -->
			<report test="./C_C243/D_5279 = 'FTXLN' and exists(./C_C243/D_3055)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG39/SG44/TAX/C243]: The  AgencyCode ('3055') for SG39/SG44/TAX should not be present if the Duty or tax or fee rate code = 'FTXLN'.</report>
			<report test="./C_C243/D_5279 != 'FTXLN' and not(exists(./C_C243/D_3055))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG39/SG44/TAX/C243]: The  AgencyCode ('3055') for SG39/SG44/TAX should be present if the Duty or tax or fee rate code comes from the EBL001 list.</report>
			<!-- DE 5278 -->
			<report test="exists(./C_C243/D_5278) and exists(./C_C243/D_5279)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG39/SG44/TAX/C243]: The Duty or tax or fee rate code ('5279') for SG39/SG44/TAX should not be present if the Duty or tax or fee rate is present '<value-of select="./C_C243/D_5279"/>'.</report>
			<report test="not(exists(./C_C243/D_5278)) and not(exists(./C_C243/D_5279))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG39/SG44/TAX/C243]: The Duty or tax or fee rate code ('5279') or Duty or tax or fee rate ('5278') the for SG39/SG44/TAX should be present. None of them are actually present.</report>
		</rule>
	</pattern>

	<!-- SG39/SG44/MOA-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG44_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG39/SG44/MOA with
        qualifier ('5025') is not correct. The value should be '23' or '204'.</assert>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG39/G_SG44/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG39/SG44/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- SG50/MOA-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG50_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG50/MOA with
        qualifier ('5025') is not correct. The value should be '9', '77', '79', '113', '129', '150', '176' or '496'.</assert>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50/S_MOA/C_C516/D_5004">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="totalamountvat" value="/INTERCHANGE/M_INVOIC/G_SG50/S_MOA/C_C516/D_5004"/>
			<report test="string-length(substring-after(., '.')) &gt; 4" role="warning">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA/C516/5004]: The EANCOM recommends max. 4 digits after '<value-of select="."/>'.
			</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="./G_SG50[last()]/S_MOA"/>
			<let name="totalamountvat" value="/INTERCHANGE/M_INVOIC/G_SG50/S_MOA/C_C516/D_5004"/>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '9']) > 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+9 must occur maximum one time.
			</report>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '77']) != 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+77 must occur exactly one time.
			</report>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '79']) != 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+79 must occur exactly one time.
			</report>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '113']) > 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+113 must occur maximum one time.
			</report>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '129']) > 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+129 must occur maximum one time.
			</report>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '150']) != 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+150 must occur exactly one time.
			</report>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '176']) > 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+176 must occur maximum one time.
			</report>
			<report test="count(./G_SG50/S_MOA[C_C516/D_5025 = '496']) > 1">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: The SG50/MOA+496 must occur maximum one time.
			</report>
		</rule>
	</pattern>
	
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50/S_MOA[C_C516/D_5025 = '150']">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="totalamountvat" value="number(./C_C516/D_5004)"/>
			<report test="$totalamountvat > 0.00 and not(exists(/INTERCHANGE/M_INVOIC/S_FTX[D_4451 = 'TXD'])) and exists(/INTERCHANGE/M_INVOIC/S_BGM[C_C002/D_1001 = '381'])">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/MOA]: CreditNote should hold text in FTX+TXD to refund tax to the state. 
			</report>
		</rule>
	</pattern>

<!--	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="totalamountvat" value="/INTERCHANGE/M_INVOIC/G_SG50[last()]/S_MOA/C_C516/D_5004"/>
			<report test="1 = 1">
				{<value-of select="count(./G_SG50/S_MOA[C_C516/D_5025 = '150'])"/>} isCreditNote '<value-of select="$isCreditNote"/>' isFreeTextPresent '<value-of select="$isFreeTextPresent"/>' totalamountvat '<value-of select="$totalamountvat"/>'   
			</report>
		</rule>
	</pattern>-->
	
	<!-- SG50/SG51/RFF-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50/G_SG51/S_RFF/C_C506/D_1153">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG51_RFF_1153']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/SG51/RFF/C506/1153]: The value '<value-of select="$codeValue"/>' for SG50/SG51/RFF with
        qualifier ('1153') is not correct. The value should be 'PQ' - Payment Reference.</assert>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50">
			<let name="actualSegment" value="./G_SG51/S_RFF"/>
			<report test="exists(./G_SG51/S_RFF) and ./S_MOA/C_C516/D_5025 != '113'">
				{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/SG51/RFF]: The SG50/SG51/RFF can be only used with segment SG50/MOA+113.
			</report>
		</rule>
	</pattern>

	<!-- SG50/SG51/DTM-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50/G_SG51/S_DTM/C_C507/D_2005">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG51_DTM_2005']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/SG51/C507/2005]: The value '<value-of select="$codeValue"/>' for SG51/DTM qualifier('2005')
        is not correct. The value should be 171. </assert>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50/G_SG51/S_DTM/C_C507/D_2379">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG51_DTM_2379']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG50/SG51/C507/2379]: The value '<value-of select="$codeValue"/>' for SG51/DTM qualifier('2379')
        is not correct. The value should be 102. </assert>
		</rule>
	</pattern>

	<!-- SG52-->
	<!-- Check presence of the MOA segment -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<report test="exists(./S_TAX/C_C243/D_5278) and not(exists(./S_MOA))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/MOA]: The SG52/MOA segment is mandatory if this is a case 'VAT is due' (SG52/TAX/C243/5278 Duty or tax or fee rate is present) </report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="descendant-or-self::*[starts-with(name(),'S_')][last()]"/>
			<report test="count(./G_SG52/S_TAX/C_C243/D_5278) !=  count(distinct-values(./G_SG52/S_TAX/C_C243/D_5278))">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/TAX]: The SG52/TAX segment should not appears twice with the same VAT number.</report>
		</rule>
	</pattern>

	<!-- SG52/TAX-->
	<!-- Values check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52/S_TAX/C_C243/D_5279">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG52_TAX_5279']/enumeration[@value = $codeValue]) and not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/TAX/C243/5279]: The value '<value-of select="$codeValue"/>' for SG52/TAX with
        Duty or tax or fee rate code ('5279') is not correct. The value can be 'FTXLN', 'FTXHD' or a code fom te EBL001 code list.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52/S_TAX/C_C243/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG52_TAX_3055']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/TAX/C243/3055]: The value '<value-of select="$codeValue"/>' for SG52/TAX with
        AgencyCode ('3055') is not correct. The value can be '281'for GS1 Belgium &amp; Luxembourg.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52/S_TAX/D_5305">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'SG52_TAX_5305']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/TAX/5305]: The value '<value-of select="$codeValue"/>' for SG52/TAX with
        Duty or tax or fee category code ('5305') is not correct. The value can be 'AE' for VAT reverse charge or 'E' for Exempt for tax.</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52/S_TAX/C_C243/D_5278">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="not(number(.)) and . != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/TAX/C243/5278]: The value 'Duty or tax or free rate' is not a number.</report>
			<report test="string-length(substring-after(., '.')) &gt; 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG52/TAX/C243/5278]:  The value 'Duty or tax or free rate' has more than 2 digits '<value-of select="."/>'.</report>
			<report test="string-length(substring-after(., '.')) != 2">
	  {<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [SG52/TAX/C243/5278]:  The value 'Duty or tax or free rate' must have exactly 2 digits '<value-of select="."/>'.</report>
		</rule>
	</pattern>
	<!-- Business check -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52/S_TAX">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- DE 3055 -->
			<report test="(./C_C243/D_5279 = 'FTXLN' or ./C_C243/D_5279 = 'FTXHD') and exists(./C_C243/D_3055)"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG52/TAX/C243]: The  AgencyCode ('3055') for SG52/TAX should not be present if the Duty or tax or fee rate code = 'FTXLN' (or 'FTXHD').</report>
			<report test="(./C_C243/D_5279 = 'FTXLN' or ./C_C243/D_5279 = 'FTXHD') and not(exists(./C_C243/D_3055))"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG52/TAX/C243]: The  AgencyCode ('3055') for SG52/TAX should be present if the Duty or tax or fee rate code comes from the EBL001 list.</report>
			<!-- DE 5278 -->
			<report test="(exists(./C_C243/D_5278) and exists(./C_C243/D_5279)) and ./D_5305 = 'AE'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG52/TAX/C243]: The Duty or tax or fee rate code ('5279') for SG52/TAX should not be present if the Duty or tax or fee rate is present '<value-of select="./C_C243/D_5279"/>'.</report>
			<report test="not(exists(./C_C243/D_5278)) and not(exists(./C_C243/D_5279))  and ./D_5305 = 'AE'"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}
	  [SG52/TAX/C243]: The Duty or tax or fee rate code ('5279') or Duty or tax or fee rate ('5278') the for SG52/TAX should be present. None of them are actually present.</report>
	  		<report test="./C_C241/D_5153 = 'VAT' and exists(./C_C243/D_5278) and format-number(./C_C243/D_5278,'0.00') != '6.00'and format-number(./C_C243/D_5278,'0.00') != '12.00'and format-number(./C_C243/D_5278,'0.00') != '21.00'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/TAX]: Invalid SG52/TAX rate for 'VAT'. Must be '6.00', '12.00' or '21.00'.</report>
		</rule>
	</pattern>

	<!-- SG52/MOA-->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG52_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG52/MOA with
        qualifier ('5025') is not correct. The value should be '124' or '04G' or 'B10'.</assert>
			<report test=". = 'B10' and (not(exists(/INTERCHANGE/M_INVOIC/G_SG8/S_PAT[D_4279 = '22'])) or not(exists(/INTERCHANGE/M_INVOIC/G_SG16/S_ALC[C_C214/D_7161 = 'EAB'])))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/MOA/C516/5025]: DE 5025 The element MOA+B10 must occur in combination with #18 PAT+22 and #31 ALC+A++++EAB.</report>
			<report test=". = '124' and exists(/INTERCHANGE/M_INVOIC/G_SG8/S_PAT[D_4279 = '22']) and exists(/INTERCHANGE/M_INVOIC/G_SG16/S_ALC[C_C214/D_7161 = 'EAB']) and not(exists(ancestor-or-self::*[starts-with(name(),'G_SG52')]/S_MOA[C_C516/D_5025 = 'B10']))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/MOA/C516/5025]: DE 5025 The element MOA+B10 must occur in combination with #18 PAT+22 and #31 ALC+A++++EAB.</report>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG52/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- SG53/ALC --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG53/S_ALC/C_C214/D_7161">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<report
        test="not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue])"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/ALC/C214/7161]: The value '<value-of select="$codeValue"/>' for SG53/ALC with
        Special service description code ('7161') is not correct. The value can be a code from te EBL001 code list.</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG53/S_ALC/C_C214">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="./D_7161"/>
			<report
        test="$codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue] and not(exists(./D_3055))"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/ALC/C214/3055]: One EBL001 code has been used in C214/7161 element so the C214/3055
        element must be present.</report>
			<report
        test="not($codelist//Code[@id = 'EBL001CL']/enumeration[@value = $codeValue]) and exists(./D_3055)"
        > {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/ALC/C214/3055]: The element 'Agency code' with value '281' should not be present if
        the 'Special service description code' is not equals to an EBL001 code ('<value-of
          select="./D_7161"/>').</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG53/S_ALC/C_C214/D_3055">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG53_ALC_3055']/enumeration[@value = $codeValue]">
       {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/ALC/C214/3055]: The value '<value-of select="$codeValue"/>' for Agency code is not
        correct. The only possible value is '281' in this context. </assert>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG53/S_ALC/C_C552/D_1227">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="true">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/ALC/C552/1227]: The element Currency identification code
        with value '<value-of select="."/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- SG53/MOA -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG53/S_MOA/C_C516/D_5025">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="codeValue" value="."/>
			<assert test="$codelist//Code[@id = 'SG53_MOA_5025']/enumeration[@value = $codeValue]">
        {<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/MOA/C516/5025]: The value '<value-of select="$codeValue"/>' for SG53/MOA with
        qualifier ('5025') is not correct. The value should be '131'.</assert>
		</rule>
	</pattern>
	<!-- Ignored segment in this context --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG53/S_MOA/C_C516">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test="exists(./D_6345)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/MOA/C516/6345]: The element Currency identification code
        with value '<value-of select="./D_6345"/>' can't be used in this context.</report>
			<report test="exists(./D_6343)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[SG53/MOA/C516/6343]: The element Currency type code qualifier
        with value '<value-of select="./D_6343"/>' can't be used in this context.</report>
		</rule>
	</pattern>

	<!-- UNT -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC">
			<let name="actualSegment" value="./S_UNT"/>
			<let name="oriVal" value="./S_UNT/D_0074"/>
			<let name="val"
        value="
          if (number(./S_UNT/D_0074))
          then
            (number(./S_UNT/D_0074))
          else
            (-1)"/>
			<let name="nbSegments" value="count(//*[starts-with(name(), 'S_')]) - 2"/>
			<report test="$val != $nbSegments">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNT/0074]: The value '<value-of select="$oriVal"/>' isn't
        correct. The UNT value should be equal to the number of segments between UNH and UNT
          segments(=<value-of select="$nbSegments"/>).</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/S_UNT/D_0062">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="unhRef" value="/INTERCHANGE/M_INVOIC/S_UNH/D_0062"/>
			<report test=". != number($unhRef)">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNT/0062]: The value '<value-of select="."/>' isn't
        correct. The UNT value should be equal to the reference present in the UNH segment <value-of
          select="$unhRef"/>.</report>
		</rule>
	</pattern>


	<!-- UNZ -->
	<pattern>
		<rule context="/INTERCHANGE/S_UNZ/D_0036">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<report test=". != '1'">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNZ/0036]: The value '<value-of select="."/>' isn't correct. The UNZ
        value should be equal to the number of messages(=1).</report>
		</rule>
	</pattern>
	<pattern>
		<rule context="/INTERCHANGE/S_UNZ/D_0020">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="unbRef" value="/INTERCHANGE/S_UNB/D_0020"/>
			<report test=". != $unbRef">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[UNZ/0020]: The value '<value-of select="."/>' isn't correct. The
        UNZ value should be equal to the reference present in the UNB segment <value-of
          select="$unbRef"/>.</report>
		</rule>
	</pattern>



	<!-- Global pattern validation -->
	<pattern>
		<rule context="//S_DTM">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<let name="fatherNode"
        value="
          if (name(parent::*[1]) = 'M_INVOIC') then
            ('')
          else
            (concat(substring-after(name(parent::*[1]), '_'), '/'))"/>
			<let name="datum" value="./C_C507/D_2380"/>
			<let name="formatType" value="./C_C507/D_2379"/>

			<let name="validDate102"
        value="concat(substring($datum, 1, 4), '-', substring($datum, 5, 2), '-', substring($datum, 7, 2))"/>
			<let name="validDate203"
        value="concat(substring($datum, 1, 4), '-', substring($datum, 5, 2), '-', substring($datum, 7, 2))"/>
			<let name="validHour203" value="substring($datum, 9, 4)"/>
			<let name="validDate718d1"
        value="concat(substring($datum, 1, 4), '-', substring($datum, 5, 2), '-', substring($datum, 7, 2))"/>
			<let name="validDate718d2"
        value="concat(substring($datum, 10, 4), '-', substring($datum, 14, 2), '-', substring($datum, 16, 2))"/>

			<report test="$formatType = '102' and empty(xs:date($validDate102))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="$fatherNode"/>DTM/C507/D_2380]: The element DTM/C507/2380 with value <value-of
          select="$datum"/> doesn't follow the good date format ('CCYYMMDDHHMM').</report>
			<report test="$formatType = '102' and string-length(normalize-space($datum)) != 8">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="$fatherNode"/>DTM/C507/D_2380]: The element DTM/C507/2380 with value <value-of
          select="$datum"/> doesn't follow the good date format ('CCYYMMDD').</report>

			<report test="$formatType = '203' and string-length(normalize-space($datum)) != 12">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="$fatherNode"/>DTM/C507/D_2380]: The element DTM/C507/2380 with value <value-of
          select="$datum"/> doesn't follow the good date format ('CCYYMMDDHHMM').</report>
			<report test="$formatType = '203' and string-length(normalize-space($validHour203)) != 4">
          {<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of select="$fatherNode"/>DTM/C507/D_2380]: Length of value of 'D_0019' must be
        equal to 4 (HHMM). </report>
			<report test="$formatType = '203' and empty(xs:date($validDate203))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="$fatherNode"/>DTM/C507/2380]: The element DTM/C507/2380 with value <value-of
          select="$datum"/> doesn't follow the good date format ('CCYYMMDD') </report>
			<report
        test="$formatType = '203' and not(matches($validHour203, '^([0-9]|0[0-9]|1[0-9]|2[0-3])[0-5][0-9]$'))"
        >{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of select="$fatherNode"/>DTM/C507/D_2380]: ('<value-of select="$validHour203"/>')
        isn't a valid hour ('HHMM') </report>

			<report test="$formatType = '718' and string-length(normalize-space($datum)) != 17">
          {<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of select="$fatherNode"/>DTM/C507/D_2380]: The element DTM/C507/2380 with value
				<value-of select="$datum"/> doesn't follow the good date format
        ('CCYYMMDD-CCYYMMDD').</report>
			<report test="$formatType = '718' and empty(xs:date($validDate718d1))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="$fatherNode"/>DTM/C507/2380]: The first part of the element DTM/C507/2380 with
        value <value-of select="$validDate718d1"/> isn't a valid date ('CCYYMMDD') </report>
			<report test="$formatType = '718' and empty(xs:date($validDate718d2))">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="$fatherNode"/>DTM/C507/2380]: The second part of the element DTM/C507/2380 with
        value <value-of select="$validDate718d2"/> isn't a valid date ('CCYYMMDD') </report>
			<report
        test="$formatType = '718' and translate($validDate718d1, '-', '') &gt;= translate($validDate718d2, '-', '')"
        >{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of select="$fatherNode"/>DTM/C507/2380]: The first part of the element
        DTM/C507/2380 with value <value-of select="$validDate718d1"/> should be before the date
        provided by the second part of the element DTM/C507/2380 with value <value-of
          select="$validDate718d2"/>.</report>
		</rule>
	</pattern>

	<pattern>
		<rule context="//S_MOA">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- Get parent node name -->
			<let name="fatherNode"
        value="
          if (name(parent::*[1]) = 'M_INVOIC') then
            ('')
          else
            (concat(substring-after(name(parent::*[1]), '_'), '/'))"/>
			<!-- Get grandparent node name -->
			<let name="grandFatherNode"
        value="
          if (name(parent::*[1]) = 'M_INVOIC') then
            ('')
          else
            (concat(substring-after(name(parent::*[1]/parent::*[1]), '_'), '/'))"/>
			<report test="not(number(./C_C516/D_5004)) and ./C_C516/D_5004 != 0">{<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="substring-after($grandFatherNode, 'M_INVOIC ')"/>
				<value-of select="$fatherNode"
        />MOA/C516/5004]: The value '<value-of select="./C_C516/D_5004"/>' is not a real decimal
        number.</report>
			<report test="string-length(substring-after(./C_C516/D_5004, '.')) &gt; 6" role="warning">{<value-of select="f:getEdifactPosition($actualSegment)"/>}
          [<value-of select="$grandFatherNode"/>
				<value-of select="$fatherNode"/>MOA/C516/5004]: The
        EANCOM recommends max. 6 digits for the value '<value-of select="./C_C516/D_5004"
        />'.</report>
		</rule>
	</pattern>


	<pattern>
		<rule context="//S_PCD">
			<let name="actualSegment" value="ancestor-or-self::*[starts-with(name(),'S_')]"/>
			<!-- Get parent node name -->
			<let name="fatherNode"
        value="
          if (name(parent::*[1]) = 'M_INVOIC') then
            ('')
          else
            (concat(substring-after(name(parent::*[1]), '_'), '/'))"/>
			<!-- Get grandparent node name -->
			<let name="grandFatherNode"
        value="
          if (name(parent::*[1]) = 'M_INVOIC') then
            ('')
          else
            (concat(substring-after(name(parent::*[1]/parent::*[1]), '_'), '/'))"/>
			<report test="not(number(./C_C501/D_5482)) and ./C_C501/D_5482 != 0"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="substring-after($grandFatherNode, 'M_INVOIC ')"/>
				<value-of select="$fatherNode"
        />PCD/C501/5482]: The value 'Percentage' is not a number.</report>
			<report test="number(./C_C501/D_5482) &lt; 0 or number(./C_C501/D_5482) &gt; 100"> {<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of
          select="substring-after($grandFatherNode, 'M_INVOIC ')"/>
				<value-of select="$fatherNode"
        />PCD/C501/5482]: The value 'Percentage' is not a valid number between 0 and 100.</report>
			<report test="string-length(substring-after(./C_C501/D_5482, '.')) &gt; 6" role="warning">
          {<value-of select="f:getEdifactPosition($actualSegment)"/>}[<value-of select="substring-after($grandFatherNode, 'M_INVOIC ')"/>
				<value-of
          select="$fatherNode"/>PCD/C501/5482]: The EANCOM recommends max. 6 digits for the value
          '<value-of select="."/>'./C_C501/D_5482</report>
		</rule>
	</pattern>


	<!-- XSLT function 
    @param: S_Node is the Segment Node provided by the assert rule
    @result: A string that provide the position of the segment in the entire list of segments
  -->
	<xsl:function name="f:getEdifactPosition" as="xs:string">
		<xsl:param name="S_Node" as="element()"/>

		<xsl:variable name="posSegment">
			<!-- Loop on all the tags started with 'S_' (=the segments) and count them -->
			<xsl:for-each select="$allSegment[starts-with(name(), 'S_')]">
				<xsl:if test="current() = $S_Node 
			and ( 
			name(current()/parent::*[1]) = name($S_Node/parent::*[1]) 
			or name(current()/parent::*[1]) = 'INTERCHANGE' 
			or name(current()/parent::*[1]) = 'M_INVOIC')">
					<xsl:value-of select="concat(position(),'/')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($posSegment, 1, string-length($posSegment) - 1)"/>
	</xsl:function>

</schema>