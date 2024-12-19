<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">

    <xsl:output method="text"/>

    <xsl:param name="form" select="'of'"/>
    <xsl:param name="weekdays" select="'no'"/>
    <xsl:param name="lang" select="'en'"/>

    <xsl:variable name="names">
        <name form="eo" weekdays="no" lang="en">Liturgical Calendar for Sundays and feasts (tridentine mass)</name>
        <name form="eo" weekdays="yes" lang="en">Liturgical Calendar for weekdays (tridentine mass)</name>
        <name form="of" weekdays="no" lang="en">Liturgical Calendar for Sundays and feasts (novus ordo)</name>
        <name form="of" weekdays="yes" lang="en">Liturgical Calendar for weekdays (novus ordo)</name>
        <name form="eo" weekdays="no" lang="nl">Liturgische Kalender voor zon- en feestdagen (tridentijnse mis)</name>
        <name form="eo" weekdays="yes" lang="nl">Liturgische Kalender voor weekdagen (tridentijnse mis)</name>
        <name form="of" weekdays="no" lang="nl">Liturgische Kalender voor zon- en feestdagen (novus ordo)</name>
        <name form="of" weekdays="yes" lang="nl">Liturgische Kalender voor weekdagen (novus ordo)</name>
        <name form="eo" weekdays="no" lang="fr">Calendrier Liturgique pour Dimanches et fêtes (messe tridentaine)</name>
        <name form="eo" weekdays="yes" lang="fr">Calendrier Liturgique pour jours de la semaine (messe tridentaine)</name>
        <name form="of" weekdays="no" lang="fr">Calendrier Liturgique pour Dimanches et fêtes (novus ordo)</name>
        <name form="of" weekdays="yes" lang="fr">Calendrier Liturgique pour jours de la semaine (novus ordo)</name>
    </xsl:variable>
    <xsl:variable name="name" select="$names/name[@form=$form][@weekdays=$weekdays][@lang=$lang]/text()"/>
    <xsl:variable name="days" select="doc('Index of liturgical days - missal.xml')/data"/>
    <xsl:variable name="i18n_of" select="doc('Catholic Liturgical Days - ordinary form - easterbrooks - all fxd.xml')/data"/>
    <xsl:variable name="i18n_eo" select="doc('Catholic Liturgical Days - extraordinary form - values.xml')/data"/>
    <xsl:variable name="dtstamp" select="format-dateTime(current-dateTime(), '[Y0001][M01][D01]T[H01][m01][s01]Z')"/>

    <xsl:template match="calendar">
        <xsl:text>BEGIN:VCALENDAR&#xd;&#xa;</xsl:text>
        <xsl:text>VERSION:2.0&#xd;&#xa;</xsl:text>
        <xsl:text>NAME:</xsl:text><xsl:value-of select="$name"/><xsl:text>&#xd;&#xa;</xsl:text>
        <xsl:text>X-WR-CALNAME:</xsl:text><xsl:value-of select="$name"/><xsl:text>&#xd;&#xa;</xsl:text>
        <xsl:text>REFRESH-INTERVAL;VALUE=DURATION:PT7D&#xd;&#xa;</xsl:text>
        <xsl:text>X-PUBLISHED-TTL:PT7D&#xd;&#xa;</xsl:text>
        <xsl:text>PRODID:-//www.missale.net//</xsl:text><xsl:value-of select="$name"/><xsl:text>//</xsl:text><xsl:value-of select="upper-case($lang)"/><xsl:text>&#xd;&#xa;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>END:VCALENDAR</xsl:text>
    </xsl:template>

    <xsl:template match="year">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="day">
        <xsl:if test="coordinates != ''">
            <xsl:variable name="day" select="$days/*[form=current()/form][coordinates=current()/coordinates][current()/cycle='None' or contains(cycle,current()/cycle)]"/>
            <xsl:message>$day: <xsl:copy-of select="$day"/></xsl:message>
            <xsl:variable name="ref" select="concat(current()/form,'.',current()/coordinates)"/>
            <xsl:message>$ref: <xsl:copy-of select="$ref"/></xsl:message>
            <xsl:variable name="i18n" select="($i18n_of/*|$i18n_eo/*)[ref=$ref]"/>
            <xsl:message>$i18n: <xsl:copy-of select="$i18n"/></xsl:message>
            <xsl:variable name="title" select="normalize-space($i18n/*[name()=$lang])"/>
            <xsl:variable name="uid" select="concat('https://www.missale.net/',form,'/',date,'/',$lang)"/>
            <xsl:variable name="url">
                <xsl:choose>
                    <xsl:when test="$weekdays='yes'"/>
                    <xsl:otherwise><xsl:value-of select="$uid"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="weekday" select="not(contains($day/category,'sunday')) and not(contains($day/category,'feast')) and not(contains($day/category,'solemnity'))"/>
            <xsl:message>$weekday: <xsl:value-of select="$weekday"/></xsl:message>
            <xsl:if test="($weekdays='no' and not($weekday)) or ($weekdays='yes' and $weekday)">
                <xsl:message>Add day to calendar</xsl:message>
                <xsl:text>BEGIN:VEVENT&#xd;&#xa;</xsl:text>
                <xsl:text>DTSTAMP:</xsl:text>
                <xsl:value-of select="$dtstamp"/>
                <xsl:text>&#xd;&#xa;</xsl:text>
                <xsl:text>DTSTART;VALUE=DATE:</xsl:text>
                <xsl:value-of select="replace(date,'-','')"/>
                <xsl:text>&#xd;&#xa;</xsl:text>
                <xsl:text>SUMMARY:</xsl:text>
                <xsl:value-of select="$title"/>
                <xsl:text>&#xd;&#xa;</xsl:text>
                <xsl:text>DESCRIPTION:</xsl:text>
                <xsl:value-of select="$title"/><xsl:if test="not($url='')"><xsl:text>\n</xsl:text></xsl:if><xsl:value-of select="$url"/>
                <xsl:text>&#xd;&#xa;</xsl:text>
                <xsl:text>UID:</xsl:text>
                <xsl:value-of select="$uid"/>
                <xsl:text>&#xd;&#xa;</xsl:text>
                <xsl:if test="not($url='')">
                    <xsl:text>URL:</xsl:text>
                    <xsl:value-of select="$url"/>
                    <xsl:text>&#xd;&#xa;</xsl:text>
                </xsl:if>
                <xsl:text>END:VEVENT</xsl:text>
                <xsl:text>&#xd;&#xa;</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*|text()"/>

</xsl:stylesheet>
