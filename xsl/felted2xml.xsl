<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    <xsl:key name="neste" match="linje" use="@neste"/>
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:mode on-no-match="shallow-skip"/>    
    <xsl:mode name="neste" on-no-match="shallow-copy" />
    <xsl:mode name="add-milestones" on-no-match="shallow-copy"/>
    <xsl:mode name="expand-milestones" on-no-match="shallow-skip"/>
    
    <xsl:variable name="field-name-regex" select="'(OSFO|NORM|ARKI|LPNR|NATY|TRAD|KONR|GBNR|INFO|OPPS|LITT)'" as="xs:string"/>
    
    
    <xsl:template match="/">
        <records>
            <xsl:apply-templates/>
        </records>
    </xsl:template>
    
    <!-- begynn poster på linjer som ikke har neste-->
    <xsl:template match="linje[@neste='0']">
        <record>
            <xsl:variable name="current">
            <xsl:apply-templates select="key('neste',@nr)" mode="expand-lines"/>            
            <xsl:apply-templates mode="expand-lines"/>           
            </xsl:variable>
            <xsl:variable name="with-milestones">
            <xsl:apply-templates select="$current" mode="add-milestones"/>
            </xsl:variable>
            <xsl:apply-templates select="$with-milestones" mode="expand-milestones"></xsl:apply-templates>
        </record>        
    </xsl:template>
    
    <xsl:template mode="neste" match="linje[@status!='1']" priority="5"/>
    
    <xsl:template match="linje" mode="neste">     
        <xsl:apply-templates select="key('neste',@nr)" mode="neste"/>     
            <xsl:apply-templates mode="neste"/>
    </xsl:template>
    
    <xsl:template match="u0012|u0013" mode="neste">
        <xsl:variable name="following-text" select="following-sibling::node()[1]/self::text()"/>
        <xsl:if test="matches($following-text,'^[A-Z]{2,}following-sibling::node()/self::text()"
    </xsl:template>
    
    <xsl:template match="text()[matches(.,$field-name-regex)]" mode="add-milestones">
        <xsl:analyze-string select="." regex="{$field-name-regex}">
            <xsl:matching-substring>
                <xsl:element name="{regex-group(1)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template mode="neste" match="text()[following-sibling::*[1]/self::u0013]">
        <id><xsl:value-of select="."/></id>
    </xsl:template>
    
    <xsl:template match="*[not(child::node())]" mode="expand-milestones">
        <xsl:element name="{name()}">
            <xsl:value-of select="normalize-space(following-sibling::node()[1]/self::text())"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>