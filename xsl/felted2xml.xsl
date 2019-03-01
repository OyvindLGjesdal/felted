<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xs math map"
    version="3.0">
    <xsl:key name="neste" match="linje" use="@neste"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="input-path" select="'/home/oyvind/repos/stedsnavn/felted/input/'"></xsl:param>
    
    <xsl:mode on-no-match="shallow-skip"/>    
    <xsl:mode name="expand-lines" on-no-match="shallow-copy"/>
    <xsl:mode name="add-milestones" on-no-match="shallow-copy"/>
    <xsl:mode name="expand-milestones" on-no-match="shallow-skip"/>

    <xsl:template match="/">        
            <xsl:for-each select="for $x  in collection('/home/oyvind/repos/stedsnavn/felted/input/?select=*.txt;metadata=yes') return map:get($x,'canonical-path')">
                <xsl:variable name="filename" select="substring-before(tokenize(.,'/')[last()],'.') || '.xml' "/>
                <xsl:variable name="document-as-string" as="xs:string">
                    <xsl:message select="$filename"/>
                    <xsl:sequence select="'&lt;records&gt;' 
                        ||  unparsed-text(.,'CP850')
                        || '&lt;/records&gt;' "/>             
                </xsl:variable>                
               
               <xsl:result-document href="{$filename}" method="xml">              
                   <records>
                       <xsl:apply-templates select="parse-xml($document-as-string)/*"/>              
                   </records>
               </xsl:result-document>
            </xsl:for-each>
    </xsl:template>
    
    <!-- begynn poster på linjer som ikke har neste, ekspanderer linjer, legger til milestone-elementer og ekspanderer til en flat xml-struktur-->
    <xsl:template match="linje[@neste = '0']">
        <record>
            <xsl:variable name="lines-added">
                <xsl:apply-templates select="key('neste', @nr)" mode="expand-lines"/>
                <xsl:apply-templates mode="expand-lines"/>
            </xsl:variable>
            <xsl:variable name="milestones-added">
                <xsl:apply-templates select="$lines-added" mode="add-milestones"/>
            </xsl:variable>
            <xsl:apply-templates select="$milestones-added" mode="expand-milestones"/>
        </record>
    </xsl:template>
    
    <xsl:template mode="#all" match="linje[@status!='1']" priority="5"/>
    
    <xsl:template match="linje" mode="expand-lines">     
        <xsl:apply-templates select="key('neste',@nr)" mode="expand-lines"/>     
            <xsl:apply-templates mode="expand-lines"/>
    </xsl:template>
    
    <!-- legger til element milestone for første tekst-node (OFSO?) som ikke har control-character-->
    <xsl:template match="text()[not(exists(preceding-sibling::node()))]" mode="add-milestones">
        <xsl:element name="{substring-before(self::text(),' ')}"/>
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="u0012|u0013" mode="add-milestones">
        <xsl:variable name="following-text" select="following-sibling::node()[1]/self::text()"/>        
        <xsl:choose>
            <xsl:when test="matches($following-text,'^([A-Z]{2,})\s')">                
                <xsl:element name="{substring-before($following-text,' ')}"/>
            </xsl:when>
            <xsl:when test="following-sibling::node()[2]/self::u0013">
                <id/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[not(child::node())]" mode="expand-milestones">
        <xsl:element name="{name()}">
            <xsl:value-of select="normalize-space(replace(following-sibling::node()[1]/self::text(),'[A-Z]{2,}\s+',''))"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>