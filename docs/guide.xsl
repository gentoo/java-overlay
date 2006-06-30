<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:exslt="http://exslt.org/common"
                xmlns:func="http://exslt.org/functions"
                extension-element-prefixes="exslt func" >

<xsl:output encoding="UTF-8" method="html" indent="yes" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" doctype-system="http://www.w3.org/TR/html4/loose.dtd"/>

<!--<xsl:include href="content.xsl" />-->
<xsl:template name="content">
  <xsl:if test="local-name() = 'guide'">
    <!-- Inside /guide -->
    <xsl:call-template name="guidecontent" />
  </xsl:if>
  <xsl:if test="local-name() = 'book'">
    <!-- Inside /book -->
    <xsl:call-template name="bookcontent" />
  </xsl:if>
  <xsl:if test="local-name() = 'sections'">
    <!-- Inside /sections -->
      <xsl:apply-templates select="/sections/section">    
        <xsl:with-param name="chapnum" select="1"/>
        <xsl:with-param name="partnum" select="1"/>
      </xsl:apply-templates>
  </xsl:if>
  <xsl:if test="local-name() = 'part'">
    <!-- Inside /book/part -->
    <xsl:call-template name="bookpartcontent" />
  </xsl:if>
  <xsl:if test="local-name() = 'chapter'">
    <!-- Inside /book/part/chapter -->
    <xsl:call-template name="bookpartchaptercontent" />
  </xsl:if>
</xsl:template>

<!--<xsl:include href="handbook.xsl" />-->
<xsl:param name="part">0</xsl:param>
<xsl:param name="chap">0</xsl:param>
<xsl:param name="full">0</xsl:param>

<!-- A book -->
<xsl:template match="/book">
  <!-- If chap = 0, show an index -->
  <xsl:choose>
    <xsl:when test="$part != 0">
      <xsl:apply-templates select="part" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="doclayout"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- <sections>, i.e. when user tries to access a book file directly -->
<xsl:template match="/sections">
  <xsl:call-template name="doclayout"/>
</xsl:template>

<!-- Content of /book -->
<xsl:template name="bookcontent">
  <h1><xsl:value-of select="title" /></h1>
  <xsl:if test="$style = 'printable'">
    <xsl:apply-templates select="author" />
    <br/>
    <i><xsl:call-template name="contentdate"/></i>
  </xsl:if>
  <p><xsl:value-of select="func:gettext('Content')"/>:</p>
  <ul>
    <xsl:for-each select="part">
      <xsl:variable name="curpart" select="position()" />
      <li>
        <xsl:choose>
          <xsl:when test="$full = 0">
            <xsl:choose>
              <xsl:when test="$style != 'printable'">
                <b><a href="?part={$curpart}"><xsl:value-of select="title" /></a></b>
              </xsl:when>
              <xsl:otherwise>
                <b><a href="?part={$curpart}&amp;style=printable"><xsl:value-of select="title" /></a></b>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <b><a href="#book_part{$curpart}"><xsl:value-of select="title" /></a></b>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="abstract">
          <br />
          <xsl:value-of select="abstract" />
        </xsl:if>
        <ol>
          <xsl:for-each select="chapter">
            <xsl:variable name="curchap" select="position()" />
            <li>
              <xsl:choose>
                <xsl:when test="$full = 0">
                  <xsl:choose>
                    <xsl:when test="$style != 'printable'">
                      <b><a href="?part={$curpart}&amp;chap={$curchap}"><xsl:value-of select="title" /></a></b>
                    </xsl:when>
                    <xsl:otherwise>
                      <b><a href="?part={$curpart}&amp;chap={$curchap}&amp;style=printable"><xsl:value-of select="title" /></a></b>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <b><a href="#book_part{$curpart}_chap{$curchap}"><xsl:value-of select="title" /></a></b>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="abstract">
                <br/>
                <xsl:value-of select="abstract" />
              </xsl:if>
            </li>
          </xsl:for-each>
        </ol>
      </li>
    </xsl:for-each>
  </ul>

  <xsl:if test="$full =1">
    <xsl:apply-templates select="part" />
  </xsl:if>
  
  <xsl:apply-templates select="/book/license" />
</xsl:template>

<!-- Part inside a book -->
<xsl:template match="/book/part">
  <xsl:if test="(($chap != 0) and ($part = position())) or ($full = 1)">
    <xsl:param name="pos" select="position()"/>
    <xsl:if test="$full = 1">
      <a name="book_part{$pos}"/>
      <h2><xsl:number level="multiple" format="A. " value="$pos"/><xsl:value-of select="title" /></h2>
    </xsl:if>
    <xsl:apply-templates select="chapter">
      <xsl:with-param name="partnum" select="$pos"/>
    </xsl:apply-templates>
  </xsl:if>
  <xsl:if test="($chap = 0) and ($part = position())">
    <xsl:call-template name="doclayout" />
  </xsl:if>
</xsl:template>

<!-- Content of /book/part -->
<xsl:template name="bookpartcontent">
  <xsl:if test="@id">
    <a name="{@id}"/>
  </xsl:if>
  <h1><xsl:number level="multiple" format="1. " value="position()"/><xsl:value-of select="title" /></h1>
  <xsl:if test="abstract">
    <p><xsl:value-of select="abstract" /></p>
  </xsl:if>
  <p><xsl:value-of select="func:gettext('Content')"/>:</p>
  <ol>
    <xsl:for-each select="chapter">
      <xsl:variable name="curpos" select="position()" />
      <xsl:if test="title">
        <li>
          <b><a href="?part={$part}&amp;chap={$curpos}"><xsl:value-of select="title" /></a></b>
          <xsl:if test="abstract">
            <br/><xsl:value-of select="abstract" />
          </xsl:if>
        </li>
      </xsl:if>
    </xsl:for-each>
  </ol>
  
  <xsl:apply-templates select="/book/license" />
</xsl:template>

<!-- Menu bar -->
<xsl:template name="menubar">
  <xsl:variable name="prevpart" select="number($part) - 1" />
  <xsl:variable name="prevchap" select="number($chap) - 1" />
  <xsl:variable name="nextpart" select="number($part) + 1" />
  <xsl:variable name="nextchap" select="number($chap) + 1" />
  <xsl:if test="($style != 'printable') and ($full = 0)">
    <hr />
    <p>
      <!-- Previous Parts -->
      <xsl:choose>
        <xsl:when test="number($prevpart) &lt; 1">
          [ &lt;&lt; ]
        </xsl:when>
        <xsl:otherwise>
          [ <a href="?part={$prevpart}">&lt;&lt;</a> ]
        </xsl:otherwise>
      </xsl:choose>
      <!-- Previous Chapter -->
      <xsl:choose>
        <xsl:when test="number($prevchap) &lt; 1">
          [ &lt; ]
        </xsl:when>
        <xsl:otherwise>
          [ <a href="?part={$part}&amp;chap={$prevchap}">&lt;</a> ]
        </xsl:otherwise>
      </xsl:choose>
      <!-- Content -->
      [ <a href="?part=0"><xsl:value-of select="func:gettext('Home')"/></a> ]
      <!-- Next Chapter -->
      <xsl:if test="name() = 'book'">
        [ <a href="?part=1">&gt;</a> ]
      </xsl:if>
      <xsl:if test="name() = 'part'">
        [ <a href="?part={$part}&amp;chap=1">&gt;</a> ]
      </xsl:if>
      <xsl:if test="name() = 'chapter'">
        <xsl:choose>
          <xsl:when test="last() = position()">
            [ &gt; ]
          </xsl:when>
          <xsl:otherwise>
            [ <a href="?part={$part}&amp;chap={$nextchap}">&gt;</a> ]
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <!-- Next Part -->
      <xsl:if test="name() = 'book'">
        [ <a href="?part={$nextpart}">&gt;&gt;</a> ]
      </xsl:if>
      <xsl:if test="name() = 'part'">
        <xsl:choose>
          <xsl:when test="number($part) = last()">
            [ &gt;&gt; ]
          </xsl:when>
          <xsl:otherwise>
            [ <a href="?part={$nextpart}">&gt;&gt;</a> ]
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="name() = 'chapter'">
        <xsl:choose>
          <xsl:when test="count(/book/part) = number($part)">
            [ &gt;&gt; ] 
          </xsl:when>
          <xsl:otherwise>
            [ <a href="?part={$nextpart}">&gt;&gt;</a> ]
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </p>
    <hr />
  </xsl:if>
</xsl:template>


<!-- Chapter inside a part -->
<xsl:template match="/book/part/chapter">
  <xsl:if test="($chap = position()) and ($full = 0)">
    <xsl:call-template name="doclayout" />
  </xsl:if>
  <xsl:if test="$full = 1">
    <xsl:call-template name="bookpartchaptercontent">
      <xsl:with-param name="partnum"><xsl:value-of select="$partnum" /></xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- Content of /book/part/chapter -->
