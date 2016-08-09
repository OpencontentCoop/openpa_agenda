<?php
use Opencontent\Opendata\Api\EnvironmentLoader;
use Opencontent\Opendata\Api\ContentRepository;
use Opencontent\Opendata\Api\ContentSearch;

$httpTool = eZHTTPTool::instance();

$startDate = $httpTool->getVariable('start', 'now');
$filters = '';

$now = new DateTime($startDate);
if ($now instanceof DateTime) {
    $start = $now->modify('first day of this month')->setTime(0, 0);
    /** @var DateTime $end */
    $end = clone $start;
    $end = $end->modify('last day of this month')->setTime(23, 59);

    $query = "classes [event] and calendar[] = [{$start->format('Y-m-d')},{$end->format('Y-m-d')}] sort [from_time=>asc] $filters";

    try {
        $contentRepository = new ContentRepository();
        $contentSearch = new ContentSearch();

        $currentEnvironment = EnvironmentLoader::loadPreset('content');
        $contentRepository->setEnvironment($currentEnvironment);
        $contentSearch->setEnvironment($currentEnvironment);

        $parser = new ezpRestHttpRequestParser();
        $request = $parser->createRequest();
        $currentEnvironment->__set('request', $request);

        $contents = array();

        while ($query) {
            $result = $contentSearch->search($query);
            $query = $result->nextPageQuery;
            $contents = array_merge($contents, $result->searchHits);
        }

        $eventsByDay = array();
        $byDayInterval = new DateInterval( 'P1D' );
        $byDayPeriod = new DatePeriod( $start, $byDayInterval, $end );
        $language = eZLocale::currentLocaleCode();
        /** @var DateTime $date */
        foreach( $byDayPeriod as $date )
        {
            $identifier = $date->format( OpenPACalendarData::FULLDAY_IDENTIFIER_FORMAT );
            $day = new OpenPACalendarDay( $identifier );
            $calendarDay = array();
            foreach($contents as &$item){
                $itemStart = DateTime::createFromFormat(DateTime::ISO8601, $item['data'][$language]['from_time']);
                $itemEnd = DateTime::createFromFormat(DateTime::ISO8601, $item['data'][$language]['to_time']);
                $item['_start'] = new OpenPACalendarDay( $itemStart->format( OpenPACalendarData::FULLDAY_IDENTIFIER_FORMAT) );
                $item['_end'] = new OpenPACalendarDay( $itemEnd->format( OpenPACalendarData::FULLDAY_IDENTIFIER_FORMAT) );
                if(
                    ( $itemStart <= $day->dayStartDateTime
                      && $itemEnd >= $day->dayEndDateTime )

                    ||  ( $itemStart >= $day->dayStartDateTime
                          && $itemEnd <= $day->dayEndDateTime )

                    ||  ( $itemStart >= $day->dayStartDateTime
                          && $itemStart <= $day->dayEndDateTime )

                    ||  ( $itemEnd >= $day->dayStartDateTime
                          && $itemEnd <= $day->dayEndDateTime )

                ){
                    $calendarDay[] = $item;
                }
            }
            $eventsByDay[$identifier] = array(
                'events' => $calendarDay,
                'day' => $day
            );
        }

        $data = array(
            'start' => new OpenPACalendarDay( $start->format( OpenPACalendarData::FULLDAY_IDENTIFIER_FORMAT) ),
            'end' => new OpenPACalendarDay( $end->format( OpenPACalendarData::FULLDAY_IDENTIFIER_FORMAT) ),
            'events' => $contents,
            'events_by_day' =>  $eventsByDay,
            'language' => $language
        );

        if (isset($_GET['debug']) && $_GET['debug'] == 'data') {
            header('Content-Type: application/json');
            echo json_encode($data);
            eZExecution::cleanExit();
        }

        $paradoxPdf = new ParadoxPDF();
        $fileName = 'test.pdf';

        $tpl = eZTemplate::factory();
        $tpl->resetVariables();
        foreach($data as $key => $value){
            $tpl->setVariable( $key, $value );
        }

        $content = $tpl->fetch( 'design:agenda/pdf/list.tpl' );

        if (isset($_GET['debug']) && $_GET['debug'] == 'content') {
            echo $content;
            eZExecution::cleanExit();
        }

        $fileContent = $paradoxPdf->generatePDF($content);
        if (!$fileContent){
            throw new Exception("Fail generating pdf");
        }
        $size = strlen( $fileContent );
        $paradoxPdf->flushPDF( $fileContent, $fileName, $size );
        eZExecution::cleanExit();

    } catch (Exception $e) {
        $data = array(
            'error_code' => $e->getCode(),
            'error_message' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        );
        echo '<H1>'.$e->getMessage().'</H1>';
    }
}


eZExecution::cleanExit();