<?php

use Opencontent\OpenApi\Exceptions\InvalidParameterException;
use Opencontent\OpenApi\OperationFactory\ContentObject\SearchOperationFactory;
use erasys\OpenApi\Spec\v3 as OA;
use Opencontent\Opendata\Api\Values\SearchResults;

class EventSearchOperationFactory extends SearchOperationFactory
{
    protected function generateSearchParameters()
    {
        $parameters = parent::generateSearchParameters();
        $parameters[] = new OA\Parameter(
            'from',
            OA\Parameter::IN_QUERY,
            'Filter events starting after the entered date. Input value expects to be given a string containing an English date format (see https://www.php.net/manual/en/function.strtotime.php)',
            [
                'schema' => $this->generateSchemaProperty(['type' => 'string', 'example' => 'now']),
            ]
        );
        $parameters[] = new OA\Parameter(
            'to',
            OA\Parameter::IN_QUERY,
            'Filter events that end before the entered date. Input value expects to be given a string containing an English date format (see https://www.php.net/manual/en/function.strtotime.php)',
            [
                'schema' => $this->generateSchemaProperty(['type' => 'string', 'example' => 'next month']),
            ]
        );
        $parameters[] = new OA\Parameter('typology[]', OA\Parameter::IN_QUERY, 'Filter by event typology', [
            'schema' => $this->generateSchemaProperty([
                'type' => 'array',
                'items' => [
                    'type' => 'string',
                    'enum' => $this->getEnumFromSchema('has_public_event_typology'),
                ],
            ]),
        ]);
        $parameters[] = new OA\Parameter('audience[]', OA\Parameter::IN_QUERY, 'Filter by event target audience', [
            'schema' => $this->generateSchemaProperty([
                'type' => 'array',
                'items' => [
                    'type' => 'string',
                    'enum' => $this->getEnumFromSchema('target_audience'),
                ],
            ]),
        ]);
        $parameters[] = new OA\Parameter('topic[]', OA\Parameter::IN_QUERY, 'Filter by event topic id', [
            'schema' => $this->generateSchemaProperty([
                'type' => 'array',
                'items' => [
                    'type' => 'string',
                ],
            ]),
        ]);
        $parameters[] = new OA\Parameter('organizer[]', OA\Parameter::IN_QUERY, 'Filter by event organizer id', [
            'schema' => $this->generateSchemaProperty([
                'type' => 'array',
                'items' => [
                    'type' => 'string',
                ],
            ]),
        ]);
        $parameters[] = new OA\Parameter('sort', OA\Parameter::IN_QUERY, 'Sort events', [
            'schema' => $this->generateSchemaProperty([
                'type' => 'string',
                'enum' => [
                    'published',
                    'modified',
                    'time_interval',
                ],
                'default' => 'published',
            ]),
        ]);
        $parameters[] = new OA\Parameter('order', OA\Parameter::IN_QUERY, 'Sort order', [
            'schema' => $this->generateSchemaProperty([
                'type' => 'string',
                'enum' => [
                    'desc',
                    'asc',
                ],
                'default' => 'desc',
            ]),
        ]);
        $parameters[] = new OA\Parameter(
            'fields',
            OA\Parameter::IN_QUERY,
            'Comma separated fields to show. The blank value means show all filters',
            [
                'schema' => $this->generateSchemaProperty(['type' => 'string']),
            ]
        );
        $parameters[] = new OA\Parameter(
            'embed_html_card',
            OA\Parameter::IN_QUERY,
            'Embed html snippet of event in card view',
            [
                'schema' => $this->generateSchemaProperty(['type' => 'boolean']),
            ]
        );

        return $parameters;
    }

    private function getEnumFromSchema($identifier): array
    {
        $eventSchema = $this->getSchemaFactories()[0];
        return $eventSchema->generateSchema()->properties[$identifier]['enum'] ?? [];
    }

