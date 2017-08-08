<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<!DOCTYPE tvdxtat [
	<!ENTITY border "0">                               <!-- border for table -->
	<!ENTITY cellspacing "1">                          <!-- cellspacing for table -->
	<!ENTITY cellpadding "1">                          <!-- cellpadding for table -->
	<!ENTITY trnc "<tr class='no_color'><td/></tr>">   <!-- table row separator -->
	<!ENTITY hsc "<th class='color'/>">                <!-- table header separator -->
	<!ENTITY dsc "<td class='color'/>">                <!-- table data separator -->
	<!ENTITY hsnc "<th class='no_color'/>">            <!-- table header separator -->
	<!ENTITY dsnc "<td class='no_color'/>">            <!-- table data separator -->
	<!ENTITY ff "'###,###,###,###,##0.000'">           <!-- float format -->
	<!ENTITY if "'###,###,###,###,###,##0'">           <!-- integer format -->
]>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html" encoding="UTF-8"/>

<!--  M A I N  -->

<xsl:template match="/tvdxtat">
	<xsl:text disable-output-escaping="yes"><![CDATA[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">]]></xsl:text>
	<html>
		<head>
			<title>TVD$XTAT Output</title>
			<style type="text/css">
				body { background-color: rgb(246,246,246); }
				h1 { color: rgb(0,51,102); font-family: helvetica; font-size: 15pt; font-weight: bold; }
				h2 { color: rgb(0,51,102); font-family: helvetica; font-size: 13pt; font-weight: bold; }
				h3 { color: rgb(0,51,102); font-family: helvetica; font-size: 11pt; font-weight: bold; }
				p { color: rgb(0,51,102); font-family: helvetica; font-size: 10pt; font-weight: normal; }
				a { color: rgb(0,51,102); font-family: helvetica; font-size: 10pt; font-weight: normal; }
				a.th { color: rgb(246,246,246); background-color: rgb(102,102,102); font-family: helvetica; font-size: 10pt; font-weight: bold; }
				p.error { color: rgb(255,0,0); font-family: helvetica; font-size: 10pt; font-weight: normal; }
				th.color { color: rgb(246,246,246); background-color: rgb(102,102,102); font-family: helvetica; font-size: 10pt; font-weight: bold; }
				th.no_color { color: rgb(0,51,102); font-family: helvetica; font-size: 10pt; font-weight: bold; }
				td.color { color: rgb(0,51,102); background-color: rgb(255,225,225); font-family: helvetica; font-size: 10pt; font-weight: normal; }
				td.color_pre { color: rgb(0,51,102); background-color: rgb(255,225,225); font-family: helvetica; font-size: 10pt; font-weight: normal; white-space: pre }
				td.no_color { color: rgb(0,51,102); font-family: helvetica; font-size: 10pt; font-weight: normal; }
				td.no_color_pre { color: rgb(0,51,102); font-family: helvetica; font-size: 10pt; font-weight: normal; white-space: pre }
			</style>
		</head>
		<body>
			<table>
				<tr>
					<td class="title" colspan="2" width="100%">
						<h1><xsl:value-of select="header/version"/></h1>
					</td>
				</tr>
				<tr>
					<td class="no_color" valign="top" width="50%">
						<xsl:variable name="email" select="header/author/email"/>
						<a href='mailto:{$email}'><xsl:value-of select="header/copyright"/></a>
					</td>
					<td class="no_color" valign="top" width="50%">
						<a href='http://www.trivadis.com'>Trivadis AG</a>
						<br/>Europa-Strasse 5
						<br/>CH-8152 Glattbrugg / Zürich
					</td>
				</tr>
			</table>
			<h1><a name="top"></a>Overall Information</h1>
			<xsl:apply-templates select="database"/>
			<xsl:apply-templates select="tracefiles"/>
			<xsl:apply-templates select="period"/>
			<xsl:apply-templates select="transactions"/>
			<xsl:apply-templates select="profile"/>
			<xsl:call-template name="cursors0"/>
			<xsl:apply-templates select="profile/event"/>
			<xsl:for-each select="cursors/cursor">
				<p><br/></p>
				<hr/>
				<xsl:variable name="id" select="@id"/>
				<h1><a name="{$id}"></a>Statement <xsl:value-of select="$id"/>&#160;&#160;<a href="#top">overall</a></h1>
				<xsl:call-template name="cursor_detail"/>
			</xsl:for-each>
			<p><br/></p>
			<hr/>
			<h1><a name="units"></a>Units of Measure&#160;&#160;<a href="#top">overall</a></h1>
			<p>
				[s] = seconds
				<br/>[&#956;s] = microseconds
				<br/>[b] = database blocks
			<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
			<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
			<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
			</p>
		</body>
	</html>
</xsl:template>

<xsl:template match="database">
	<xsl:if test="line">
		<h2>Database Version</h2>
		<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
			<xsl:for-each select="line">
				<tr valign="top">
					<td class="no_color" align="left"><xsl:value-of select="text()"/></td>
				</tr>
			</xsl:for-each>
		</table>
	</xsl:if>
</xsl:template>
  
<xsl:template match="tracefiles">
	<xsl:if test="tracefile">
		<xsl:choose>
			<xsl:when test="count(tracefile)=1">
				<h2>Analyzed Trace File</h2>
			</xsl:when>
			<xsl:otherwise>
				<h2>Analyzed Trace Files</h2>
			</xsl:otherwise>
		</xsl:choose>
		<p>
			<xsl:for-each select="tracefile/name">
				<xsl:value-of select="text()"/><br/>
			</xsl:for-each>
		</p>
	</xsl:if>
</xsl:template>

<xsl:template match="period">
	<h2>Interval</h2>
	<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
		<xsl:if test="begin">
			<tr valign="top">
				<td class="no_color" align="left">Beginning</td>
				<td class="no_color" align="left"><xsl:value-of select="begin"/></td>
			</tr>
			<tr valign="top">
				<td class="no_color" align="left">End</td>
				<td class="no_color" align="left"><xsl:value-of select="end"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="duration">
			<tr valign="top">
				<td class="no_color" align="left">Duration</td>
				<td class="no_color" align="left"><xsl:value-of select="format-number(duration div 1000000,&ff;)"/>&#160;<a href="#units">[s]</a></td>
			</tr>
		</xsl:if>
	</table>
	<xsl:for-each select="warning">
		<p class="error">WARNING: <xsl:value-of select="text()"/></p>
	</xsl:for-each>
</xsl:template>
  
<xsl:template match="transactions">
	<h2>Transactions</h2>
	<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
		<tr valign="top">
			<td class="no_color" align="left">Committed</td>
			<td class="no_color" align="left"><xsl:value-of select="format-number(commit,&if;)"/></td>
		</tr>
		<tr valign="top">
			<td class="no_color" align="left">Rollbacked</td>
			<td class="no_color" align="left"><xsl:value-of select="format-number(rollback,&if;)"/></td>
		</tr>
	</table>
</xsl:template>

<xsl:template match="profile">
	<xsl:variable name="id" select="../@id"/>
	<xsl:variable name="totalElapsed" select="@total_elapsed"/>				
	<h2>Resource Usage Profile&#160;&#160;<a href="#top">overall</a>&#160;<a href="#{$id}">current</a></h2>
	<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
		<tr valign="top">
			<th class="color" align="left">Component</th>
			&hsnc;
			<th class="color" align="right">Total Duration <a class="th" href="#units">[s]</a></th>
			&hsnc;
			<th class="color" align="right">%</th>
			&hsnc;
			<th class="color" align="right">Number of Events</th>
			&hsnc;
			<th class="color" align="right">Duration per Event <a class="th" href="#units">[s]</a></th>
		</tr>
		&trnc;
		<xsl:for-each select="event">
			<xsl:variable name="name" select="@name"/>
			<tr valign="top">
				<td class="color" align="left">
					<xsl:choose>
						<xsl:when test="histogram or contributors">
							<a href="#{$name}-{$id}"><xsl:value-of select="$name"/></a>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$name"/>
						</xsl:otherwise>
					</xsl:choose>
				</td>
				&dsnc;
				<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
				&dsnc;
				<td class="color" align="right">
					<xsl:choose>
						<xsl:when test="$totalElapsed > 0">
							<xsl:value-of select="format-number(@elapsed div $totalElapsed * 100, &ff;)"/>
						</xsl:when>
						<xsl:otherwise>
							n/a
						</xsl:otherwise>
					</xsl:choose>
				</td>
				&dsnc;
				<td class="color" align="right">
					<xsl:choose>
	 					<xsl:when test="@count">
							<xsl:value-of select="format-number(@count,&if;)"/>
						</xsl:when>
						<xsl:otherwise>
							n/a
						</xsl:otherwise>
					</xsl:choose>
				</td>
				&dsnc;
				<td class="color" align="right">
					<xsl:choose>
						<xsl:when test="@count">
							<xsl:value-of select="format-number(@elapsed div 1000000 div @count,&ff;)"/>
						</xsl:when>
						<xsl:otherwise>
							n/a
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</xsl:for-each>
		<xsl:if test="count(event)>1">
			&trnc;
			<tr>
				<td class="color" align="left">Total</td>
				&dsnc;
				<td class="color" align="right"><xsl:value-of select="format-number($totalElapsed div 1000000,&ff;)"/></td>
				&dsnc;
				<td class="color" align="right">
					<xsl:choose>
						<xsl:when test="@total_elapsed > 0">
							<xsl:value-of select="format-number(100,&ff;)"/>
						</xsl:when>
						<xsl:otherwise>
							n/a
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</xsl:if>
	</table>
	<!-- only true for the profile at statement level -->
	<xsl:if test="../children/cursor">
		<p>
			<xsl:choose>
				<xsl:when test="../children/@count = 1">
					1 recursive statement was executed.
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../children/@count"/> recursive statements were executed.
				</xsl:otherwise>
			</xsl:choose>
			<br/>
			<xsl:if test="../children/@count > ../children/@limit">
				In the following table, only the top <xsl:value-of select="../children/@limit"/> recursive statements are reported.
			</xsl:if>
		</p>
		<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
			<tr valign="top">
				<th class="color" align="left">Statement ID</th>
				&hsnc;
				<th class="color" align="left">Type</th>
				&hsnc;
				<th class="color" align="right">Total Duration <a class="th" href="#units">[s]</a></th>
				&hsnc;
				<th class="color" align="right">%</th>
			</tr>
			&trnc;
			<xsl:for-each select="../children/cursor">
				<tr>
					<td class="color" align="left"><xsl:call-template name="anchor4cursor"/></td>
					&dsnc;
					<td class="color" align="left"><xsl:call-template name="cursortype"/></td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalElapsed > 0">  
								<xsl:value-of select="format-number(@elapsed div $totalElapsed * 100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:for-each>
			<xsl:if test="../children/@count > 1">
				&trnc;
				<tr>
					<td class="color" align="left">Total</td>
					&dsnc;
					<td class="color" align="left"/>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number(../children/@elapsed div 1000000,&ff;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalElapsed > 0">  
								<xsl:value-of select="format-number(../children/@elapsed div $totalElapsed * 100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:if>
		</table>    
	</xsl:if>
</xsl:template>

<xsl:template name="cursors0">
	<xsl:variable name="totalElapsed" select="profile/@total_elapsed"/>				
	<xsl:variable name="sumElapsed" select="sum(profile/contributors/cursor/@elapsed)"/>
	<p>
		The input file contains <xsl:value-of select="profile/contributors/@count"/> distinct statements, 
		<xsl:choose>
			<xsl:when test="profile/contributors/@count_recursive = 1">
				<xsl:value-of select="profile/contributors/@count_recursive"/> of which is recursive.
			</xsl:when>
			<xsl:when test="profile/contributors/@count_recursive > 1">
				<xsl:value-of select="profile/contributors/@count_recursive"/> of which are recursive.
			</xsl:when>
			<xsl:otherwise>
				no one is resursive.
			</xsl:otherwise>
		</xsl:choose>
    </p>
	<xsl:if test="profile/contributors/cursor">
	    <p>
			In the following table, only
			<xsl:if test="profile/contributors/@count - profile/contributors/@count_recursive > profile/contributors/@limit">
				the top 
				<xsl:value-of select="profile/contributors/@limit"/>
			</xsl:if>
			non-recursive statements are reported.
		</p>
		<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
			<tr valign="top">
				<th class="color" align="left">Statement ID</th>
				&hsnc;
				<th class="color" align="left">Type</th>
				&hsnc;
				<th class="color" align="right">Total Duration <a class="th" href="#units">[s]</a></th>
				&hsnc;
				<th class="color" align="right">%</th>
				&hsnc;
				<th class="color" align="right">Number of Executions</th>
				&hsnc;
				<th class="color" align="right">Duration per Execution <a class="th" href="#units">[s]</a></th>
			</tr>
			&trnc;
			<xsl:for-each select="profile/contributors/cursor">
				<tr valign="top">
					<td class="color" align="left">
						<xsl:call-template name="anchor4cursor"/>
					</td>
					&dsnc;
					<td class="color" align="left"><xsl:call-template name="cursortype"/></td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="@elapsed > 0">  
								<xsl:value-of select="format-number(@elapsed div $totalElapsed * 100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="format-number(0,&ff;)"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number(@count,&if;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="@count > 0">  
								<xsl:value-of select="format-number(@elapsed div 1000000 div @count,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:for-each>
			&trnc;
			<tr valign="top">
				<td class="color" align="left">Total</td>
				&dsnc;
				<td class="color" align="left"/>
				&dsnc;
				<td class="color" align="right"><xsl:value-of select="format-number($sumElapsed div 1000000,&ff;)"/></td>
				&dsnc;
				<td class="color" align="right">
					<xsl:choose>
						<xsl:when test="$sumElapsed > 0">  
							<xsl:value-of select="format-number($sumElapsed div $totalElapsed * 100,&ff;)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="format-number(0,&ff;)"/>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</table>
	</xsl:if>
</xsl:template>

<xsl:template match="profile/event">
	<xsl:variable name="id" select="../../@id"/>
	<xsl:variable name="name" select="@name"/>
	<xsl:variable name="totalElapsed" select="@elapsed"/>
	<xsl:variable name="sumElapsed" select="sum(contributors/cursor/@elapsed)"/>
	<xsl:variable name="totalCount" select="@count"/>
	<xsl:variable name="totalBlocks" select="@blocks"/>
	<xsl:if test="histogram or contributors">
		<h2><a name="{$name}-{$id}"></a><xsl:value-of select="$name"/>&#160;&#160;
		<a href="#top">overall</a><xsl:if test="../../@id">&#160;<a href="#{$id}">current</a></xsl:if>
		</h2>
	</xsl:if>
	<xsl:if test="histogram">
		<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
			<tr valign="top">
				<th class="color" align="left">Range <a class="th" href="#units">[&#956;s]</a></th>
				&hsnc;
				<th class="color" align="right">Total Duration <a class="th" href="#units">[s]</a></th>
				&hsnc;
				<th class="color" align="right">%</th>
				&hsnc;
				<th class="color" align="right">Number of Events</th>
				&hsnc;
				<th class="color" align="right">%</th>
				&hsnc;
				<th class="color" align="right">Duration per Event <a class="th" href="#units">[&#956;s]</a></th>
				<xsl:if test="$totalBlocks>0">
					&hsnc;
      	      <th class="color" align="right">Blocks <a class="th" href="#units">[b]</a></th>
					&hsnc;
					<th class="color" align="right">Blocks per Event <a class="th" href="#units">[b]</a></th>
				</xsl:if>
			</tr>
			&trnc;
			<xsl:for-each select="histogram/bucket">
				<tr>
					<td class="color" align="center"><xsl:value-of select="@range"/></td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalElapsed > 0">
								<xsl:value-of select="format-number(@elapsed div $totalElapsed * 100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number(@count,&if;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalCount > 0">
								<xsl:value-of select="format-number(@count div $totalCount * 100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="@count > 0">
								<xsl:value-of select="format-number(@elapsed div @count,&if;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<xsl:if test="$totalBlocks>0">
						&hsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@blocks,&if;)"/></td>
						&hsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@blocks div @count,&ff;)"/></td>
					</xsl:if>
				</tr>
			</xsl:for-each>
			<xsl:if test="count(histogram/bucket)>1">
				&trnc;
				<tr>
					<td class="color" align="left">Total</td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number($totalElapsed div 1000000,&ff;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalElapsed > 0">  
								<xsl:value-of select="format-number(100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number($totalCount,&if;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalCount > 0">  
								<xsl:value-of select="format-number(100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number($totalElapsed div $totalCount,&if;)"/></td>
					<xsl:if test="$totalBlocks>0">
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number($totalBlocks,&if;)"/></td>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number($totalBlocks div $totalCount,&ff;)"/></td>
					</xsl:if>
				</tr>
			</xsl:if>
		</table>
		<p/>
		<xsl:if test="distribution">
			<xsl:variable name="totalDistributionBlocks" select="sum(distribution/bucket/@blocks)"/>
			<xsl:variable name="totalDistributionCount" select="sum(distribution/bucket/@count)"/>
			<xsl:variable name="totalDistributionElapsed" select="sum(distribution/bucket/@elapsed)"/>
			<p>
				<xsl:if test="distribution/@count > distribution/@limit">
					In total there are <xsl:value-of select="distribution/@count"/> entries.
					In the following table, only the top <xsl:value-of select="distribution/@limit"/> entries are reported.
				</xsl:if>
			</p>
			<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
				<tr valign="top">
					<xsl:if test="distribution/bucket[1]/@file">
						<th class="color" align="left">File</th>
					</xsl:if>
					<xsl:if test="distribution/bucket[1]/@block">
						&hsnc;
						<th class="color" align="left">Block Number</th>
					</xsl:if>
					&hsnc;
					<th class="color" align="right">Total Duration <a class="th" href="#units">[s]</a></th>
					<xsl:if test="$totalDistributionElapsed>0">
						&hsnc;
						<th class="color" align="right">%</th>
					</xsl:if>
					<xsl:if test="distribution/bucket[1]/@count">
						&hsnc;
						<th class="color" align="right">Number of Events</th>
						<xsl:if test="$totalDistributionCount>0">
							&hsnc;
							<th class="color" align="right">%</th>
						</xsl:if>
					</xsl:if>
					<xsl:if test="distribution/bucket[1]/@blocks">
						&hsnc;
						<th class="color" align="right">Blocks <a class="th" href="#units">[b]</a></th>
						<xsl:if test="$totalDistributionBlocks>0">
							&hsnc;
							<th class="color" align="right">%</th>
						</xsl:if>
					</xsl:if>
					&hsnc;
					<th class="color" align="right">Duration per Event <a class="th" href="#units">[&#956;s]</a></th>
					<xsl:if test="distribution/bucket[1]/@reason">
						&hsnc;
						<th class="color" align="left">Class/Reason</th>
					</xsl:if>
				</tr>
				&trnc;
				<xsl:for-each select="distribution/bucket">
					<tr valign="top">
						<xsl:if test="../bucket[1]/@file">
							<td class="color" align="left"><xsl:value-of select="@file"/></td>
						</xsl:if>
						<xsl:if test="../bucket[1]/@block">
							&dsnc;
							<td class="color" align="left"><xsl:value-of select="format-number(@block,&if;)"/></td>
						</xsl:if>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
						<xsl:if test="$totalDistributionElapsed>0">
							&dsnc;
							<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div $totalDistributionElapsed * 100,&ff;)"/></td>
						</xsl:if>
						<xsl:if test="../bucket[1]/@count">
							&dsnc;
							<td class="color" align="right"><xsl:value-of select="format-number(@count,&if;)"/></td>
							<xsl:if test="$totalDistributionCount>0">
								&hsnc;
								<td class="color" align="right"><xsl:value-of select="format-number(@count div $totalDistributionCount * 100,&ff;)"/></td>
							</xsl:if>
						</xsl:if>
						<xsl:if test="../bucket[1]/@blocks">
							&dsnc;
							<td class="color" align="right"><xsl:value-of select="format-number(@blocks,&if;)"/></td>
							<xsl:if test="$totalDistributionBlocks>0">
								&hsnc;
								<td class="color" align="right"><xsl:value-of select="format-number(@blocks div $totalDistributionBlocks * 100,&ff;)"/></td>
							</xsl:if>
						</xsl:if>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div @count,&if;)"/></td>
						<xsl:if test="../bucket[1]//@reason">
							&dsnc;
							<td class="color" align="left"><xsl:value-of select="@reason"/></td>
						</xsl:if>
					</tr>
				</xsl:for-each>
				<xsl:if test="count(distribution/bucket)>1">
					&trnc;
					<tr valign="top">
						<xsl:if test="distribution/bucket[1]/@file">
							<td class="color" align="left">Total</td>
						</xsl:if>
						<xsl:if test="distribution/bucket[1]/@block">
							&hsnc;
							<td class="color" align="right"></td>
						</xsl:if>
						&hsnc;
						<td class="color" align="right"><xsl:value-of select="format-number($totalDistributionElapsed div 1000000,&ff;)"/></td>
						<xsl:if test="$totalDistributionElapsed>0">
							&hsnc;
							<td class="color" align="right"><xsl:value-of select="format-number(100,&ff;)"/></td>
						</xsl:if>
						<xsl:if test="distribution/bucket[1]/@count">
							&hsnc;
							<td class="color" align="right"><xsl:value-of select="format-number($totalDistributionCount,&if;)"/></td>
							<xsl:if test="$totalDistributionCount>0">
								&hsnc;
								<td class="color" align="right"><xsl:value-of select="format-number(100,&ff;)"/></td>
							</xsl:if>
						</xsl:if>
						<xsl:if test="distribution/bucket[1]/@blocks">
							&hsnc;
							<td class="color" align="right"><xsl:value-of select="format-number($totalDistributionBlocks,&if;)"/></td>
							<xsl:if test="$totalDistributionBlocks>0">
								&hsnc;
								<td class="color" align="right"><xsl:value-of select="format-number(100,&ff;)"/></td>
							</xsl:if>
						</xsl:if>
						&hsnc;
						<td class="color" align="right"><xsl:value-of select="format-number($totalDistributionElapsed div $totalDistributionCount,&if;)"/></td>
					</tr>
				</xsl:if>
			</table>
		</xsl:if>
	</xsl:if>
	<xsl:if test="contributors">
		<p>
			<xsl:choose>
				<xsl:when test="contributors/@count = 1"> 
					1 statement contributed to this event.
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="contributors/@count"/> statements contributed to this event.
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="contributors/@count > contributors/@limit">
				In the following table, only the top <xsl:value-of select="contributors/@limit"/> contributors are reported.
			</xsl:if>
		</p>
		<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
			<tr valign="top">
				<th class="color" align="left">Statement ID</th>
				&hsnc;
				<th class="color" align="left">Type</th>
				&hsnc;
				<th class="color" align="right">Total Duration <a class="th" href="#units">[s]</a></th>
				&hsnc;
				<th class="color" align="right">%</th>
			</tr>
			&trnc;
			<xsl:for-each select="contributors/cursor">
				<tr>
					<td class="color" align="left">
						<xsl:call-template name="anchor4cursor"/>
					</td>
					&dsnc;
					<td class="color" align="left">
						<xsl:call-template name="cursortype"/>               
					</td>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalElapsed > 0">  
								<xsl:value-of select="format-number(@elapsed div $totalElapsed * 100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:for-each>
			<xsl:if test="contributors/@count > 1">
				&trnc;
				<tr>
					<td class="color" align="left">Total</td>
					&dsnc;
					<td class="color" align="left"/>
					&dsnc;
					<td class="color" align="right"><xsl:value-of select="format-number($sumElapsed div 1000000,&ff;)"/></td>
					&dsnc;
					<td class="color" align="right">
						<xsl:choose>
							<xsl:when test="$totalElapsed > 0">  
								<xsl:value-of select="format-number($sumElapsed div $totalElapsed * 100,&ff;)"/>
							</xsl:when>
							<xsl:otherwise>
								n/a
							</xsl:otherwise>
						</xsl:choose>
					</td>
				</tr>
			</xsl:if>
		</table>    
	</xsl:if>
</xsl:template>
 
<xsl:template name="cursor_detail">
	<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
		<xsl:if test="session_id">
			<tr valign="top">
				<th class="no_color" align="left">Session&#160;ID</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="session_id"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="client_id">
			<tr valign="top">
				<th class="no_color" align="left">Client&#160;ID</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="client_id"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="service_name">
			<tr valign="top">
				<th class="no_color" align="left">Service&#160;Name</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="service_name"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="module_name">
			<tr valign="top">
				<th class="no_color" align="left">Module&#160;Name</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="module_name"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="action_name">
			<tr valign="top">
				<th class="no_color" align="left">Action&#160;Name</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="action_name"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="@uid">
			<tr valign="top">
				<th class="no_color" align="left">Parsing&#160;User</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="@uid"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="@depth!=0">
			<tr valign="top">
				<th class="no_color" align="left">Recursive&#160;Level</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="@depth"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="@depth!=0">
			<tr valign="top">
				<th class="no_color" align="left">Parent&#160;Statement</th>
				&hsnc;
				<td class="no_color" align="left">
					<a href="#{@parent}"><xsl:value-of select="@parent"/></a>&#160;
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="@hash_value">
			<tr valign="top">
				<th class="no_color" align="left">Hash&#160;Value</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="@hash_value"/></td>
			</tr>
		</xsl:if>
		<xsl:if test="@sql_id">
			<tr valign="top">
				<th class="no_color" align="left">SQL&#160;ID</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="@sql_id"/></td>
			</tr>
		</xsl:if>
		<tr valign="top">
			<th class="no_color" align="left">Text</th>
			&dsnc;
			<td class="no_color_pre" align="left">
				<xsl:for-each select="sql/line">
					<xsl:value-of select="."/><br/>
				</xsl:for-each>
			</td>
		</tr>
		<xsl:if test="errors">
			<tr valign="top">
				<th class="no_color" align="left">Errors</th>
				&dsnc;
				<td class="no_color" align="left">
					<xsl:for-each select="errors/error">
						ORA-<xsl:value-of select="format-number(.,'00000')"/>&#160;
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
	</table>
	<xsl:apply-templates select="binds"/>
	<xsl:apply-templates select="execution_plans"/>
	<xsl:apply-templates select="cumulated_statistics"/>
	<xsl:apply-templates select="current_statistics"/>
	<xsl:apply-templates select="profile"/>
	<xsl:apply-templates select="profile/event"/>
</xsl:template>

<xsl:template match="cumulated_statistics">
	<h2>
		<xsl:choose>
			<xsl:when test="../current_statistics">
				Database Call Statistics with Recursive Statements
			</xsl:when>
			<xsl:otherwise>
				Database Call Statistics
			</xsl:otherwise>
		</xsl:choose>
	</h2>
	<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
		<tr valign="top">
			<th class="color" align="left">Call</th>
			&hsnc;
			<th class="color" align="right">Count</th>
			&hsnc;
			<th class="color" align="left">Misses</th>
			&hsnc;
			<th class="color" align="right">CPU <a class="th" href="#units">[s]</a></th>
			&hsnc;
			<th class="color" align="right">Elapsed <a class="th" href="#units">[s]</a></th>
			&hsnc;
			<th class="color" align="right">PIO <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">LIO <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">Consistent <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">Current <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">Rows</th>
		</tr>
		&trnc;
		<xsl:apply-templates select="statistic"/>
	</table>
</xsl:template>

<xsl:template match="current_statistics">
	<h2>Database Call Statistics without Recursive Statements</h2>
	<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
		<tr valign="top">
			<th class="color" align="left">Call</th>
			&hsnc;
			<th class="color" align="right">Count</th>
			&hsnc;
			<th class="color" align="left">Misses</th>
			&hsnc;
			<th class="color" align="right">CPU <a class="th" href="#units">[s]</a></th>
			&hsnc;
			<th class="color" align="right">Elapsed <a class="th" href="#units">[s]</a></th>
			&hsnc;
			<th class="color" align="right">PIO <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">LIO <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">Consistent <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">Current <a class="th" href="#units">[b]</a></th>
			&hsnc;
			<th class="color" align="right">Rows</th>
		</tr>
		&trnc;
		<xsl:apply-templates select="statistic"/>
	</table>
</xsl:template>

<xsl:template match="statistic[@call='Parse' or @call='Execute' or @call='Fetch' or @call='Total']">
	<xsl:if test="@call='Total'">
		&trnc;
	</xsl:if>
	<tr valign="top">
		<td class="color" align="left"><xsl:value-of select="@call"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@count,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@misses,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@cpu div 1000000,&ff;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@pio,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@lio,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@consistent,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@current,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@rows,&if;)"/></td>
	</tr>
</xsl:template>

<xsl:template match="statistic[substring(@call,1,7)='Average']">
	&trnc;
	<tr valign="top">
		<td class="color" align="left"><xsl:value-of select="@call"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@count,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="@misses"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@cpu div 1000000,&ff;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@pio,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@lio,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@consistent,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@current,&if;)"/></td>
		&dsnc;
		<td class="color" align="right"><xsl:value-of select="format-number(@rows,&if;)"/></td>
	</tr>
</xsl:template>

<xsl:template match="execution_plans">
	<h2>Execution Plans</h2>
	<xsl:for-each select="execution_plan">
		<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
			<tr valign="top">
				<th class="no_color" align="left">Optimizer Mode</th>
				&hsnc;
				<td class="no_color" align="left"><xsl:value-of select="@goal"/></td>
			</tr>
			<xsl:if test="@hash_value">
				<tr valign="top">
					<th class="no_color" align="left">Hash Value</th>
					&hsnc;
					<td class="no_color" align="left"><xsl:value-of select="@hash_value"/></td>
				</tr>
			</xsl:if>
			<xsl:if test="count(../execution_plan)>1">
				<tr valign="top">
					<th class="no_color" align="left">Number of Executions</th>
					&hsnc;
					<td class="no_color" align="left"><xsl:value-of select="@executions"/></td>
				</tr>
			</xsl:if>
		</table>
		<xsl:if test="@incomplete='true'">
			<p class="error">WARNING: The following execution plan is incomplete.</p>
		</xsl:if>
		<p/>
		<table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
			<xsl:if test="line/@elapsed">
				<tr valign="top">
					<th class="no_color" colspan="9"></th>
					&hsnc;
					<th class="color" align="center" colspan="5">Cumulated (incl. descendants)</th>
				</tr>
			</xsl:if>
			<tr valign="top">
				<th class="color" align="right">Rows</th>
				&hsnc;
				<th class="color" align="left">Operation</th>
				<xsl:if test="line/@elapsed">
					&hsnc;
					<th class="color" align="right">Elapsed <a class="th" href="#units">[s]</a></th>
					&hsnc;
					<th class="color" align="right">PIO <a class="th" href="#units">[b]</a></th>
					&hsnc;
					<th class="color" align="right">Consistent <a class="th" href="#units">[b]</a></th>
					&hsnc;
					<th class="color" align="right">Elapsed <a class="th" href="#units">[s]</a></th>
					&hsnc;
					<th class="color" align="right">PIO <a class="th" href="#units">[b]</a></th>
					&hsnc;
					<th class="color" align="right">Consistent <a class="th" href="#units">[b]</a></th>
				</xsl:if>
			</tr>
			&trnc;
			<xsl:for-each select="line">
				<tr valign="top">
					<td class="color" align="right"><xsl:value-of select="format-number(@rows,&if;)"/></td>
					&dsnc;
					<td class="color" align="left">
						<xsl:value-of select="substring('&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;',1,3*@level)"/>
						<xsl:value-of select="text()"/>
					</td>
					<xsl:if test="@elapsed">
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@elapsed div 1000000,&ff;)"/></td>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@pio,&if;)"/></td>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@lio,&if;)"/></td>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@cum_elapsed div 1000000,&ff;)"/></td>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@cum_pio,&if;)"/></td>
						&dsnc;
						<td class="color" align="right"><xsl:value-of select="format-number(@cum_lio,&if;)"/></td>
					</xsl:if>
				</tr>
			</xsl:for-each>
		</table>
		<p/>
	</xsl:for-each>