<xsl:template name="bookpartchaptercontent">
  <xsl:param name="chapnum" select="position()"/>
  <xsl:if test="@id">
    <a name="{@id}"/>
  </xsl:if>
  <xsl:if test="$full = 1">
    <a name="book_part{$partnum}_chap{$chapnum}"/>
    <h3><xsl:number level="multiple" format="1. " value="position()"/><xsl:value-of select="title" /></h3>
  </xsl:if>
  <xsl:if test="$full = 0">
    <h1><xsl:number level="multiple" format="1. " value="position()"/><xsl:value-of select="title" /></h1>
  </xsl:if>
  <xsl:variable name="doc" select="include/@href"/>
  <xsl:variable name="FILE" select="document($doc,.)" />
  <xsl:if test="$full = 0">
    <!-- Chapter content only when rendering a single page -->
    <xsl:if test="$FILE/sections/section/title">
      <b><xsl:value-of select="func:gettext('Content')"/>: </b>
      <ul>
        <xsl:for-each select="$FILE/sections/section/title">
          <xsl:variable name="pos" select="position()" />
          <li><a href="#doc_chap{$pos}" class="altlink"><xsl:value-of select="." /></a></li>
        </xsl:for-each>
      </ul>
    </xsl:if>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="$full = 1">
      <xsl:apply-templates select="$FILE/sections/section">
        <xsl:with-param name="chapnum" select="$chapnum"/>
        <xsl:with-param name="partnum" select="$partnum"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="$FILE/sections/section">
        <xsl:with-param name="chapnum" select="$chapnum"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
  
  <xsl:if test="$full = 0">
    <xsl:apply-templates select="/book/license" />
  </xsl:if>
</xsl:template>

<!-- Section inside a chapter -->
<xsl:template match="/sections/section">
  <xsl:param name="pos" select="position()" />
  <xsl:choose>
    <xsl:when test="$full = 1">
      <!-- We need two anchors, 1 for internal links, 1 for cross-chapters links -->
      <a name="book_{generate-id(../..)}_chap{$pos}"/>
      <a name="book_part{$partnum}_chap{$chapnum}__chap{$pos}"/>
    </xsl:when>
    <xsl:otherwise>
      <a name="doc_chap{$pos}"/>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@id">
    <a name="{@id}"/>
  </xsl:if>
  <xsl:if test="title">
    <p class="chaphead"><span class="chapnum"><xsl:value-of select="$chapnum" />.<xsl:number level="multiple" format="a. " value="position()" /></span><xsl:value-of select="title" /></p>
  </xsl:if>

  <xsl:choose>
    <xsl:when test="$full = 1">
      <xsl:apply-templates select="body|subsection">
        <xsl:with-param name="chpos" select="$pos"/>
        <xsl:with-param name="chapnum" select="$chapnum"/>
        <xsl:with-param name="partnum" select="$partnum"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="body|subsection">
        <xsl:with-param name="chpos" select="$pos"/>
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!-- Subsubsection inside a section -->
<xsl:template match="/sections/section/subsection">
  <xsl:param name="pos" select="position()"/>
  <xsl:choose>
    <xsl:when test="$full = 1">
      <!-- We need two anchors, 1 for internal links, 1 for cross-chapters links -->
      <a name="book_{generate-id(../../..)}_chap{$chpos}_sect{$pos}"/>
      <a name="book_part{$partnum}_chap{$chapnum}__chap{$chpos}_sect{$pos}"/>
    </xsl:when>
    <xsl:otherwise>
      <a name="doc_chap{$chpos}_sect{$pos}" />
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="@id">
    <a name= "{@id}"/>
  </xsl:if>
  <p class="secthead"><xsl:value-of select="title" /></p>
  <xsl:apply-templates select="body" />
</xsl:template>

<!--<xsl:include href="inserts.xsl" />-->
<func:function name="func:gettext">
  <xsl:param name="str"/>
  <xsl:param name="PLANG"/>
  
  <xsl:variable name="LANG">
    <xsl:choose>
      <xsl:when test="$PLANG"><xsl:value-of select="$PLANG"/></xsl:when>
      <xsl:when test="$glang"><xsl:value-of select="$glang"/></xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="contains('|ca|cs|da|de|el|en|es|fi|fr|id|it|ko|lt|pl|pt_br|ro|ru|sr|sv|tr|vi|zh_tw|',concat('|', $LANG,'|'))">
      <xsl:variable name="insert" select="exslt:node-set($Inserts)/inserts[@lang=$LANG]/insert[@name=$str]"/>
      <xsl:choose>
        <xsl:when test="$insert">
          <func:result select="$insert"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="insert-en" select="exslt:node-set($Inserts)/inserts[@lang='en']/insert[@name=$str]"/>
          <xsl:choose>
            <xsl:when test="$insert-en">
              <func:result select="$insert-en"/>
            </xsl:when>
            <xsl:otherwise>
              <func:result select="'UNDEFINED STRING'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="insert-en" select="exslt:node-set($Inserts)/inserts[@lang='en']/insert[@name=$str]"/>
      <xsl:choose>
        <xsl:when test="$insert-en">
          <func:result select="$insert-en" />
        </xsl:when>
        <xsl:otherwise>
          <func:result select="'UNDEFINED STRING'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</func:function>


<!-- D A T E   F O R M A T T I N G   R O U T I N E S -->

<func:function name="func:format-date">
  <xsl:param name="datum" />
  <xsl:param name="lingua" select="$glang"/>

  <xsl:variable name="NormlzD"><xsl:value-of select="normalize-space($datum)"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="func:is-date($NormlzD)='YES'">
      <xsl:variable name="Y"><xsl:value-of select="number(substring($NormlzD,1,4))"/></xsl:variable>
      <xsl:variable name="M"><xsl:value-of select="number(substring($NormlzD,6,2))"/></xsl:variable>
      <xsl:variable name="D"><xsl:value-of select="number(substring($NormlzD,9,2))"/></xsl:variable>
      <xsl:choose>
        <!-- Formatting per language happens here -->

        <!-- For complex and/or repeated cases, better use a dedicated function -->

        <!-- RFC-822 -->
        <xsl:when test="$lingua='RFC822'">
          <func:result select="func:format-date-rfc822($mensis, $Y, $M, $D)"/>
        </xsl:when>

        <!-- English -->
        <xsl:when test="$lingua='en'">
          <func:result select="func:format-date-en($mensis, $Y, $M, $D)"/>
        </xsl:when>

        <!-- Danish / German / Finnish / Serbian -->
        <xsl:when test="$lingua='da' or $lingua='de' or $lingua='fi' or $lingua='cs' or $lingua='sr'">
          <func:result select="concat($D, '. ', exslt:node-set($mensis)//months[@lang=$lingua]/month[position()=$M], ' ', $Y)"/>
        </xsl:when>

        <!-- Spanish -->
        <xsl:when test="$lingua='es' or $lingua='ca'">
          <func:result select="concat($D, ' de ', exslt:node-set($mensis)//months[@lang=$lingua]/month[position()=$M], ', ', $Y)"/>
        </xsl:when>
        
        <!-- Brazilian Portuguese -->
        <xsl:when test="$lingua='pt_br'">
          <func:result select="concat($D, ' de ', exslt:node-set($mensis)//months[@lang=$lingua]/month[position()=$M], ' de ', $Y)"/>
        </xsl:when>
        
        <!-- Hungarian -->
        <xsl:when test="$lingua='hu'">
          <func:result select="concat($Y, '. ', exslt:node-set($mensis)//months[@lang=$lingua]/month[position()=$M], ' ', $D, '.')"/>
        </xsl:when>

        <!-- Chinese / Japanese -->
        <xsl:when test="$lingua='zh_cn' or $lingua='zh_tw' or $lingua='ja'">
          <func:result select="concat($Y, '年 ', $M, '月 ', $D, '日 ')"/>
        </xsl:when>

        <!-- Korean -->
        <xsl:when test="$lingua='ko'">
          <func:result select="concat($Y, '년 ', $M, '월 ', $D, '일')"/>
        </xsl:when>

        <!-- French -->
        <xsl:when test="$lingua='fr'">
          <func:result select="func:format-date-fr($mensis, $Y, $M, $D)" />
        </xsl:when>

        <!-- Lithuanian -->
        <xsl:when test="$lingua='lt'">
          <func:result select="concat($Y, ' ', exslt:node-set($mensis)//months[@lang=$lingua]/month[position()=$M], ' ', $D)"/>
        </xsl:when>

        <!-- Dutch / Greek / Indonesian / Italian / Polish / Romanian / Russian / Swedish / Turkish / Vietnamese -->
        <xsl:when test="$lingua='nl' or $lingua='el' or $lingua='id' or $lingua='it' or $lingua='pl' or $lingua='ro' or $lingua='ru' or $lingua='sv' or $lingua='tr' or $lingua='vi'">
          <func:result select="concat($D, ' ', exslt:node-set($mensis)//months[@lang=$lingua]/month[position()=$M], ' ', $Y)"/>
        </xsl:when>

        <xsl:otherwise> <!-- Default to English -->
          <func:result select="func:format-date-en($mensis, $Y, $M, $D)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <func:result select="$datum" />
    </xsl:otherwise>
  </xsl:choose>