    protected function buildQueryParts($endpointFactory)
    {
        $searchTerm = $this->getCurrentRequestParameter('searchTerm');
        $limit = (int)$this->getCurrentRequestParameter('limit');
        $offset = (int)$this->getCurrentRequestParameter('offset');
        $from = $this->getCurrentRequestParameter('from');
        $to = $this->getCurrentRequestParameter('to');
        $typology = $this->getCurrentRequestParameter('typology');
        $audience = $this->getCurrentRequestParameter('audience');
        $topic = $this->getCurrentRequestParameter('topic');
        $organizer = $this->getCurrentRequestParameter('organizer');
        $sort = $this->getCurrentRequestParameter('sort');
        $order = $this->getCurrentRequestParameter('order');

        $sortString = '[published=>desc]';
        if ($sort || $order) {
            $sort = $sort ?? 'published';
            $order = $order ?? 'desc';
            $sortString = "[$sort=>$order]";
        }

        if ($limit <= 0 || $limit > self::MAX_LIMIT) {
            throw new InvalidParameterException('limit', $limit);
        }
        if ($offset < 0) {
            throw new InvalidParameterException('offset', $offset);
        }

        $query = [];
        if (!empty($searchTerm)) {
            $query[] = 'q = \'' . addcslashes($searchTerm, '\'()[]"') . '\'';
        }

        $query[] = 'classes [' . implode(',', $endpointFactory->getClassIdentifierList()) . ']';
        $query[] = 'subtree [' . $endpointFactory->getNodeId() . ']';
        $query[] = 'raw[meta_language_code_ms] in [' . $this->getCurrentRequestLanguage() . ']';
        if ($from || $to) {
            $interval = [
                $from ?? '*',
                $to ?? '*',
            ];
            $query[] = "calendar[time_interval] = ['. $interval[0] . ',' . $interval[1] .']";
        }
        if (!empty($typology) && !empty($typology[0])) {
            $typology = array_map(function ($value) {
                $value = addcslashes($value, '\'()[]"');
                return '"' . $value . '"';
            }, $typology);
            $query[] = 'has_public_event_typology in [' . implode(',', $typology) . ']';
        }
        if (!empty($audience) && !empty($audience[0])) {
            $audience = array_map(function ($value) {
                $value = addcslashes($value, '\'()[]"');
                return '"' . $value . '"';
            }, $audience);
            $query[] = 'target_audience in [' . implode(',', $audience) . ']';
        }
        if (!empty($topic) && !empty($topic[0])) {
            $topic = array_map(function ($value) {
                $value = addcslashes($value, '\'()[]"');
                return '"' . $value . '"';
            }, $topic);
            $query[] = 'topics.remote_id in [' . implode(',', $topic) . ']';
        }
        if (!empty($organizer) && !empty($organizer[0])) {
            $organizer = array_map(function ($value) {
                $value = addcslashes($value, '\'()[]"');
                return '"' . $value . '"';
            }, $organizer);
            $query[] = 'organizer.remote_id in [' . implode(',', $organizer) . ']';
        }
        $query[] = 'sort ' . $sortString;
        $query[] = 'limit ' . $limit;
        $query[] = 'offset ' . $offset;

        return $query;
    }

    protected function buildResult(SearchResults $searchResults, $path)
    {
        $result = parent::buildResult($searchResults, $path);

        $embedHtml = $this->getCurrentRequestParameter('embed_html_card');

        if ($embedHtml === true || $embedHtml == 'true') {
            foreach ($result['items'] as $index => $hit) {
                $hit['embedded']['html'] = '';
                $contentObjectIdentifier = \eZDB::instance()->escapeString($hit['id']);
                $query = "SELECT node_id
                  FROM ezcontentobject_tree
                  WHERE main_node_id = node_id AND
                        contentobject_id in ( SELECT ezcontentobject.id
                                              FROM ezcontentobject
                                              WHERE ezcontentobject.remote_id='$contentObjectIdentifier')";
                $resArray = \eZDB::instance()->arrayQuery($query);

                if (count($resArray) == 1 && $resArray !== false) {
                    $nodeId = $resArray[0]['node_id'];
                    $view = 'card';
                    $html = \OpenPABootstrapItaliaContentEnvironmentSettings::generateView(
                        $nodeId,
                        $view
                    );
                    $hit['embedded']['card'] = preg_replace(['/\s*\R\s*/','/\s{2,}/', '/[\t\n]/'], '', $html);
                }
                $result['items'][$index] = $hit;
            }
        }

        $fields = $this->getCurrentRequestParameter('fields');
        if ($fields) {
            $fields = array_map('trim', explode(',', $fields));
            if (!empty($fields)) {
                $fieldIndexes = [];
                foreach ($fields as $index => $field) {
                    if (strpos($field, '[') !== false) {
                        $startPos = strpos($field, '[');
                        $fieldNormalized = substr($field, 0, $startPos);
                        $fieldIndex = trim(substr($field, $startPos), '[]');
                        $fieldIndexes[$fieldNormalized] = $fieldIndex;
                        $fields[$index] = $fieldNormalized;
                    }
                }
                $fieldsMock = array_fill_keys($fields, true);
                $hits = $result['items'];
                foreach ($hits as $index => $hit) {
                    $filteredHit = array_intersect_ukey($hit, $fieldsMock, function ($key1, $key2) {
                        if ($key1 == $key2) {
                            return 0;
                        } else {
                            if ($key1 > $key2) {
                                return 1;
                            } else {
                                return -1;
                            }
                        }
                    });
                    if (!empty($fieldIndexes)) {
                        foreach ($filteredHit as $name => $value) {
                            if (isset($fieldIndexes[$name])) {
                                if (is_array($value)) {
                                    $filteredHit[$name] = $value[$fieldIndexes[$name]] ?? null;
                                }
                            }
                        }
                    }
                    $result['items'][$index] = $filteredHit;
                }
            }
        }

        return $result;
    }
}
