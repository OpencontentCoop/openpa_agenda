<?php

class OpenPAAgendaStatIndexPlugin implements ezfIndexPlugin
{
    public function modify(eZContentObject $contentObject, &$docList)
    {
        if ($contentObject->attribute('class_identifier') != OpenPAAgenda::instance()->getEventClassIdentifier()){
            return;
        }

        $version = $contentObject->currentVersion();
        if ($version === false) {
            return;
        }

        $published = new DateTime();
        $published->setTimestamp($contentObject->attribute('published'));

        $month = $published->format('n');
        if ($month >= 10) $quarter = 4;
        elseif ($month >= 7) $quarter = 3;
        elseif ($month >= 4) $quarter = 2;
        else $quarter = 1;

        if ($month >= 6) $semester = 2;
        else $semester = 1;

        $extras = [];
        $extras['extra_stat_month_i'] = $published->format('Ym');
        $extras['extra_stat_quarter_i'] = $published->format('Y') . $quarter;
        $extras['extra_stat_semester_i'] = $published->format('Y') . $semester;
        $extras['extra_stat_year_i'] = $published->format('Y');

        $availableLanguages = $version->translationList(false, false);
        foreach ($availableLanguages as $languageCode) {
            if ($docList[$languageCode] instanceof eZSolrDoc) {
                foreach ($extras as $key => $value) {
                    if ($docList[$languageCode]->Doc instanceof DOMDocument) {
                        $xpath = new DomXpath($docList[$languageCode]->Doc);
                        if ($xpath->evaluate('//field[@name="' . $key . '"]')->length == 0) {
                            $docList[$languageCode]->addField($key, $value);
                        }
                    } elseif (is_array($docList[$languageCode]->Doc) && !isset($docList[$languageCode]->Doc[$key])) {
                        $docList[$languageCode]->addField($key, $value);
                    }
                }
            }
        }
    }

}