</xsl:template>

<xsl:template match="binds[@count&gt;0]">
    <h2>Bind Variables</h2>
	<p>
		<xsl:choose>
			<xsl:when test="@count = 1">
				1 bind variable set was used to execute this statement.
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@count"/> bind variable sets were used to execute this statement.
			</xsl:otherwise>
		</xsl:choose>
		<br/>
		<xsl:if test="@count > @limit">
			In the following table, only the first <xsl:value-of select="@limit"/> bind variable sets are reported.
		</xsl:if>
	</p>
    <table border="&border;" cellspacing="&cellspacing;" cellpadding="&cellpadding;">
		<tr valign="top">
			<th class="color" align="left">Execution</th>
			&hsnc;
			<th class="color" align="left">Bind</th>
			&hsnc;
			<th class="color" align="left">Datatype</th>
			&hsnc;
			<th class="color" align="left">Value</th>
		</tr>
      <xsl:apply-templates select="bind_set/bind"/>
    </table>
</xsl:template>

<xsl:template match="bind_set/bind">
	<xsl:if test="@nr=1">
		&trnc;
	</xsl:if>
	<tr valign="top">
		<td class="color" align="left">
		<xsl:if test="@nr=1">
			<xsl:value-of select="../@nr"/>
		</xsl:if>
		</td>
		&dsnc;
		<td class="color" align="left"><xsl:value-of select="@nr"/></td>
		&dsnc;
		<td class="color" align="left"><xsl:value-of select="@datatype"/></td>
		&dsnc;
		<td class="color_pre" align="left"><xsl:value-of select="text()"/></td>
    </tr>
</xsl:template>

<!-- small pieces of code reused many times... -->
  
<xsl:template name="anchor4cursor">
	<xsl:variable name="currentId" select="@id"/>
	<xsl:choose>
		<xsl:when test="/tvdxtat/cursors/cursor[@id=$currentId]">
			<a href="#{$currentId}"><xsl:value-of select="$currentId"/></a>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$currentId"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="cursortype">
	<xsl:value-of select="@type"/>
	<xsl:if test="@uid = 0 and @depth > 0">
		(SYS recursive)
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
