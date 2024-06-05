<?php

use Opencontent\OpenApi\EndpointFactory;
use Opencontent\OpenApi\Exceptions\InvalidParameterException;
use Opencontent\OpenApi\OperationFactory\GetOperationFactory;
use erasys\OpenApi\Spec\v3 as OA;

class OpenAgendaCalendarOperationFactory extends GetOperationFactory
{
    protected $name = 'getOpenagendaCalendarOperation';

    public function handleCurrentRequest(EndpointFactory $endpointFactory)
    {
        $result = new \ezpRestMvcResult();
        $yearMonth = $this->getCurrentRequestParameter('year-month');
        if (empty($yearMonth)){
            throw new InvalidParameterException('year-month', $yearMonth);
        }
        [$year, $month] = explode('-', $yearMonth);
        if (empty($year)){
            throw new InvalidParameterException('year', $year);
        }
        if (empty($month)){
            throw new InvalidParameterException('month', $month);
        }

        $query = 'classes [event] and calendar[time_interval] = [2024-05-01,2024-05-31] limit 0 facets [raw[attr_time_interval_dp]]';
        $search = new \Opencontent\Opendata\Api\ContentSearch();
        $search->setEnvironment(new DefaultEnvironmentSettings(['debug' => true]));

        echo '<pre>';print_r(
            $search->search($query)
    );die();

        $result->variables = [
            'year' => $year,
            'month' => $month,
        ];

        return $result;
    }

    protected function generateResponseList()
    {
        return [
            '200' => new OA\Response('Successful response', [
                'application/json' => new OA\MediaType([
                    'schema' => $this->generateSchemasReference()
                ])
            ], $this->generateResponseHeaders()),
            '400' => new OA\Response('Invalid input provided', null, $this->generateResponseHeaders(true)),
            '403' => new OA\Response('Forbidden', null, $this->generateResponseHeaders(true)),
            '404' => new OA\Response('Not found', null, $this->generateResponseHeaders(true)),
            '500' => new OA\Response('Internal error', null, $this->generateResponseHeaders(true)),
        ];
    }

    protected function generateOperationAdditionalProperties()
    {
        $properties = parent::generateOperationAdditionalProperties();
        $properties['parameters'] = [
            new OA\Parameter('year-month', OA\Parameter::IN_PATH, 'Year and month YYYY-MM', [
                'schema' => $this->generateSchemaProperty(['type' => 'string']),
                'required' => true,
            ]),
        ];

        return $properties;
    }
}
