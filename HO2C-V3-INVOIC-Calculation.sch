<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" schemaVersion="iso" queryBinding="xslt2"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<ns uri="functions:1.0" prefix="f"/>

	<!-- Reference documents and variables -->
	<let name="allSegment" value="//*[starts-with(name(), 'S_') or starts-with(name(), 'G_')]"/>

	<!-- Global Amount to reuse -->
	<let name ="inv" value="/INTERCHANGE/M_INVOIC"/>

	<!-- Percentage discount for prompt Payment -->


	<title>Schema for HO2C-V3-INVOIC-Calculation; 2002; EAN</title>


	<!-- Rule F test -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26[S_MOA/C_C516/D_5025 = '125']">
			<let name="actualSegment" value="./S_LIN"/>
			<!-- Get the quantity invoiced or the returned quantity -->
			<let name="invoicedQuantity_10" value="number(./S_QTY[C_C186/D_6063 = '47' or C_C186/D_6063 = '61']/C_C186/D_6060)"/>
			<!-- Multiply factor for the Price-->
			<let name="calcGrossPriceMult_9" value="number(if (exists(./S_MEA/C_C174/D_6314) and ./S_MEA/C_C174/D_6411 = ./S_QTY[C_C186/D_6063 = '47']/C_C186/D_6411) then (./S_MEA/C_C174/D_6314) else ('1'))"/>
			<let name="calcGrossPriceUnit_11" value="number(./G_SG29/S_PRI[C_C509/D_5125 = 'AAB']/C_C509/D_5118) * $calcGrossPriceMult_9"/>
			<!-- Charge Amount by line -->
			<let name="sumChargeAmountLine_13" value="number(if (exists(./G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '23']/C_C516/D_5004)) then (sum(./G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '23']/C_C516/D_5004)) else ('0'))"/>
			<!-- Allowance amount by line -->
			<let name="sumAllowanceAmountLine_14" value="number(if (exists(./G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '204']/C_C516/D_5004)) then (sum(./G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '204']/C_C516/D_5004)) else ('0'))"/>
			<!-- Expected result: Line taxable amount -->
			<let name="lineTaxableAmount_12" value="number(sum(./G_SG34/S_MOA[C_C516/D_5025 = '125']/C_C516/D_5004))"/>
			<!-- Result from rule F -->
			<let name="ruleF" value="f:getRuleF(.)"/>

			<report test="f:getRuleF(.) != $lineTaxableAmount_12">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[SG26/LIN] - RULE F error: (#66 MOA+125)rate = [QTY+47 * PRI+AAB] + SUM(MOA+23) - SUM(MOA+204). \n
			Actual value for MOA+125: <value-of select="$lineTaxableAmount_12"/> != <value-of select="$invoicedQuantity_10"/> * <value-of select="$calcGrossPriceUnit_11"/> + <value-of select="$sumChargeAmountLine_13"/> - <value-of select="$sumAllowanceAmountLine_14"/>. \n
			Expected value for MOA+125:  <value-of select="$ruleF"/>
			</report> 

		</rule>
	</pattern>

	<!-- Rule E test -->
	<pattern>
		<!-- For this rule, we assumed that the previous .sch is correctly done, and we don't have duplicated SG52 segment with the same Tax rate -->
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52[S_MOA/C_C516/D_5025 = '04G']">
			<let name="actualSegment" value="/INTERCHANGE/M_INVOIC/S_UNS"/>
			<let name="taxRate" value="number(./S_TAX/C_C243/D_5278)"/>
			<let name="isexempt" value="number(if (/INTERCHANGE/M_INVOIC/G_SG52/S_TAX/D_5305 = 'E') then ('1') else ('0'))"/>

			<!-- Sum of all the Line Taxable Amount - MOA+125 -->
			<let name="sumLineTaxableAmount_12" value="number(sum(//G_SG34[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '125']/C_C516/D_5004))"/>		
			<!-- Global Charge Amount -->
			<let name="globalChargeAmount_8" value="number(if (exists($inv/G_SG16/G_SG22[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '23']/C_C516/D_5004)) then (sum($inv/G_SG16/G_SG22[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '23']/C_C516/D_5004)) else ('0'))"/>
			<!-- Global Allowance Amount -->
			<let name="globalAllowanceAmount_7" value="number(if (exists($inv/G_SG16/G_SG22[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '204']/C_C516/D_5004)) then (sum($inv/G_SG16/G_SG22[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '204']/C_C516/D_5004)) else ('0'))"/>
			<!-- Expected result: Taxable basis amount excluding payment discount => Compared with ruleE -->
			<let name="taxBasisAmountExclPD_3" value="number(.[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '04G']/C_C516/D_5004)"/>
			<!-- Result from rule F -->
			<let name="ruleE" value="number($sumLineTaxableAmount_12 + $globalChargeAmount_8 - $globalAllowanceAmount_7)"/>

			<!-- Check that resultE = taxBasisAmountExclude but the MOA+04G must exist -->
			<report test="(format-number($ruleE,'0.00') != format-number($taxBasisAmountExclPD_3,'0.00')) and string($taxRate) != 'NaN'">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[UNS] - RULE E error: (#87 MOA+04G)rate = SUM(#66 MOA+125)rate + SUM(#37 MOA+23)rate - SUM(#37 MOA+204)rate. \n
			Actual value for MOA+04G: <value-of select="$taxBasisAmountExclPD_3"/> != <value-of select="format-number($sumLineTaxableAmount_12,'0.00')"/> + <value-of select="format-number($globalChargeAmount_8,'0.00')"/> - <value-of select="format-number($globalAllowanceAmount_7,'0.00')"/>. \n
			Expected value for MOA+04G:  <value-of select="format-number($ruleE,'0.00')"/>
			</report> 
		</rule>
	</pattern>


	<!-- Rule B test -->
	<pattern>
		<!-- For this rule, we assumed that the previous .sch is correctly done, and we don't have duplicated SG52 segment with the same Tax rate -->
		<rule context="/INTERCHANGE/M_INVOIC/G_SG16/G_SG22[S_MOA/C_C516/D_5025 = '52']">
			<let name="actualSegment" value="./S_TAX[last()]"/>
			<let name="taxRate" value="number(./S_TAX/C_C243/D_5278)"/>
			<let name="isEAB" value="number(if (/INTERCHANGE/M_INVOIC/G_SG16/S_ALC/C_C214/D_7161 = 'EAB') then ('1') else ('0'))"/>

			<!-- Sum of all the Taxable AMount basis excluding Payement Discount - MOA+04G -->
			<let name="sumtaxBasisAmountExclPD_3" value="number(sum($inv/G_SG52[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '04G']/C_C516/D_5004))"/>		
			<!-- Percentage discount -->
			<let name="percentageDiscountPerPromptPayment_5" value="number(if (exists($inv/G_SG8/S_PCD/C_C501/D_5482)) then ($inv/G_SG8/S_PCD/C_C501/D_5482) else ('1'))"/>
			<!-- Expected result: Payment Discout Amount => Compared with ruleB -->
			<let name="paymentDiscountAmount_6" value="number(.[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '52']/C_C516/D_5004)"/>
			<!-- Result from rule F -->
			<let name="ruleB" value="number($sumtaxBasisAmountExclPD_3 * $percentageDiscountPerPromptPayment_5 * 0.01)"/>

			<!-- Rule B - Check that resultE = taxBasisAmountExclude but the MOA+04G must exist -->
			<report test="($ruleB != $paymentDiscountAmount_6)">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[UNS] - RULE B error: (#37 MOA+52)rate = (#87 MOA+04G)rate * PCD+12 / 100. \n
			Actual value for MOA+04G: <value-of select="$paymentDiscountAmount_6"/> != <value-of select="$sumtaxBasisAmountExclPD_3"/> * <value-of select="$percentageDiscountPerPromptPayment_5"/> / 100. \n
			Expected value for MOA+04G:  <value-of select="$ruleB"/>
			</report> 
		</rule>
	</pattern>

	<!-- Rule C test -->
	<pattern>
		<!-- This rule is checking content and calculation on the MOA+B10 segment (VAT calculation and allowance for short term payment) -->
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52[S_MOA/C_C516/D_5025 = 'B10']">
			<let name="actualSegment" value="./S_TAX[last()]"/>
			<let name="taxRate" value="number(./S_TAX/C_C243/D_5278)"/>
			
			<!-- Sum of all the Taxable AMount basis excluding Payement Discount - MOA+04G -->
			<let name="sumtaxBasisAmountExclPD_3" value="number(sum($inv/G_SG52[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '04G']/C_C516/D_5004))"/>	
			<!-- Sum of all the Taxable AMount basis including Payement Discount - MOA+B10 -->
			<let name="sumtaxBasisAmountInclPD_3" value="number(sum($inv/G_SG52[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = 'B10']/C_C516/D_5004))"/>			
			<!-- Percentage discount -->
			<let name="percentageDiscountPerPromptPayment_5" value="number(if (exists($inv/G_SG8/S_PCD/C_C501/D_5482)) then ($inv/G_SG8/S_PCD/C_C501/D_5482) else ('1'))"/>
			<!-- Expected result: Payment Discout Amount => Compared with ruleB -->
			<let name="paymentDiscountAmount_6" value="number($inv/G_SG16/G_SG22[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '52']/C_C516/D_5004)"/>
			<!-- Result from rule C -->
			<let name="ruleC" value="number($sumtaxBasisAmountExclPD_3 - $paymentDiscountAmount_6)"/>

			<!-- Rule C - Check that resultE = taxBasisAmountExclude but the MOA+04G must exist -->
			<report test="($ruleC != $sumtaxBasisAmountInclPD_3)">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[UNS] - RULE C error: (#87 MOA+B10) = (#87 MOA+04G) - (#37 MOA+52). \n
			Actual value for MOA+B10: <value-of select="$sumtaxBasisAmountInclPD_3"/> != <value-of select="$sumtaxBasisAmountExclPD_3"/> - <value-of select="$paymentDiscountAmount_6"/>. \n
			Expected value for MOA+B10:  <value-of select="$ruleC"/>
			</report> 
		</rule>
	</pattern>	

	<!-- Rule D test --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG52[S_MOA/C_C516/D_5025 = '124']">
			<let name="actualSegment" value="./S_TAX[last()]"/>
			<let name="taxRate" value="number(./S_TAX/C_C243/D_5278)"/>

			<!-- Sum of all the Taxable AMount basis excluding Payement Discount - MOA+04G -->
			<let name="sumtaxBasisAmountExclPD_3" value="number(sum($inv/G_SG52[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '04G']/C_C516/D_5004))"/>		
			<!-- Payment Discout Amount -->
			<let name="paymentDiscountAmount_6" value="number(sum($inv/G_SG16/G_SG22[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '52']/C_C516/D_5004))"/>
			<!-- Expected result: Payment Discout Amount => Compared with ruleB -->
			<let name="totalVatAmount_1" value="number(.[S_TAX/C_C243/D_5278 = $taxRate]/S_MOA[C_C516/D_5025 = '124']/C_C516/D_5004)"/>
			<!-- Result from rule F -->
			<let name="ruleD" value="number(($sumtaxBasisAmountExclPD_3 - $paymentDiscountAmount_6) * $taxRate * 0.01)"/>


			<!-- Rule B - Check that resultE = taxBasisAmountExclude but the MOA+04G must exist -->
			<report test="(format-number($ruleD,'0.00') != format-number($totalVatAmount_1,'0.00')) and string($taxRate) != 'NaN'">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[UNS] - RULE D error: (#87 MOA+124)rate = (#87 MOA+B10)rate * rate. \n
			Actual value for MOA+124: <value-of select="format-number($totalVatAmount_1,'0.00')"/> != (<value-of select="$sumtaxBasisAmountExclPD_3"/> - <value-of select="$paymentDiscountAmount_6"/>) * <value-of select="$taxRate * 0.01"/>. \n
			Expected value for MOA+124:  <value-of select="format-number($ruleD,'0.00')"/>
			</report> 
		</rule>
	</pattern>

	<!-- Rule A test --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG50[S_MOA/C_C516/D_5025 = '150']">
			<let name="actualSegment" value="./S_MOA[last()]"/>

			<!-- Sum of all the Taxable AMount basis excluding Payement Discount - MOA+04G -->
			<let name="sumTotalVatAmount_1" value="number(sum($inv/G_SG52/S_MOA[C_C516/D_5025 = '124']/C_C516/D_5004))"/>		
			<!-- Expected result: Payment Discout Amount => Compared with ruleB -->
			<let name="invoiceVatAmount_2" value="number(./S_MOA[C_C516/D_5025 = '150']/C_C516/D_5004)"/>
			<!-- Result from rule F -->
			<let name="ruleA" value="$sumTotalVatAmount_1"/>


			<!-- Rule A - Check that resultA = sum Total Vat Amount -->
			<report test="($ruleA != $invoiceVatAmount_2)">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[UNS] - RULE A error: #83 MOA+150 = SUM(#87 MOA+124). \n
			Actual value for MOA+150: <value-of select="$invoiceVatAmount_2"/> != <value-of select="$sumTotalVatAmount_1"/>. \n
			Expected value for MOA+150:  <value-of select="$ruleA"/>
			</report> 
		</rule>
	</pattern>

	<!-- Rule I test --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC[G_SG50/S_MOA/C_C516/D_5025 = '77']">
			<let name="actualSegment" value="./G_SG50/S_MOA[C_C516/D_5025 = '77']"/>

			<!-- Total taxable Amount -->
			<let name="totalTaxableAmount_27" value="number(./G_SG50/S_MOA[C_C516/D_5025 = '79']/C_C516/D_5004)"/>	
			<!-- Invoice (Total) VAT Amount -->
			<let name="invoiceVatAmount_2" value="number(./G_SG50/S_MOA[C_C516/D_5025 = '150']/C_C516/D_5004)"/>	
			<!-- Expected result: Total Invoiced Amount -->
			<let name="totalInvoicAmount_17" value="number(./G_SG50/S_MOA[C_C516/D_5025 = '77']/C_C516/D_5004)"/>
			<!-- Result from rule F -->
			<let name="ruleI" value="round(number($totalTaxableAmount_27 + $invoiceVatAmount_2) * 10000 ) div 10000"/>

			<!-- Rule I - Check that ruleI = invoiceVatAmount_2 + totalTaxableAmount_27 -->
			<report test="($ruleI != $totalInvoicAmount_17) and string($totalInvoicAmount_17) != 'NaN'">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[UNS] - RULE I error: #83 MOA+77 = (#83 MOA+79) + (#83 MOA+150). \n
			Actual value for MOA+77: <value-of select="$totalInvoicAmount_17"/> != <value-of select="$totalTaxableAmount_27"/> + <value-of select="$invoiceVatAmount_2"/>. \n
			Expected value for MOA+77:  <value-of select="$ruleI"/>
			</report> 
		</rule>
	</pattern>

	<!-- Rule J test --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC[G_SG50/S_MOA/C_C516/D_5025 = '9']">
			<let name="actualSegment" value="./G_SG50/S_MOA[C_C516/D_5025 = '9']"/>

			<!-- Total Invoiced Amount -->
			<let name="totalInvoicAmount_17" value="number(./G_SG50/S_MOA[C_C516/D_5025 = '77']/C_C516/D_5004)"/>
			<!-- Prepaid Amount -->
			<let name="prepaidAmount_18" value="number(./G_SG50/S_MOA[C_C516/D_5025 = '113']/C_C516/D_5004)"/>	
			<!-- Expected result: Amount to be Paid -->
			<let name="amountToBePaid_19" value="number(./G_SG50/S_MOA[C_C516/D_5025 = '9']/C_C516/D_5004)"/>
			<!-- Result from rule F -->
			<let name="ruleJ" value="number($totalInvoicAmount_17 - $prepaidAmount_18)"/>

			<!-- Rule I - Check that ruleI = totalInvoicAmount_17 - prepaidAmount_18 -->
			<report test="($ruleJ != $amountToBePaid_19)">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>}
			[UNS] - RULE J error: #83 MOA+9 = (#83 MOA+77) - (#83 MOA+113). \n
			Actual value for MOA+9: <value-of select="$amountToBePaid_19"/> != <value-of select="$totalInvoicAmount_17"/> - <value-of select="$prepaidAmount_18"/>. \n
			Expected value for MOA+9:  <value-of select="$ruleJ"/>
			</report> 
		</rule>
	</pattern>

	<!-- Rule G test --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26[G_SG27/S_MOA/C_C516/D_5025 = '496']">
			<let name="actualSegment" value="./S_LIN"/>

			<!-- Quantity deposit units - Chargeable -->
			<let name="quantityDepositUnit_24a" value="number(./S_QTY[C_C186/D_6063 = '47']/C_C186/D_6060)"/>
			<!-- Quantity deposit units - Returned -->
			<let name="quantityDepositUnit_24b" value="number(./S_QTY[C_C186/D_6063 = '61']/C_C186/D_6060)"/>
			<!-- Deposit net price -->
			<let name="depositNetPrice_16" value="number(./G_SG29/S_PRI[C_C509/D_5125 = 'AAA']/C_C509/D_5118)"/>	
			<!-- Expected result: Total returnable packages deposit amount -->
			<let name="totalReturnablePackageDepositAmount_26" value="number(./G_SG27/S_MOA[C_C516/D_5025 = '496']/C_C516/D_5004)"/>
			<!-- Result from rule G -->
			<let name="ruleG_a" value="number($quantityDepositUnit_24a * $depositNetPrice_16)"/>
			<let name="ruleG_b" value="number($quantityDepositUnit_24b * $depositNetPrice_16)"/>

			<!-- Rule G - RTI return check on Line Level -->
			<report test="($ruleG_a != $totalReturnablePackageDepositAmount_26) and exists(./S_QTY[C_C186/D_6063 = '47']/C_C186/D_6060)">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>} 
			[UNS] - RULE G error: #54 MOA+496 = (#54 PRI+AAA) * (#43 QTY+47). \n
			Actual value for MOA+496 on LIN+<value-of select="./S_LIN/D_1082"/>: <value-of select="$totalReturnablePackageDepositAmount_26"/> != <value-of select="$quantityDepositUnit_24a"/> * <value-of select="$depositNetPrice_16"/>. \n
			Expected value for MOA+496 on LIN+<value-of select="./S_LIN/D_1082"/>:  <value-of select="$ruleG_a"/>
			</report> 

			<!-- Rule G - RTI return check on Line Level -->
			<report test="($ruleG_b != $totalReturnablePackageDepositAmount_26) and exists(./S_QTY[C_C186/D_6063 = '61']/C_C186/D_6060)">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>} 
			[UNS] - RULE G error: #54 MOA+496 = (#54 PRI+AAA) * (#43 QTY+61). \n
			Actual value for MOA+496 on LIN+<value-of select="./S_LIN/D_1082"/>: <value-of select="$totalReturnablePackageDepositAmount_26"/> != <value-of select="$quantityDepositUnit_24b"/> * <value-of select="$depositNetPrice_16"/>. \n
			Expected value for MOA+496 on LIN+<value-of select="./S_LIN/D_1082"/>:  <value-of select="$ruleG_b"/>
			</report> 
		</rule>
	</pattern>

	<!-- Rule H test --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC[G_SG50/S_MOA/C_C516/D_5025 = '79']">
			<let name="actualSegment" value="./G_SG50/S_MOA[C_C516/D_5025 = '79']"/>

			<!-- Taxable basis amount excluding payment discout => Compared with ruleE -->
			<let name="taxBasisAmountExclPD_3" value="number(if (exists(./G_SG52/S_MOA[C_C516/D_5025 = '04G']/C_C516/D_5004)) then (sum($inv/G_SG52/S_MOA[C_C516/D_5025 = '04G']/C_C516/D_5004)) else ('0'))"/>
			<!-- Total returnable packages deposit amount chargeable -->
			<let name="sumTotalReturnablePackageDepositAmount_26a" value="number(sum(./G_SG26[not(S_QTY/C_C186/D_6063 = '61')]/G_SG27/S_MOA[C_C516/D_5025 = '496']/C_C516/D_5004))"/>
			<!-- Total returnable packages deposit amount returned -->
			<let name="sumTotalReturnablePackageDepositAmount_26b" value="number(sum(./G_SG26[S_QTY/C_C186/D_6063 = '61']/G_SG27/S_MOA[C_C516/D_5025 = '496']/C_C516/D_5004))"/>
			<!-- Expected result: Total Taxable Amount -->
			<let name="totalTaxableAmount_79" value="number(./G_SG50/S_MOA[C_C516/D_5025 = '79']/C_C516/D_5004)"/>
			<!-- Result from rule H -->
			<let name="ruleH" value="abs(number($taxBasisAmountExclPD_3 + $sumTotalReturnablePackageDepositAmount_26a - $sumTotalReturnablePackageDepositAmount_26b))"/>

			<!-- Rule H - RTI return check on Line Level -->
			<report test="($ruleH != $totalTaxableAmount_79)">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>} 
			[UNS] - RULE H error: #83 MOA+79 = SUM(#87 MOA+04G) + (#83 MOA+496). \n
			Actual value for MOA+79: <value-of select="$totalTaxableAmount_79"/> != <value-of select="$taxBasisAmountExclPD_3"/> + <value-of select="$sumTotalReturnablePackageDepositAmount_26a"/> - <value-of select="$sumTotalReturnablePackageDepositAmount_26b"/>. \n
			Expected value for MOA+79: <value-of select="$ruleH"/>
			</report> 

		</rule>
	</pattern>

	<!-- Rule K test --> 
	<!-- Apply this rule only if there is no free goods -->
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26[not(S_QTY/C_C186/D_6063 = '61')]">
			<let name="actualSegment" value="./S_LIN[last()]"/>

			<!-- Delivered Quantity -->
			<let name="deliveredQuantity_21" value="number(
				if (exists(./S_QTY[C_C186/D_6063 = '46' and exists(C_C186/D_6411)])) then
					(./S_QTY[C_C186/D_6063 = '46' and exists(C_C186/D_6411)]/C_C186/D_6060) else 
					(./S_QTY[C_C186/D_6063 = '46']/C_C186/D_6060)
				)"/>
			<!-- Total returnable packages deposit amount chargeable -->
			<let name="unitOfMeasure_22" value="number(if (exists(./S_MEA/C_C174/D_6314)) then (./S_MEA/C_C174/D_6314) else ('1'))"/>
			<!-- Free goods -->
			<let name="freeGoodsQuantity_23" value="number(
				if (exists(./S_QTY[C_C186/D_6063 = '192' and exists(C_C186/D_6411)])) then
					(./S_QTY[C_C186/D_6063 = '192' and exists(C_C186/D_6411)]/C_C186/D_6060) else 
					if (exists(./S_QTY[C_C186/D_6063 = '192']/C_C186/D_6060)) then 
					(./S_QTY[C_C186/D_6063 = '192']/C_C186/D_6060) else ('0')
				)"/>
			<!-- Invoiced quantity -->
			<let name="invoicedQuantity_10" value="number(
				if (exists(./S_QTY[C_C186/D_6063 = '47' and exists(C_C186/D_6411)])) then
					(./S_QTY[C_C186/D_6063 = '47' and exists(C_C186/D_6411)]/C_C186/D_6060) else 
					(./S_QTY[C_C186/D_6063 = '47']/C_C186/D_6060)
				)"/>
			<!-- Result from rule K -->
			<let name="ruleK" value="number($deliveredQuantity_21 * $unitOfMeasure_22)"/>
			<!-- Result from rule L -->
			<let name="ruleL" value="number($deliveredQuantity_21 * $unitOfMeasure_22) - $freeGoodsQuantity_23"/>

			<!-- Rule K - check when MEA present -->
			<report test="($ruleK != $invoicedQuantity_10 and exists(./S_MEA/C_C174/D_6314))">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>} 
			[QTY] - RULE K error on LIN+<value-of select="./S_LIN/D_1082"/>: #43 QTY+47 = #43 QTY+47 * #42 MEA+ABW. \n
			Actual value for QTY+47: <value-of select="$invoicedQuantity_10"/> != <value-of select="$deliveredQuantity_21"/> * <value-of select="$unitOfMeasure_22"/>. \n
			Expected value for QTY+47: <value-of select="$ruleK"/>
			</report> 

			<!-- Rule L -->
			<report test="$ruleL != $invoicedQuantity_10 and string($invoicedQuantity_10) != 'NaN'  and string($deliveredQuantity_21) != 'NaN'">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>} 
			[QTY] - RULE L error on LIN+<value-of select="./S_LIN/D_1082"/>: #43 QTY+47 = (#43 QTY+47 * #42 MEA+ABW) - #43 QTY+192 \n
			Actual value for QTY+47: <value-of select="$invoicedQuantity_10"/> != <value-of select="$deliveredQuantity_21"/> * <value-of select="$unitOfMeasure_22"/> - <value-of select="$freeGoodsQuantity_23"/> . \n
			Expected value for QTY+47: <value-of select="$ruleL"/>
			</report>

		</rule>
	</pattern>

	<!-- Rule L test --> 
	<pattern>
		<rule context="/INTERCHANGE/M_INVOIC/G_SG26[S_QTY/C_C186/D_6063 = '192']">
			<let name="actualSegment" value="./S_LIN[last()]"/>

			<!-- Delivered Quantity -->
			<let name="deliveredQuantity_21" value="number(./S_QTY[C_C186/D_6063 = '46']/C_C186/D_6060)"/>
			<!-- Total returnable packages deposit amount chargeable -->
			<let name="unitOfMeasure_22" value="number(if (exists(./S_MEA/C_C174/D_6314)) then (./S_MEA/C_C174/D_6314) else ('1'))"/>
			<!-- Free goods -->
			<let name="freeGoodsQuantity_23" value="number(./S_QTY[C_C186/D_6063 = '192']/C_C186/D_6060)"/>
			<!-- Invoiced quantity -->
			<let name="invoicedQuantity_10" value="number(./S_QTY[(C_C186/D_6063 = '47' or C_C186/D_6063 = '61') and exists(C_C186/D_6411)]/C_C186/D_6060)"/>
			<!-- Result from rule L -->
			<let name="ruleL" value="number($deliveredQuantity_21 * $unitOfMeasure_22) - $freeGoodsQuantity_23"/>

			<!-- Rule L - check when MEA present 
			<report test="$ruleL != $invoicedQuantity_10">
			{<value-of select="f:getEdifactPosition($actualSegment)"/>} 
			[QTY] - RULE L error on LIN+<value-of select="./S_LIN/D_1082"/>: #43 QTY+47 = (#43 QTY+47 * #42 MEA+ABW) - #43 QTY+192 \n
			Actual value for QTY+47: <value-of select="$invoicedQuantity_10"/> != <value-of select="$unitOfMeasure_22"/> * <value-of select="$unitOfMeasure_22"/> - <value-of select="$freeGoodsQuantity_23"/> . \n
			Expected value for QTY+47: <value-of select="$ruleL"/>
			</report> -->

		</rule>
	</pattern>



	<!-- XSLT function - getRuleF
	Definition: Provide the expected result of the Rule F, for a received Line.
    @param: G_SG26, is the Node we want to test
    @result: A decimal, result of the RULE F calculation
  -->
	<xsl:function name="f:getRuleF" as="xs:decimal">
		<xsl:param name="G_SG26" as="node()"/>

		<!-- Get the quantity invoiced or the returned quantity -->
		<xsl:variable name="invoicedQuantity_10" select="number($G_SG26/S_QTY[C_C186/D_6063 = '47' or C_C186/D_6063 = '61']/C_C186/D_6060)"/>
		<!-- Multiply factor for the Price-->
		<xsl:variable name="calcGrossPriceMult_9" select="number(if (exists($G_SG26/S_MEA/C_C174/D_6314) and $G_SG26/S_MEA/C_C174/D_6411 = $G_SG26/S_QTY[C_C186/D_6063 = '47']/C_C186/D_6411) then ($G_SG26/S_MEA/C_C174/D_6314) else ('1'))"/>
		<xsl:variable name="calcGrossPriceUnit_11" select="number($G_SG26/G_SG29/S_PRI[C_C509/D_5125 = 'AAB']/C_C509/D_5118) * $calcGrossPriceMult_9"/>
		<!-- Charge Amount by line -->
		<xsl:variable name="sumChargeAmountLine_13" select="number(if (exists($G_SG26/G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '23']/C_C516/D_5004)) then (sum($G_SG26/G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '23']/C_C516/D_5004)) else ('0'))"/>
		<!-- Allowance amount by line -->
		<xsl:variable name="sumAllowanceAmountLine_14" select="number(if (exists($G_SG26/G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '204']/C_C516/D_5004)) then (sum($G_SG26/G_SG39/G_SG44/S_MOA[C_C516/D_5025 = '204']/C_C516/D_5004)) else ('0'))"/>
		<!-- Expected result: Line taxable amount -->
		<xsl:variable name="lineTaxableAmount_12" select="number(sum($G_SG26/G_SG34/S_MOA[C_C516/D_5025 = '125']/C_C516/D_5004))"/>
		<!-- Rule F result-->
		<xsl:variable name="ruleF" select="$invoicedQuantity_10 * $calcGrossPriceUnit_11 + $sumChargeAmountLine_13 - $sumAllowanceAmountLine_14"/>

		<xsl:value-of select="$ruleF"/>
	</xsl:function>

	<!-- XSLT function - getEdifactPosition
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