</func:function>

<!-- Validate date, 1000<=YYYY<=9999, 01<=MM<=12, 01<=DD<={days in month} -->
<func:function name="func:is-date">
  <xsl:param name="YMD" />

  <func:result>
    <xsl:if test="string-length($YMD)=10 and substring($YMD,5,1)='-' and substring($YMD,8,1)='-' and contains('|01|02|03|04|05|06|07|08|09|10|11|12|',concat('|',substring($YMD,6,2),'|'))">
      <xsl:variable name="Y"><xsl:value-of select="number(substring($YMD,1,4))"/></xsl:variable>
      <xsl:variable name="M"><xsl:value-of select="number(substring($YMD,6,2))"/></xsl:variable>
      <xsl:variable name="D"><xsl:value-of select="number(substring($YMD,9,2))"/></xsl:variable>
      <xsl:if test="$Y &gt;= 1000 and $Y &lt;= 9999 and $D &gt;= 1 and $D &lt;= 31">
        <xsl:choose>
          <xsl:when test="$M=4 or $M=6 or $M=9 or $M=11">
            <xsl:if test="$D&lt;=30">YES</xsl:if>
          </xsl:when>
          <xsl:when test="$M=2 and ((($Y mod 4 = 0) and ($Y mod 100 != 0))  or  ($Y mod 400 = 0))">
            <xsl:if test="$D&lt;=29">YES</xsl:if>
          </xsl:when>
          <xsl:when test="$M=2">
            <xsl:if test="$D&lt;=28">YES</xsl:if>
          </xsl:when>
          <xsl:otherwise>YES</xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </func:result>
</func:function>

<!-- Format date according to RFC822, time is set to 00:00:00 UTC,
     Day of the week is optional, we do not output it
     RFC says YY but YYYY is widely accepted
  -->
<func:function name="func:format-date-rfc822">
  <xsl:param name="mensis" />
  <xsl:param name="Y" />
  <xsl:param name="M" />
  <xsl:param name="D" />
  <func:result select="concat($D, ' ', substring(exslt:node-set($mensis)//months[@lang='en']/month[position()=$M],1,3), ' ', $Y, ' 00:00:00 GMT')" />
</func:function>

<!-- Format date in  ENGLISH -->
<func:function name="func:format-date-en">
  <xsl:param name="mensis" />
  <xsl:param name="Y" />
  <xsl:param name="M" />
  <xsl:param name="D" />
  <func:result select="concat(exslt:node-set($mensis)//months[@lang='en']/month[position()=$M], ' ', $D, ', ', $Y)" />
</func:function>

<!-- Format date in  FRENCH -->
<func:function name="func:format-date-fr">
  <xsl:param name="mensis" />
  <xsl:param name="Y" />
  <xsl:param name="M" />
  <xsl:param name="D" />
  <func:result>
    <xsl:value-of select="$D"/>
    <xsl:if test="$D=1"><sup>er</sup></xsl:if>
    <xsl:value-of select="concat(' ', exslt:node-set($mensis)//months[@lang='fr']/month[position()=$M], ' ', $Y)"/>
  </func:result>
</func:function>




<!-- Define some globals that can be used throughout the stylesheets -->

<!-- Top element name e.g. "book" -->
<xsl:param name="TTOP"><xsl:value-of select="name(//*[1])" /></xsl:param>

<!-- Value of top element's link attribute e.g. "handbook.xml" -->
<xsl:param name="LINK"><xsl:value-of select="//*[1]/@link" /></xsl:param>

<!-- Value of top element's lang attribute e.g. "pt_br" -->
<xsl:param name="glang"><xsl:value-of select="//*[1]/@lang" /></xsl:param>


<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<!-- When using <pre>, whitespaces should be preserved -->
<xsl:preserve-space elements="pre"/>

<!-- Global definition of style parameter -->
<xsl:param name="style">0</xsl:param>
<xsl:param name="newsitemcount">6</xsl:param>

<!-- Category from metadoc -->
<xsl:param name="catid">0</xsl:param>


<!-- img tag -->
<xsl:template match="img">
  <img src="{@src}" alt=""/>
</xsl:template>

<xsl:template name="show-disclaimer">
  <!-- Disclaimer stuff -->
  <xsl:if test="/*[1][@disclaimer] or /*[1][@redirect]">
    <table class="ncontent" align="center" width="90%" border="1px" cellspacing="0" cellpadding="4px">
      <tr>
        <td bgcolor="#ddddff">
          <p class="note">
            <xsl:if test="/*[1][@disclaimer]">
              <b><xsl:value-of select="func:gettext('disclaimer')"/>: </b>
              <xsl:apply-templates select="func:gettext(/*[1]/@disclaimer)"/>
            </xsl:if>
            <xsl:if test="/*[1][@redirect]">
              <xsl:apply-templates select="func:gettext('redirect')">
                <xsl:with-param name="paramlink" select="/*[1]/@redirect"/>
              </xsl:apply-templates>
            </xsl:if>
          </p>
        </td>
      </tr>
    </table>
  </xsl:if>
</xsl:template>


<!-- Content of /guide -->
<xsl:template name="guidecontent">
  <xsl:if test="$style != 'printable'">
    <br />
  </xsl:if>

  <h1>
    <xsl:choose>
      <xsl:when test="/guide/subtitle"><xsl:value-of select="/guide/title"/>: <xsl:value-of select="/guide/subtitle"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="/guide/title"/></xsl:otherwise>
    </xsl:choose>
  </h1>

  <xsl:choose>
    <xsl:when test="$style = 'printable'">
      <xsl:apply-templates select="author" />
      <br/>
      <i><xsl:call-template name="contentdate"/></i>
    </xsl:when>
    <xsl:otherwise>
     <xsl:if test="count(/guide/chapter)&gt;1">
      <form name="contents" action="http://www.gentoo.org">
        <b><xsl:value-of select="func:gettext('Content')"/></b>:
        <select name="url" size="1" OnChange="location.href=form.url.options[form.url.selectedIndex].value" style="font-family:sans-serif,Arial,Helvetica">
          <xsl:for-each select="chapter">
            <xsl:variable name="chapid">doc_chap<xsl:number/></xsl:variable><option value="#{$chapid}"><xsl:number/>. <xsl:value-of select="title"/></option>
          </xsl:for-each>
        </select>
      </form>
     </xsl:if>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
    <xsl:when test="/guide">
      <xsl:apply-templates select="chapter"/>
    </xsl:when>
    <xsl:when test="/sections">
      <xsl:apply-templates select="/sections/section"/>
    </xsl:when>
  </xsl:choose>
  <br/>
  <xsl:if test="/guide/license">
    <xsl:apply-templates select="license" />
  </xsl:if>
  <br/>
</xsl:template>

<!-- Layout for documentation -->
<xsl:template name="doclayout">
<html>
  <xsl:if test="string-length($glang)>1">
    <xsl:attribute name="lang"><xsl:value-of select="translate($glang,'_','-')"/></xsl:attribute>
  </xsl:if>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <link title="new" rel="stylesheet" href="css/main.css" type="text/css"/>
  <link REL="shortcut icon" HREF="http://www.gentoo.org/favicon.ico" TYPE="image/x-icon"/>
    <!-- Just remove this bit if http refresh is too annoying -->
      <xsl:if test="/*[1][@redirect]">
        <meta http-equiv="Refresh">
          <xsl:attribute name="content"><xsl:value-of select="concat('15; URL=', /*[1]/@redirect)"/></xsl:attribute>
        </meta>
      </xsl:if>    

<title>
  <xsl:choose>
    <xsl:when test="/guide/@type='project'">Gentoo Linux Projects</xsl:when>
    <xsl:when test="/guide/@type='newsletter'">Gentoo Linux Newsletter</xsl:when>
    <xsl:when test="/sections">Gentoo Linux Handbook Page</xsl:when>
    <xsl:otherwise><xsl:value-of select="func:gettext('GLinuxDoc')"/></xsl:otherwise>
  </xsl:choose>
--
  <xsl:choose>
    <xsl:when test="subtitle"><xsl:if test="/guide/@type!='newsletter'"><xsl:value-of select="title"/>:</xsl:if> <xsl:value-of select="subtitle"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="title"/></xsl:otherwise>
  </xsl:choose>
</title>

</head>
<xsl:choose>
  <xsl:when test="$style = 'printable'">
    <!-- Insert the node-specific content -->
<body bgcolor="#ffffff">
    <xsl:call-template name="show-disclaimer"/>
    <xsl:call-template name="content"/>
</body>
  </xsl:when>
  <xsl:otherwise>
