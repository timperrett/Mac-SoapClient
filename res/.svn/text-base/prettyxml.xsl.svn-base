<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">

    <xsl:output method="xml" indent="no" omit-xml-declaration="no"/>
	
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="name(node()[1]) != 'TOD_nil'">
				<xsl:call-template name="start"/>
			</xsl:when>
			<xsl:otherwise>
				<html></html>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

    <xsl:template name="start">
		<html>
		<head>
			<style type="text/css">
				/*<![CDATA[*/
				body {
					margin:10px 0 0 -15px;
				}
				.TOD_element {
					font-family:Monaco;
					font-size:10px;
					margin-left:15;
					white-space:nowrap;
				}
				.TOD_content {
					font-family:Monaco;
				}
				.TOD_expandButton {
					cursor:pointer;
					padding:2px 5px;
					-khtml-user-select:none;
				}
				.TOD_startOpenBracket,
				.TOD_endOpenBracket,
				.TOD_startCloseBracket,
				.TOD_endCloseBracket {
					color:black;
				}
				.TOD_endOpenBracketIndent {
					/*display:block;
					margin-left:25px;*/
				}
				.TOD_startCloseBracket {
					margin-left:15px;
				}
				.TOD_startElementName, .TOD_endElementName {
					color:purple;
					font-weight:normal;
				}
				.TOD_endElementName {
				}
				.TOD_attrName,
				.TOD_attrEquals {
					color:black;
					font-weight:normal;
				}
				.TOD_attrIndent {
					display:block;
					margin-left:50px;
				}
				.TOD_attrValue,
				.TOD_openAttrQuote,
				.TOD_closeAttrQuote {
					color:blue;
				}
				.TOD_comment,
				.TOD_pi {
					font-family:Monaco;
					font-size:12px;
					margin-left:30;
				}
				.TOD_comment {
					color:gray;
				}
				.TOD_pi {
					color:#449a9b;
				}
				/*]]>*/
			</style>
			<script type="text/javascript">
				//<![CDATA[
				function isShowing(el) {
					return "none" != el.style.display;
				}
				function toggle(el) {
					if (isShowing(el))
						el.style.display = "none";
					else
						el.style.display = "";
				}
				function expand(expandButton) {
					var expandArea = getNextSiblingByClassName(expandButton, "TOD_content");
					toggle(expandArea);
					if (isShowing(expandArea))
						expandButton.innerHTML = "- ";
					else
						expandButton.innerHTML = "+ ";
				}
				function getNextSiblingByClassName(element, className) {
					while (element = element.nextSibling) {
						if (element.nodeType == Node.ELEMENT_NODE) {
							if (-1 != element.className.indexOf(className)) {
								return element;
							}
						}
					}
					return null;
				}
				//]]>
			</script>
		</head>
		<body>
			<xsl:apply-templates/>
		</body>
		</html>
    </xsl:template>

    <xsl:template match="*">
    	
    	<!-- process elements -->
        <div class="TOD_element">
            <span class="TOD_expandButton" onclick="expand(this);">-</span>
            <span class="TOD_startOpenBracket">&lt;</span>
            <span class="TOD_startElementName">
                <xsl:value-of select="name()"/>
            </span>
            
            <!-- process namespaces on document element only... no good reason, it just seems right 
            	other wise, the namespace nodes are too noisy -->
            <xsl:variable name="isDocEl" select="local-name() = 'Envelope'"/>
            	
            <xsl:if test="$isDocEl">
				<xsl:for-each select="namespace::*">
					<xsl:call-template name="doNamespaceOrAttribute">
						<xsl:with-param name="value" select="."/>
						<xsl:with-param name="name" select="concat('xmlns:', name())"/>
						<xsl:with-param name="isDocEl" select="$isDocEl"/>
						<!--
						<xsl:with-param name="isNS" select="true()"/>
						-->
					</xsl:call-template>
				</xsl:for-each>
            </xsl:if>



            <xsl:variable name="isMethodEl" select="local-name(..) = 'Body'"/>
            <xsl:if test="$isMethodEl">
				<xsl:for-each select="namespace::*">
					<xsl:if test="not(.='http://www.w3.org/XML/1998/namespace')
								and not(.='http://schemas.xmlsoap.org/soap/envelope/')
								and not(.='http://schemas.xmlsoap.org/soap/encoding/')
								and not(.='http://www.w3.org/2001/XMLSchema-instance')
								and not(.='http://www.w3.org/2001/XMLSchema')
								and not(.='http://www.w3.org/1999/XMLSchema')
								and not(.='http://www.w3.org/1999/XMLSchema-instance')">
						<xsl:variable name="name">
							<xsl:choose>
								<xsl:when test="name()"><xsl:value-of select="concat('xmlns:', name())"/></xsl:when>
								<xsl:otherwise><xsl:value-of select="'xmlns'"/></xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:call-template name="doNamespaceOrAttribute">
							<xsl:with-param name="value" select="."/>
							<xsl:with-param name="name" select="$name"/>
							<xsl:with-param name="isDocEl" select="false()"/>
							<xsl:with-param name="isNS" select="true()"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:for-each>
            </xsl:if>


            <!-- process attributes -->
            <xsl:apply-templates select="@*">
            	<xsl:with-param name="isDocEl" select="$isDocEl"/>
            </xsl:apply-templates>
           
			<xsl:variable name="className">
				<xsl:choose>
					<xsl:when test="$isDocEl and count(namespace::*)">TOD_endOpenBracketIndent</xsl:when>
					<xsl:otherwise>TOD_endOpenBracket</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
           
			<span class="{$className}">&gt;</span>            <span class="TOD_content">
            <xsl:apply-templates/>
            </span>
            <xsl:choose>
                <xsl:when test="count(*)">
                    <span class="TOD_startCloseBracket">&lt;/</span>
                </xsl:when>
                <xsl:otherwise>
                    <span class="TOD_leafStartCloseBracket">&lt;/</span>
                </xsl:otherwise>
            </xsl:choose>
            <span class="TOD_endElementName">
                <xsl:value-of select="name()"/>                </span>
            <span class="TOD_endCloseBracket">&gt;</span>        </div>
    </xsl:template>
    
    <xsl:template name="doNamespaceOrAttribute">
    	<xsl:param name="name"/>
    	<xsl:param name="value"/>
    	<xsl:param name="isDocEl" select="false()"/>
    	<xsl:param name="isNS" select="false()"/>
    	<xsl:param name="hasNS" select="false()"/>
    	
		<xsl:if test="$name != 'xmlns:xml'">
			<xsl:variable name="className">
				<xsl:choose>
				<!--
					<xsl:when test="$isNS and position() > 1">TOD_attr</xsl:when>
					-->
					<xsl:when test="$isDocEl">TOD_attrIndent</xsl:when>
					<xsl:when test="$hasNS and position() = 1">TOD_attrIndent</xsl:when>
					<xsl:otherwise>TOD_attr</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<span class="{$className}">
				<xsl:text> </xsl:text>
				<span class="TOD_attrName">
					<xsl:value-of select="$name"/>
				</span>
				<span class="TOD_attrEquals">
					<xsl:text>=</xsl:text>
				</span>
				<span class="TOD_openAttrQuote">
					<xsl:text>"</xsl:text>
				</span>
				<span class="TOD_attrValue">
					<xsl:value-of select="$value"/>
				</span>
				<span class="TOD_closeAttrQuote">
					<xsl:text>"</xsl:text>
				</span>
			</span>
		</xsl:if>
    </xsl:template>
    
    <xsl:template match="@*">
	    <xsl:param name="isDocEl"/>
		<xsl:call-template name="doNamespaceOrAttribute">
			<xsl:with-param name="value" select="."/>
			<xsl:with-param name="name" select="name()"/>
			<xsl:with-param name="hasNS" select="$isDocEl and count(../namespace::*)"/>
		</xsl:call-template>
    </xsl:template>

    <xsl:template match="comment()">
        <div class="TOD_comment">
        <xsl:text>&lt;!-- </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text> --&gt;</xsl:text>
        </div>
    </xsl:template>

    <xsl:template match="processing-instruction()">
        <div class="TOD_pi">
        <xsl:text>&lt;?</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>?&gt;</xsl:text>
        </div>
    </xsl:template>

</xsl:stylesheet>