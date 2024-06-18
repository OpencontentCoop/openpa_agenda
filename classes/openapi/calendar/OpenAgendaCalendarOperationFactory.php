<?php

use Opencontent\OpenApi\EndpointFactory;
use Opencontent\OpenApi\Exceptions\InvalidParameterException;
use Opencontent\OpenApi\OperationFactory\GetOperationFactory;
use erasys\OpenApi\Spec\v3 as OA;
use Opencontent\OpenApi\SchemaFactory\ContentClassSchemaFactory;
use Opencontent\Opendata\Api\ClassRepository;
use Opencontent\Opendata\Api\ContentSearch;
use Opencontent\Opendata\Api\Values\ContentClass;

class OpenAgendaCalendarOperationFactory extends GetOperationFactory
{
    protected $name = 'getOpenagendaCalendarOperation';

    private $filters;

    /**
     * @throws \Opencontent\Opendata\Api\Exception\OutOfRangeException
     * @throws InvalidParameterException
     */
    public function handleCurrentRequest(EndpointFactory $endpointFactory)
    {
        $result = new ezpRestMvcResult();
        $yearMonth = $this->getCurrentRequestParameter('year-month');
        if (empty($yearMonth)) {
            throw new InvalidParameterException('year-month', $yearMonth);
        }
        [$year, $month] = explode('-', $yearMonth);
        if (empty($year)) {
            throw new InvalidParameterException('year', $year);
        }
        if (empty($month)) {
            throw new InvalidParameterException('month', $month);
        }

        $year = (int)$year;
        if ($year <= 0) {
            throw new InvalidParameterException('year', $year);
        }
        $month = (int)$month;
        if ($month < 1 || $month > 12) {
            throw new InvalidParameterException('month', $month);
        }
        $month = str_pad($month, 2, '0', STR_PAD_LEFT);

        $filters = $this->getFilters();
        $eventQuery = [];
        foreach ($filters as $name => $filter) {
            $name = str_replace('[]', '', $name);
            switch ($filter['dataType']) {
                case eZTagsType::DATA_TYPE_STRING:
                case eZObjectRelationListType::DATA_TYPE_STRING:
                case eZObjectRelationType::DATA_TYPE_STRING:
                    $values = $this->getCurrentRequestParameter($name);
                    if (!empty($values) && !empty($values[0])) {
                        $values = array_map(function ($value) {
                            $value = addcslashes($value, '\'()[]"');
                            return '"' . $value . '"';
                        }, $values);
                        $eventQuery[] = $filter['queryField'] . ' in [' . implode(',', $values) . ']';
                    }
                    break;

                case eZSelectionType::DATA_TYPE_STRING:
                    $value = $this->getCurrentRequestParameter($name);
                    if (!empty($values) && is_string($value)) {
                        $eventQuery[] = $filter['queryField'] . ' = \'"' . addcslashes($value, '\'()[]"') . '"\'';
                    }
                    break;
            }
        }

        $query = implode(' and ', $eventQuery)
            . ' classes [event] and raw[subattr_time_interval___ym____lk] = "' . $year . '-' . $month . '" limit 1 facets [raw[subattr_time_interval___ymd____lk]|name]';
        $search = new ContentSearch();
        $search->setEnvironment(new DefaultEnvironmentSettings(['debug' => true]));

        $date = DateTime::createFromFormat('Y-m-d', $year . '-' . $month . '-01');
        $days = $date->format('t');
        $withEvents = $search->search($query)->facets[0]['data'];
        $calendar = [];
        for ($i = 1; $i <= $days; $i++) {
            $date = $year . '-' . $month . '-' . str_pad($i, 2, '0', STR_PAD_LEFT);
            $calendar[] = [
                'date' => $date,
                'has_events' => isset($withEvents[$date]),
            ];
        }

        $result->variables = $calendar;

        return $result;
    }

    protected function getFilters(): array
    {
        if ($this->filters === null) {
            $this->filters = [];

            $classRepository = new ClassRepository();
            try {
                $class = $classRepository->load('event');
                if ($class instanceof ContentClass) {
                    $schema = (new ContentClassSchemaFactory('event'))->generateSchema();
                    foreach ($class->fields as $field) {
                        if (!$field['isSearchable']) {
                            continue;
                        }
                        $identifier = $field['identifier'];
                        if (!isset($schema->properties[$identifier])) {
                            continue;
                        }
                        if (isset($schema->properties[$identifier]['deprecated'])) {
                            continue;
                        }

                        switch ($field['dataType']) {
                            case eZTagsType::DATA_TYPE_STRING;
                                $this->filters[$identifier . '[]'] = [
                                    'in' => OA\Parameter::IN_QUERY,
                                    'description' => sprintf('Filter by %s field', $identifier),
                                    'schema' => [
                                        'type' => 'array',
                                        'items' => [
                                            'type' => 'string',
                                            'enum' => $schema->properties[$identifier]['enum'] ?? [],
                                        ],
                                    ],
                                    'queryField' => $identifier,
                                    'dataType' => $field['dataType'],
                                ];
                                break;

                            case eZObjectRelationListType::DATA_TYPE_STRING;
                            case eZObjectRelationType::DATA_TYPE_STRING;
                                $this->filters[$identifier . '[]'] = [
                                    'in' => OA\Parameter::IN_QUERY,
                                    'description' => sprintf('Filter by %s field id', $identifier),
                                    'schema' => [
                                        'type' => 'array',
                                        'items' => [
                                            'type' => 'string',
                                        ],
                                    ],
                                    'queryField' => $identifier . '.remote_id',
                                    'dataType' => $field['dataType'],
                                ];
                                break;

                            case eZSelectionType::DATA_TYPE_STRING:
                                $this->filters[$identifier] = [
                                    'in' => OA\Parameter::IN_QUERY,
                                    'description' => sprintf('Filter by %s field', $identifier),
                                    'schema' => [
                                        'type' => 'string',
                                        'enum' => $schema->properties[$identifier]['enum'] ?? [],
                                    ],
                                    'queryField' => $identifier,
                                    'dataType' => $field['dataType'],
                                ];
                                break;
                        }
                    }
                }
            } catch (\Throwable $e) {
            }
        }

        return $this->filters;
    }

    protected function generateResponseList()
    {
        $schemaFactory = $this->getSchemaFactories()[0];
        return [
            '200' => new OA\Response('Successful response', [
                'application/json' => new OA\MediaType([
                    'schema' => $schemaFactory->generateSchema(),
                ]),
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

        foreach ($this->getFilters() as $name => $filter) {
            $properties['parameters'][] = new OA\Parameter(
                $name,
                $filter['in'],
                $filter['description'],
                [
                    'schema' => $this->generateSchemaProperty($filter['schema']),
                ]
            );
        }

        return $properties;
    }
}