<body style="margin:0px;" bgcolor="#ffffff">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top" height="125" bgcolor="#45347b">
    <a href="http://www.gentoo.org/"><img border="0" src="images/gtop-www.jpg" alt="Gentoo Logo"/></a>
    </td>
  </tr>
  <tr>
    <td valign="top" align="right" colspan="1" bgcolor="#ffffff">
      <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr>
          <td width="99%" class="content" valign="top" align="left">
            <!-- Insert the node-specific content -->
            <xsl:call-template name="show-disclaimer"/>
            <xsl:call-template name="content"/>
          </td>
          <td width="1%" bgcolor="#dddaec" valign="top">
            <xsl:call-template name="rhcol"/>
          </td>
        </tr>
      </table>
    </td>
  </tr>
  <tr>
    <td colspan="2" align="right" class="infohead">
      Copyright 2001-2006 Gentoo Foundation.
    </td>
  </tr>
</table>

</body>
  </xsl:otherwise>
  </xsl:choose>
</html>
</xsl:template>

<!-- Guide template -->
<xsl:template match="/guide">
<xsl:call-template name="doclayout" />
</xsl:template>

<!-- {Mainpage, News, Email} template -->
<xsl:template match="/mainpage | /news | /email">
<html>
  <xsl:if test="string-length($glang)>1">
    <xsl:attribute name="lang"><xsl:value-of select="translate($glang,'_','-')"/></xsl:attribute>
  </xsl:if>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <link title="new" rel="stylesheet" href="css/main.css" type="text/css"/>
  <link REL="shortcut icon" HREF="http://www.gentoo.org/favicon.ico" TYPE="image/x-icon"/>
  
  <xsl:if test="/mainpage/@id='news'">
    <link rel="alternate" type="application/rss+xml" title="Gentoo Linux News RDF" href="http://www.gentoo.org/rdf/en/gentoo-news.rdf" />
  </xsl:if>
  <xsl:choose>
    <xsl:when test="/mainpage | /news">
      <title>Gentoo Linux -- <xsl:value-of select="title"/></title>
    </xsl:when>
    <xsl:when test="/email">
      <title><xsl:value-of select="subject"/></title>
    </xsl:when>
  </xsl:choose>
</head>
<body style="margin:0px;" bgcolor="#000000">

<table border="0" width="100%" cellspacing="0" cellpadding="0">
  <tr>
    <td valign="top" height="125" width="1%" bgcolor="#45347b">
    <a href="http://www.gentoo.org/"><img border="0" src="images/gtop-www.jpg" alt="Gentoo Logo"/></a>
    </td>

    <td valign="bottom" align="left" bgcolor="#000000" colspan="2" lang="en">
      <p class="menu">
        <xsl:choose>
          <xsl:when test="/mainpage/@id='about'">
            <a class="highlight" href="http://www.gentoo.org/main/en/about.xml">About</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/main/en/about.xml">About</a>
          </xsl:otherwise>
        </xsl:choose>
        |
        <xsl:choose>
          <xsl:when test="/mainpage/@id='projects'">
            <a class="highlight" href="http://www.gentoo.org/proj/en/index.xml?showlevel=1">Projects</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/proj/en/index.xml?showlevel=1">Projects</a>
          </xsl:otherwise>
        </xsl:choose>
        |
        <xsl:choose>
          <xsl:when test="/mainpage/@id='docs'">
            <a class="highlight" href="http://www.gentoo.org/doc/en/index.xml">Docs</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/doc/en/index.xml">Docs</a>
          </xsl:otherwise>
        </xsl:choose>
        | <a class="menulink" href="http://forums.gentoo.org">Forums</a>
        |
        <xsl:choose>
          <xsl:when test="/mainpage/@id='lists'">
            <a class="highlight" href="http://www.gentoo.org/main/en/lists.xml">Lists</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/main/en/lists.xml">Lists</a>
          </xsl:otherwise>
        </xsl:choose>
        | <a class="menulink" href="http://bugs.gentoo.org">Bugs</a>
        | <a class="menulink" href="http://www.cafepress.com/officialgentoo/">Store</a>
        |
        <xsl:choose>
          <xsl:when test="/mainpage/@id='newsletter'">
            <a class="highlight" href="http://www.gentoo.org/news/en/gwn/gwn.xml"> GWN</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/news/en/gwn/gwn.xml"> GWN</a>
          </xsl:otherwise>
        </xsl:choose>
        |
        <xsl:choose>
          <xsl:when test="/mainpage/@id='where'">
            <a class="highlight" href="http://www.gentoo.org/main/en/where.xml">Get Gentoo!</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/main/en/where.xml">Get Gentoo!</a>
          </xsl:otherwise>
        </xsl:choose>
        |
        <xsl:choose>
          <xsl:when test="/mainpage/@id='support'">
            <a class="highlight" href="http://www.gentoo.org/main/en/support.xml">Support</a> 
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/main/en/support.xml">Support</a> 
          </xsl:otherwise>
        </xsl:choose>
        |
        <xsl:choose>
          <xsl:when test="/mainpage/@id='sponsors'">
            <a class="highlight" href="http://www.gentoo.org/main/en/sponsors.xml">Sponsors</a>
          </xsl:when>
          <xsl:otherwise>
            <a class="menulink" href="http://www.gentoo.org/main/en/sponsors.xml">Sponsors</a>
          </xsl:otherwise>
        </xsl:choose>
        | <a class="menulink" href="http://planet.gentoo.org">Planet</a>
      </p>
    </td>
  </tr>
  <tr>
    <td valign="top" align="right" width="1%" bgcolor="#dddaec">
      <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tr>
          <td height="1%" valign="top" align="right">
            <img src="images/gridtest.gif" alt="Gentoo Spaceship"/>
          </td>
        </tr>
        <tr>
          <td height="99%" valign="top" align="left">
            <!--info goes here-->
            <table cellspacing="0" cellpadding="5" border="0">
              <tr>
                <td valign="top" class="leftmenu" lang="en">
                  <p class="altmenu">
                    Installation:
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/doc/en/handbook/index.xml">Gentoo Handbook</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/doc/en/index.xml?catid=install#doc_chap2">Installation Docs</a>
                   <br/><br/>
                    Documentation:
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/doc/en/">Home</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/doc/en/list.xml">Listing</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/about.xml">About Gentoo</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/philosophy.xml">Philosophy</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/contract.xml">Social Contract</a>
                    <br/><br/>
                    Resources:
                    <br/>
                    <a class="altlink" href="http://bugs.gentoo.org">Bug Tracker</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/proj/en/devrel/roll-call/userinfo.xml">Developer List</a>
                    <br/>
                    <a class="altlink" href="http://forums.gentoo.org">Discussion Forums</a>
                    <br/>
                    <a class="altlink" href="http://tracker.netdomination.org/">Gentoo BitTorrents</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/proj/en/glep/">Gentoo Linux Enhancement Proposals</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/irc.xml">IRC Channels</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/lists.xml">Mailing Lists</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/mirrors.xml">Mirrors</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/name-logo.xml">Name and Logo Guidelines</a>
                    <br/>
                    <a class="altlink" href="http://packages.gentoo.org/">Online Package Database</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/security/en/index.xml">Security Announcements</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/proj/en/devrel/staffing-needs/">Staffing Needs</a>
                    <br/>
             		    <a class="altlink" href="http://vendors.gentoo.org/">Supporting Vendors</a>
		    <br/>
                    <a class="altlink" href="http://viewcvs.gentoo.org/">View our CVS</a>
                    <br/><br/>
                    Graphics:
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/graphics.xml">Logos and themes</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/dyn/icons.xml">Icons</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/shots.xml">ScreenShots</a>
                    <br/><br/>
                    Miscellaneous Resources:
                    <br/>
                    <a class="altlink" href="http://www.cafepress.com/officialgentoo/">Gentoo Linux Store</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/projects.xml">Gentoo-hosted projects</a>
                    <br/>
                    <a class="altlink" href="http://www.gentoo.org/main/en/articles.xml">IBM dW/Intel article archive</a>
                    <xsl:if test="/mainpage/@id='news'">
                    <br/><br/>
                      Older News:<br/>
                      <xsl:for-each select="document('http://www.gentoo.org/dyn/news-index.xml?passthru=1')/uris/uri[position()&gt;$newsitemcount][position()&lt;20]/text()">
                        <xsl:variable name="newsuri" select="."/>
                        <a class="altlink" href="http://www.gentoo.org{$newsuri}"><xsl:value-of select="document(concat('http://www.gentoo.org',.,'?passthru=1'))/news/title"/></a>
                        <br/>
                      </xsl:for-each>
                    </xsl:if>
                  </p>
                  <br/><br />
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </td>
    <!-- Content below top menu and between left menu and ads -->
    <td valign="top" bgcolor="#ffffff">
            <xsl:choose>
              <xsl:when test="/mainpage/@id='news'">
              <p class="news">
                <img class="newsicon" src="images/gentoo-new.gif" alt="Gentoo logo"/>
                <span class="newsitem" lang="en">We produce Gentoo Linux, a special flavor of Linux that
                can be automatically optimized and customized for just
                about any application or need. Extreme performance,
                configurability and a top-notch user and developer
                community are all hallmarks of the Gentoo experience.
                To learn more, read our <b><a href="http://www.gentoo.org/main/en/about.xml">about
                page</a></b>.</span>
              </p>
              <xsl:for-each select="document('http://www.gentoo.org/dyn/news-index.xml?passthru=1')/uris/uri[position()&lt;=$newsitemcount]/text()">
                <xsl:call-template name="newscontent">
                  <xsl:with-param name="thenews" select="document(concat('http://www.gentoo.org',.,'?passthru=1'))/news"/>
                  <xsl:with-param name="summary" select="'yes'"/>
                  <xsl:with-param name="link" select="."/>
                </xsl:call-template>
              </xsl:for-each>
              </xsl:when>
              <xsl:when test="/news">
                <xsl:call-template name="newscontent">
                  <xsl:with-param name="thenews" select="/news"/>
                  <xsl:with-param name="summary" select="no"/>
                </xsl:call-template>
              </xsl:when>
            </xsl:choose>
            <br/>
            <table border="0" class="content">
              <tr>
                <td>
                  <xsl:apply-templates select="chapter"/>
                </td>
              </tr>
            </table>
            <br/>
            <xsl:if test="/mainpage/license">
              <xsl:apply-templates select="license" />
            </xsl:if>
            <br/>
            <!--content end-->
    </td>
    <td width="1%" bgcolor="#dddaec" valign="top">
      <xsl:call-template name="rhcol"/>
    </td>
  </tr>
  <tr lang="en">
    <td align="right" class="infohead" colspan="3">
      Copyright 2001-2006 Gentoo Foundation.
    </td>
  </tr>
</table>

</body>
</html>
</xsl:template>

<!-- Mail template -->
<xsl:template match="mail">
<a>
 <xsl:attribute name="href">
   <xsl:choose>
    <xsl:when test="@link">
      <xsl:value-of select="concat('mailto:', @link)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('mailto:', .)"/>
    </xsl:otherwise>
   </xsl:choose>
 </xsl:attribute>
 <xsl:value-of select="."/>
</a>

</xsl:template>

<!-- Mail inside <author>...</author> -->
<xsl:template match="/guide/author/mail|/book/author/mail">
<b>
  <a class="altlink" href="mailto:{@link}"><xsl:value-of select="."/></a>
</b>
</xsl:template>

<!-- Author -->
<xsl:template match="author">
<xsl:apply-templates/>
  <xsl:if test="@title">
    <xsl:if test="$style != 'printable'">
      <br/>
    </xsl:if>
    <xsl:if test="$style = 'printable'">&#160;</xsl:if>
    <i><xsl:value-of select="@title"/></i>
  </xsl:if>
  <br/>
  <xsl:if test="$style != 'printable' and position()!=last()">
    <br/>
  </xsl:if>
</xsl:template>

<!-- Chapter -->
<xsl:template match="chapter">
<xsl:variable name="chid"><xsl:number/></xsl:variable>
<xsl:choose>
  <xsl:when test="title">
    <p class="chaphead">
      <xsl:if test="@id">
        <a name="{@id}"/>
      </xsl:if>
      <span class="chapnum">
        <a name="doc_chap{$chid}"><xsl:number/>. </a>
      </span>
      <xsl:value-of select="title"/>
    </p>
  </xsl:when>
  <xsl:otherwise>
    <xsl:if test="/guide">
      <p class="chaphead">
        <span class="chapnum">
          <a name="doc_chap{$chid}"><xsl:number/>.</a>
        </span>
      </p>
    </xsl:if>
  </xsl:otherwise>
</xsl:choose>
<xsl:apply-templates select="body">
  <xsl:with-param name="chid" select="$chid"/>
</xsl:apply-templates>
<xsl:apply-templates select="section">
  <xsl:with-param name="chid" select="$chid"/>
</xsl:apply-templates>
</xsl:template>


<!-- Section template -->
<xsl:template match="section">
<xsl:param name="chid"/>
<xsl:if test="title">
  <xsl:variable name="sectid">doc_chap<xsl:value-of select="$chid"/>_sect<xsl:number/></xsl:variable>
  <xsl:if test="@id">
    <a name="{@id}"/>
  </xsl:if>
  <p class="secthead">
    <a name="{$sectid}"><xsl:value-of select="title"/></a>
  </p>
</xsl:if>
<xsl:apply-templates select="body">
  <xsl:with-param name="chid" select="$chid"/>
</xsl:apply-templates>
</xsl:template>

<!-- Figure template -->
<xsl:template match="figure">
<xsl:param name="chid"/>
<xsl:variable name="fignum"><xsl:number level="any" from="chapter" count="figure"/></xsl:variable>
<xsl:variable name="figid">doc_chap<xsl:value-of select="$chid"/>_fig<xsl:value-of select="$fignum"/></xsl:variable>
<xsl:variable name="llink">
  <xsl:choose>
    <xsl:when test="starts-with(@link,'/')">
      <xsl:value-of select="concat('http://www.gentoo.org', @link)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@link"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<br/>
<a name="{$figid}"/>
<table cellspacing="0" cellpadding="0" border="0">
  <tr>
    <td bgcolor="#7a5ada">
      <p class="codetitle">
        <xsl:choose>
          <xsl:when test="@caption">
            <xsl:value-of select="func:gettext('Figure')"/>&#160;<xsl:value-of select="$chid"/>.<xsl:value-of select="$fignum"/><xsl:value-of select="func:gettext('SpaceBeforeColon')"/>: <xsl:value-of select="@caption"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="func:gettext('Figure')"/>&#160;<xsl:value-of select="$chid"/>.<xsl:value-of select="$fignum"/>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </td>
  </tr>
  <tr>
    <td align="center" bgcolor="#ddddff">
      <xsl:choose>
        <xsl:when test="@short">
          <img src="{$llink}" alt="Fig. {$fignum}: {@short}"/>
        </xsl:when>
        <xsl:otherwise>
          <img src="{$llink}" alt="Fig. {$fignum}"/>
        </xsl:otherwise>
      </xsl:choose>
    </td>
  </tr>
</table>
<br/>
</xsl:template>

<!--figure without a caption; just a graphical element-->
<xsl:template match="fig">
<xsl:variable name="llink">
  <xsl:choose>
    <xsl:when test="starts-with(@link,'/')">
      <xsl:value-of select="concat('http://www.gentoo.org', @link)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="@link"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<center>
  <xsl:choose>
    <xsl:when test="@linkto">
      <a href="{@linkto}"><img border="0" src="{$llink}" alt="{@short}"/></a>
    </xsl:when>
    <xsl:otherwise>
      <img src="{$llink}" alt="{@short}"/>
    </xsl:otherwise>
  </xsl:choose>
</center>
</xsl:template>

<!-- Line break -->
<xsl:template match="br">
<br/>
</xsl:template>

<!-- Note -->
<xsl:template match="note">
<table class="ncontent" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td bgcolor="#bbffbb">
      <p class="note">
        <b><xsl:value-of select="func:gettext('Note')"/>: </b>
        <xsl:apply-templates/>
      </p>
    </td>
  </tr>
</table>
</xsl:template>

<!-- Important item -->
<xsl:template match="impo">
<table class="ncontent" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td bgcolor="#ffffbb">
      <p class="note">
        <b><xsl:value-of select="func:gettext('Important')"/>: </b>
        <xsl:apply-templates/>
      </p>
    </td>
  </tr>
</table>
</xsl:template>

<!-- Warning -->
<xsl:template match="warn">
<table class="ncontent" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td bgcolor="#ffbbbb">
      <p class="note">
        <b><xsl:value-of select="func:gettext('Warning')"/>: </b>
        <xsl:apply-templates/>
      </p>
    </td>
  </tr>
</table>
</xsl:template>

<!-- Code note -->
<xsl:template match="codenote">
<span class="comment">
  <xsl:if test='not(starts-with(., "("))'>(</xsl:if>
  <xsl:apply-templates/>
  <xsl:if test='not(starts-with(., "("))'>)</xsl:if>
</span>
</xsl:template>

<!-- Regular comment -->
<xsl:template match="comment">
<span class="comment">
  <xsl:apply-templates/>
</span>
</xsl:template>

<!-- User input -->
<xsl:template match="i">
<span class="input"><xsl:apply-templates/></span>
</xsl:template>

<!-- Bold -->
<xsl:template match="b">
<b><xsl:apply-templates/></b>
</xsl:template>

<!-- Superscript -->
<xsl:template match="sup">
  <sup><xsl:apply-templates/></sup>
</xsl:template>

<!-- Subscript -->
<xsl:template match="sub">
  <sub><xsl:apply-templates/></sub>
</xsl:template>

<!-- Brite -->
<xsl:template match="brite">
<font color="#ff0000">
  <b><xsl:apply-templates/></b>
</font>
</xsl:template>

<!-- Body -->
<xsl:template match="body">
<xsl:param name="chid"/>
<xsl:apply-templates>
  <xsl:with-param name="chid" select="$chid"/>
</xsl:apply-templates>
</xsl:template>

<!-- Command or input, not to use inside <pre> -->
<xsl:template match="c">
<span class="code"><xsl:apply-templates/></span>
</xsl:template>

<!-- Box with small text -->
<xsl:template match="box">
<p class="infotext"><xsl:apply-templates/></p>
</xsl:template>

<!-- Preserve whitespace, aka Code Listing -->
<xsl:template match="pre">
<xsl:param name="chid"/>
<xsl:variable name="prenum"><xsl:number level="any" from="chapter" count="pre"/></xsl:variable>
<xsl:variable name="preid">doc_chap<xsl:value-of select="$chid"/>_pre<xsl:value-of select="$prenum"/></xsl:variable>
<a name="{$preid}"/>
<table class="ntable" width="100%" cellspacing="0" cellpadding="0" border="0">
  <tr>
    <td bgcolor="#7a5ada">
      <p class="codetitle">
      <xsl:value-of select="func:gettext('CodeListing')"/>&#160;<xsl:if test="$chid"><xsl:value-of select="$chid"/>.</xsl:if><xsl:value-of select="$prenum"/>
      <xsl:if test="@caption">
        <xsl:value-of select="func:gettext('SpaceBeforeColon')"/>: <xsl:value-of select="@caption"/>
      </xsl:if>
      </p>
    </td>
  </tr>
  <tr>
    <td bgcolor="#ddddff">
      <pre>
        <xsl:apply-templates/>
      </pre>
    </td>
  </tr>
</table>
</xsl:template>

<!-- Path -->
<xsl:template match="path">
<span class="path"><xsl:value-of select="."/></span>
</xsl:template>

<!-- Url -->
<xsl:template match="uri">
<xsl:param name="paramlink"/>
<!-- expand templates to handle things like <uri link="http://bar"><c>foo</c></uri> -->
<xsl:choose>
  <xsl:when test="@link">
    <xsl:choose>
      <xsl:when test="($TTOP = 'sections') and (starts-with(@link, '?'))">
        <!-- Handbook link pointing to another part/chapter when viewing a single page,
             cannot be a link because we have no idea where to link to
             Besides, we have no way of knowing the language unless told via a param -->
          <xsl:variable name="nolink"><xsl:value-of select="func:gettext('hb_file', $glang)"/></xsl:variable>
          <span title="{$nolink}"><font color="#404080">(<xsl:apply-templates/>)</font></span>
      </xsl:when>
      <xsl:when test="($TTOP = 'book') and ($full = 0) and (starts-with(@link, '?'))">
        <!-- Handbook link pointing to another part/chapter, normal case -->
        <xsl:choose>
          <xsl:when test="$style != 'printable'">
            <a href="{@link}"><xsl:apply-templates/></a>
          </xsl:when>
          <xsl:otherwise>
            <a href="{@link}&amp;style=printable"><xsl:apply-templates/></a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="($TTOP = 'book') and ($full = 1) and (starts-with(@link, '?'))">
        <!-- Handbook link pointing to another part/chapter
             Handbook is being rendered in a single page (full=1)
             Hence link needs to be rewritten as a local one
             i.e. ?part=1&chap=3#doc_chap1 must become #book_part1_chap3__chap1   Case 1a
             i.e. ?part=1&chap=3#anID      must become #anID                      Case 1b
             or   ?part=1&chap=3           must become #book_part1_chap3          Case 2
             or   ?part=2                  must become #book_part2                Case 3-->
        <xsl:choose>
          <xsl:when test="contains(@link, 'chap=') and contains(@link, '#doc_')">
            <!-- Link points inside a chapter  (Case 1a)-->
            <xsl:param name="linkpart" select="substring-after(substring-before(@link, '&amp;'), '=')" />
            <xsl:param name="linkchap" select="substring-before(substring-after(substring-after(@link, '&amp;'), '='), '#doc_')" />
            <xsl:param name="linkanch" select="substring-after(@link, '#doc_')" />
            <a href="#book_part{$linkpart}_chap{$linkchap}__{$linkanch}"><xsl:apply-templates /></a>
          </xsl:when>
          <xsl:when test="contains(@link, 'chap=') and contains(@link, '#')">
            <!-- Link points inside a chapter via an ID (Case 1b)
                 (IDs are expected to be unique throughout a handbook) -->
            <xsl:param name="linkanch" select="substring-after(@link, '#')" />
            <a href="#{$linkanch}"><xsl:apply-templates /></a>
          </xsl:when>
          <xsl:when test="contains(@link, 'chap=')">
            <!-- Link points to a chapter  (Case 2)-->
            <xsl:param name="linkpart" select="substring-after(substring-before(@link, '&amp;'), '=')" />
            <xsl:param name="linkchap" select="substring-after(substring-after(@link, '&amp;'), '=')" />
            <a href="#book_part{$linkpart}_chap{$linkchap}"><xsl:apply-templates /></a>
          </xsl:when>
          <xsl:otherwise>
            <!-- Link points to a part  (Case 3)-->
            <xsl:param name="linkpart" select="substring-after(@link, '=')" />
            <a href="#book_part{$linkpart}"><xsl:apply-templates/></a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="($TTOP = 'book') and ($full = 1) and (starts-with(@link, '#'))">
        <!-- Handbook link pointing to another place in same part/chapter
             Handbook is being rendered in a single page (full=1)
             Hence link needs to be rewritten as an internal one that is unique
             for the whole handbook, i.e.
             #doc_part1_chap3 becomes #book_{UNIQUEID}_part1_chap3, but
             #anything_else_like_an_ID is left unchanged (IDs are expected to be unique throughout a handbook)-->
        <xsl:choose>
          <xsl:when test="starts-with(@link, '#doc_')">
            <xsl:param name="locallink" select="substring-after(@link, 'doc_')" />
            <a href="#book_{generate-id(/)}_{$locallink}"><xsl:apply-templates /></a>
          </xsl:when>
          <xsl:otherwise>
            <a href="{@link}"><xsl:apply-templates/></a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="theurl">
          <xsl:choose>
            <xsl:when test="@link"><xsl:value-of select="@link" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="text()" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="thelink">
          <xsl:choose>
            <xsl:when test="name(..)='insert' and $theurl='$redirect' and $paramlink"><xsl:value-of select="$paramlink" /></xsl:when>
            <xsl:when test="name(..)='insert' and $theurl='$originalversion' and $paramlink">
              <xsl:variable name="temp">
                <xsl:value-of select="$paramlink"/>
                <xsl:if test="$style = 'printable'">&amp;style=printable</xsl:if>
                <xsl:if test="$full != '0'">&amp;full=1</xsl:if>
                <xsl:if test="$part != '0'">&amp;part=<xsl:value-of select="$part"/></xsl:if>
                <xsl:if test="$chap != '0'">&amp;chap=<xsl:value-of select="$chap"/></xsl:if>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="contains($temp, '&amp;')">
                  <xsl:value-of select="concat(substring-before($temp,'&amp;'), '?', substring-after($temp,'&amp;'))"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$temp"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$theurl" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="llink">
          <xsl:choose>
            <xsl:when test="starts-with($thelink, 'http://www.gentoo.org/cgi-bin/viewcvs.cgi')"><xsl:value-of select="concat('http://sources.gentoo.org', substring-after($thelink, 'http://www.gentoo.org/cgi-bin/viewcvs.cgi'))" /></xsl:when>
            <xsl:when test="starts-with($thelink, '/cgi-bin/viewcvs.cgi')"><xsl:value-of select="concat('http://sources.gentoo.org', substring-after($thelink, '/cgi-bin/viewcvs.cgi'))" /></xsl:when>
            <xsl:when test="starts-with($thelink, '/')"><xsl:value-of select="concat('http://www.gentoo.org', $thelink)" /></xsl:when>
            <!-- Add catid to links to /doc/LL/index.xml -->
            <xsl:when test="$catid != '0' and starts-with($thelink, '/doc/') and (substring-after(substring-after($thelink, '/doc/'), '/')='' or substring-after(substring-after($thelink, '/doc/'), '/')='index.xml')">
              <xsl:value-of select="concat($thelink, '?catid=', $catid)"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$thelink" /></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <!-- Now, insert style=printable in the URL if necessary -->
        <xsl:variable name="alink">
          <xsl:choose>
          <xsl:when test="$style != 'printable'  or  contains($llink, 'style=printable')">
            <!-- Not printable style or style=printable already in URL, copy link -->
            <xsl:value-of select="$llink" />
          </xsl:when>
          <xsl:when test="contains($llink, '://')">
            <!-- External link, copy link -->
            <xsl:value-of select="$llink" />
          </xsl:when>
          <xsl:when test="starts-with($llink, '#')">
            <!-- Anchor, copy link -->
            <xsl:value-of select="$llink" />
          </xsl:when>
          <xsl:otherwise>
            <!--  We should have eliminated all other cases,
                  style printable, local link, then insert ?style=printable -->
            <xsl:choose>
              <xsl:when test="starts-with($llink, '?')">
                <xsl:value-of select="concat( '?style=printable&amp;', substring-after($llink, '?'))" />
              </xsl:when>
              <xsl:when test="contains($llink, '.xml?')">
                <xsl:value-of select="concat(substring-before($llink, '.xml?'), '.xml?style=printable&amp;', substring-after($llink, '.xml?'))" />
              </xsl:when>
              <xsl:when test="contains($llink, '.xml#')">
                <xsl:value-of select="concat(substring-before($llink, '.xml#'), '.xml?style=printable#', substring-after($llink, '.xml#'))" />
              </xsl:when>
              <xsl:when test="substring-after($llink, '.xml') = ''">
                <xsl:value-of select="concat($llink, '?style=printable')" />
              </xsl:when>
              <xsl:otherwise>
                <!-- Have I forgotten anything?
                     Copy link -->
                <xsl:value-of select="$llink" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <a href="{$alink}"><xsl:apply-templates/></a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise>
    <xsl:variable name="loc" select="."/>
    <a href="{$loc}"><xsl:apply-templates/></a>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- Paragraph -->
<xsl:template match="p">
<xsl:param name="chid"/>
  <p>
    <!-- Keep this for old files with <p class="secthead"> -->
    <xsl:if test="@class">
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
    </xsl:if>

    <xsl:if test="@by">
      <xsl:attribute name="class">epigraph</xsl:attribute>
    </xsl:if>

    <xsl:apply-templates>
      <xsl:with-param name="chid" select="$chid"/>
    </xsl:apply-templates>

    <xsl:if test="@by">
      <br/><br/><span class="episig">—<xsl:value-of select="@by"/></span><br/><br/>
    </xsl:if>
  </p>
</xsl:template>

<!-- Emphasize -->
<xsl:template match="e">
  <span class="emphasis"><xsl:apply-templates/></span>
</xsl:template>

<!-- Table -->
<xsl:template match="table">
<table class="ntable">
  <xsl:apply-templates/>
</table>
</xsl:template>

<!-- Table Row -->
<xsl:template match="tr">
<tr>
  <xsl:if test="@id">
    <xsl:attribute name="id">
      <xsl:value-of select="@id"/>
    </xsl:attribute>
  </xsl:if>
  <xsl:apply-templates/>
</tr>
</xsl:template>

<xsl:template match="tcolumn">
<col width="{@width}"/>
</xsl:template>

<!-- Table Item -->
<xsl:template match="ti">
<td class="tableinfo">
  <xsl:if test="@colspan">
    <xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute>
  </xsl:if>
  <xsl:if test="@rowspan">
    <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
  </xsl:if>
  <xsl:apply-templates/>
</td>
</xsl:template>

<!-- Table Heading, no idea why <th> hasn't been used -->
<xsl:template match="th">
<td class="infohead">
  <xsl:if test="@colspan">
    <xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute>
    <!-- Center only when item spans several columns as
         centering all <th> might disrupt some pages.
         We might want to use a plain html <th> tag later.
         Tip: to center a single-cell title, use <th colspan="1">
       -->
    <xsl:attribute name="style">text-align:center</xsl:attribute>
  </xsl:if>
  <xsl:if test="@rowspan">
    <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
  </xsl:if>
  <b>
    <xsl:apply-templates/>
  </b>
</td>
</xsl:template>

<!-- Unnumbered List -->
<xsl:template match="ul">
<ul>
  <xsl:apply-templates/>
</ul>
</xsl:template>

<!-- Ordered List -->
<xsl:template match="ol">
<ol>
  <xsl:apply-templates/>
</ol>
</xsl:template>

<!-- List Item -->
<xsl:template match="li">
<li>
  <xsl:apply-templates/>
</li>
</xsl:template>

<!-- Definition Lists -->
<xsl:template match="dl">
<dl><xsl:apply-templates/></dl>
</xsl:template>

<xsl:template match="dt">
<dt><xsl:apply-templates/></dt>
</xsl:template>

<xsl:template match="dd">
<dd><xsl:apply-templates/></dd>
</xsl:template>

<!-- License Tag -->
<xsl:template match="license">
<p class="copyright">
  <xsl:apply-templates select="func:gettext('License')"/>
</p>
<xsl:comment>
  &lt;rdf:RDF xmlns="http://web.resource.org/cc/"
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"&gt;
  &lt;License rdf:about="http://creativecommons.org/licenses/by-sa/2.5/"&gt;
     &lt;permits rdf:resource="http://web.resource.org/cc/Reproduction" /&gt;
     &lt;permits rdf:resource="http://web.resource.org/cc/Distribution" /&gt;
     &lt;requires rdf:resource="http://web.resource.org/cc/Notice" /&gt;
     &lt;requires rdf:resource="http://web.resource.org/cc/Attribution" /&gt;
     &lt;permits rdf:resource="http://web.resource.org/cc/DerivativeWorks" /&gt;
     &lt;requires rdf:resource="http://web.resource.org/cc/ShareAlike" /&gt;
  &lt;/License&gt;
  &lt;/rdf:RDF&gt;
</xsl:comment>
</xsl:template>

<!-- GLSA Index -->
<xsl:template match="glsaindex">
  <xsl:apply-templates select="document('http://www.gentoo.org/dyn/glsa-index.xml?passthru=1')/guide/chapter[1]/section[1]/body"/>
</xsl:template>

<!-- GLSA Latest (max 10) -->
<xsl:template match="glsa-latest">
  <xsl:variable name="src" select="'http://www.gentoo.org/dyn/glsa-index.xml?passthru=1'"/>
  <table>
  <xsl:for-each select="document($src)/guide/chapter[1]/section[1]/body/table[1]/tr[position()&lt;11]">
    <tr><xsl:apply-templates/></tr>
  </xsl:for-each>
  </table>
</xsl:template>

<!-- Return the date of a document, for handbooks, it is the max(main file date, all included parts dates) -->
<xsl:template name="maxdate">
  <xsl:param name="thedoc"/>
  <xsl:choose>
    <xsl:when test="$thedoc/book">
      <!-- In a book: look for max(/date, include_files/sections/date) -->
      <xsl:for-each select="$thedoc/book/part/chapter/include">
        <xsl:sort select="document(@href,.)/sections/date" order="descending" />
        <xsl:if test="position() = 1">
          <!-- Compare the max(date) from included files with the date in the master file
               Of course, XSLT 1.0 knows no string comparison operator :-(
               So we build a node set with the two dates and we sort it.
            -->
          <xsl:variable name="theDates">
            <xsl:element name="bookDate">
              <xsl:value-of select="$thedoc/book/date"/>
            </xsl:element>
            <xsl:element name="maxChapterDate">
              <xsl:value-of select="document(@href,.)/sections/date"/>
            </xsl:element>
          </xsl:variable>
          <xsl:variable name="sortedDates">  
            <xsl:for-each select="exslt:node-set($theDates)/*">  
              <xsl:sort select="." order="descending" />
              <xsl:copy-of select="."/>
            </xsl:for-each>   
          </xsl:variable>
          <!-- First date is the one we want -->
          <xsl:value-of select="exslt:node-set($sortedDates)/*[position()=1]"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="$thedoc/guide or $thedoc/sections or $thedoc/mainpage">
      <xsl:value-of select="$thedoc/*[1]/date"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template name="contentdate">
  <xsl:variable name="docdate">
    <xsl:call-template name="maxdate">
      <xsl:with-param name="thedoc" select="/"/>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="func:gettext('Updated')/docdate">
      <xsl:apply-templates select="func:gettext('Updated')">
        <xsl:with-param name="docdate" select="$docdate"/>
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat(func:gettext('Updated'),' ')"/> <xsl:copy-of select="func:format-date($docdate)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="docdate">
<xsl:param name="docdate"/>
  <xsl:copy-of select="func:format-date($docdate)"/>
</xsl:template>


<xsl:template name="rhcol">
<!-- Right-hand column with date/authors/ads -->
  <table border="0" cellspacing="4px" cellpadding="4px">
    <!-- Add a "printer-friendly" button when link attribute exists -->

    <!-- Don't add the print button with stand-alone guide.xsl  UNCOMMENT if you really want it
    <xsl:if test="/book/@link or /guide/@link">
     <tr>
      <td class="topsep" align="center">
        <p class="altmenu">
          <xsl:variable name="PrintTip"><xsl:value-of select="func:gettext('PrintTip')"/></xsl:variable>
          <xsl:variable name="href">
            <xsl:choose>
              <xsl:when test="/book and $full != 0">
                <xsl:value-of select="'?full=1&amp;style=printable'"/>
              </xsl:when>
              <xsl:when test="/book">
                <xsl:value-of select="'?style=printable'"/>
                <xsl:if test="$part != '0'">&amp;part=<xsl:value-of select="$part"/></xsl:if>
                <xsl:if test="$chap != '0'">&amp;chap=<xsl:value-of select="$chap"/></xsl:if>
              </xsl:when>
              <xsl:when test="/guide">
                <xsl:value-of select="'?style=printable'"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <a title="{$PrintTip}" class="altlink" href="{$href}"><xsl:value-of select="func:gettext('Print')"/></a>
        </p>
      </td>
     </tr>
    </xsl:if>
    -->
    <xsl:choose>
      <xsl:when test="/book/date or /guide/date or /sections/date">
        <tr>
          <td align="center" class="topsep">
            <p class="alttext">
            <xsl:call-template name="contentdate"/>
            </p>
          </td>
        </tr>
      </xsl:when>
      <xsl:when test="/mainpage/date">
        <tr>
          <td align="center" class="topsep">
            <p class="alttext">
            <xsl:value-of select="concat(func:gettext('Updated'),' ')"/>
            <xsl:copy-of select="func:format-date(/mainpage/date)"/>
            </p>
          </td>
        </tr>
      </xsl:when>
      <xsl:when test="/news/date">
        <tr>
          <td align="center" class="topsep">
            <p class="alttext">
            <xsl:value-of select="concat(func:gettext('Updated'),' ')"/>
            <xsl:copy-of select="func:format-date(/news/date)"/>
            </p>
          </td>
        </tr>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="/book/abstract[normalize-space(.)] or /guide/abstract[normalize-space(.)]">
      <tr>
        <td align="left" class="topsep">
          <p class="alttext">
            <!-- Abstract (summary) of the document -->
            <b><xsl:value-of select="func:gettext('Summary')"/>: </b>
            <xsl:apply-templates select="abstract"/>
          </p>
        </td>
      </tr>
    </xsl:if>
    <xsl:if test="/book/author or /guide/author">
    <tr>
      <td align="left" class="topsep">
        <p class="alttext">
          <!-- Authors -->
          <xsl:apply-templates select="/guide/author|/book/author"/>
        </p>
      </td>
    </tr>
    </xsl:if>

      <tr lang="en">
      <td align="center" class="topsep">
        <p class="alttext">
          <b>Donate</b> to support our development efforts.
        </p>

        <form action="https://www.paypal.com/cgi-bin/webscr" method="post">
          <input type="hidden" name="cmd" value="_xclick"/>
          <input type="hidden" name="business" value="paypal@gentoo.org"/>
          <input type="hidden" name="item_name" value="Gentoo Linux Support"/>
          <input type="hidden" name="item_number" value="1000"/>
          <input type="hidden" name="image_url" value="/images/paypal.png"/>
          <input type="hidden" name="no_shipping" value="1"/>
          <input type="hidden" name="return" value="http://www.gentoo.org"/>
          <input type="hidden" name="cancel_return" value="http://www.gentoo.org"/>

          <input type="image" src="http://images.paypal.com/images/x-click-but21.gif" name="submit" alt="Make payments with PayPal - it's fast, free and secure!"/>
        </form>
      </td>
    </tr>
    <tr>
    <td align="center" class="topsep"/>
    </tr>
  </table>
</xsl:template>

<xsl:template name="newscontent">
<xsl:param name="thenews"/>
<xsl:param name="summary"/>
<xsl:param name="link"/>

  <div class="news">
    <p class="newshead" lang="en">
      <b><xsl:value-of select="$thenews/title"/></b>
      <br/>
      <font size="0.90em">
      Posted on <xsl:copy-of select="func:format-date($thenews/date)"/>
      by <xsl:value-of select="$thenews/poster"/>
      </font>
    </p>
    
    <xsl:choose>
      <xsl:when test="$thenews/@category='alpha'">
        <img class="newsicon" src="images/icon-alpha.gif" alt="AlphaServer GS160"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='kde'">
        <img class="newsicon" src="images/icon-kde.png" alt="KDE"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='gentoo'">
        <img class="newsicon" src="images/icon-gentoo.png" alt="gentoo"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='main'">
        <img class="newsicon" src="images/icon-stick.png" alt="stick man"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='ibm'">
        <img class="newsicon" src="images/icon-ibm.gif" alt="ibm"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='linux'">
        <img class="newsicon" src="images/icon-penguin.png" alt="tux"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='moo'">
        <img class="newsicon" src="images/icon-cow.png" alt="Larry the Cow"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='plans'">
        <img class="newsicon" src="images/icon-clock.png" alt="Clock"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='nvidia'">
        <img class="newsicon" src="images/icon-nvidia.png" alt="Nvidia"/>
      </xsl:when>
      <xsl:when test="$thenews/@category='freescale'">
        <img class="newsicon" src="images/icon-freescale.gif" alt="Freescale Semiconductor"/>
      </xsl:when>
    </xsl:choose>
                  
    <div class="newsitem">
    <xsl:choose>
      <xsl:when test="$thenews/summary and $summary='yes'">
        <xsl:apply-templates select="$thenews/summary"/>
        <br/>
        <a href="{$link}"><b>(full story)</b></a>
      </xsl:when>
      <xsl:when test="$thenews/body">
        <xsl:apply-templates select="$thenews/body"/>
      </xsl:when>
    </xsl:choose>
    </div>
  </div>
</xsl:template>

<xsl:variable name="mensis">
  <months lang="en">
    <month>January</month>
    <month>February</month>
    <month>March</month>
    <month>April</month>
    <month>May</month>
    <month>June</month>
    <month>July</month>
    <month>August</month>
    <month>September</month>
    <month>October</month>
    <month>November</month>
    <month>December</month>
  </months>
</xsl:variable>

<xsl:variable name="Inserts">
<inserts lang="en">
  <insert name="Content">Content</insert>
  <insert name="Updated">Updated <docdate/></insert>
  <insert name="Outdated">The <uri link="$originalversion">original version</uri> of this document was last updated <docdate/></insert>
  <!-- Doc not in /doc/LL/metadoc.xml -->
  <insert name="NoIndex">This translation is not maintained anymore</insert>
  <!-- Doc in /doc/LL/metadoc.xml but not in /doc/en/metadoc.xml-->
  <insert name="NoOriginal">The original version of this translation is not maintained anymore</insert>
  <insert name="Summary">Summary</insert>
  <insert name="Figure">Figure</insert>
  <insert name="Note">Note</insert>
  <insert name="Warning">Warning</insert>
  <insert name="Important">Important</insert>
  <insert name="CodeListing">Code Listing</insert>
  <insert name="GLinuxDoc">Gentoo Linux Documentation</insert>
  <insert name="PrintableDoc">Printable Linux Documentation</insert>
  <insert name="PrintablePrj">Printable Linux Project</insert>
  <insert name="SpaceBeforeColon"/>
  <insert name="Print">Print</insert>
  <insert name="PrintTip">View a printer-friendly version</insert>
  <insert name="Home">Home</insert>
  <insert name="License">
    The contents of this document are licensed under the <uri
    link="http://creativecommons.org/licenses/by-sa/2.5">Creative Commons -
    Attribution / Share Alike</uri> license.
  </insert>
  <insert name="hb_file">Link to other book part not available</insert>
  <!-- Metadoc stuff -->
  <insert name="GLinuxDocCat">Gentoo Linux Documentation Categories</insert>
  <insert name="members">Members</insert>
  <insert name="member">Member</insert>
  <insert name="lead">Lead</insert>
  <insert name="name">Name</insert>
  <insert name="nick">Nickname</insert>
  <insert name="email">E-mail</insert>
  <insert name="position">Position</insert>
  <insert name="files">Files</insert>
  <insert name="filename">Filename</insert>
  <insert name="version">Version</insert>
  <insert name="original">Original Version</insert>
  <insert name="editing">Editing</insert>
  <insert name="N/A">N/A</insert>
  <insert name="bugs">Bugs</insert>
  <insert name="showstoppers">Showstoppers</insert>
  <insert name="normalbugs">Normal Bugs</insert>
  <insert name="document">Document</insert>
  <insert name="bugid">Bug ID</insert>
  <insert name="untranslated">Untranslated files</insert>
   
  <!-- Disclaimer and redirect stuff -->
  <insert name="disclaimer">Disclaimer </insert>
  <insert name="articles">
    The original version of this article was first published on IBM
    developerWorks, and is property of Westtech Information Services. This
    document is an updated version of the original article, and contains
    various improvements made by the Gentoo Linux Documentation team.<br/>
    This document is not actively maintained.
  </insert>
  <insert name="oldbook">
    This handbook has been replaced by a newer version and is not maintained anymore.
  </insert>
  <insert name="draft">
    This document is a work in progress and should not be considered official yet.
  </insert>
  <insert name="obsolete">
    This document is not valid and is not maintained anymore.
  </insert>
  <insert name="redirect">
    This document has been replaced by a <uri link="$redirect">new version</uri>.
  </insert>
</inserts>
</xsl:variable>

</xsl:stylesheet>
