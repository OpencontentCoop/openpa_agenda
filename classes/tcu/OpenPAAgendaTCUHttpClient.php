<?php

class OpenPAAgendaTCUHttpClient
{

    const REMOTE_ID_PREFIX = 'tcu_push_';

    protected $server;

    protected $login;

    protected $password;

    protected $proxy;

    protected $proxyPort;

    protected $proxyLogin;

    protected $proxyPassword;

    protected $proxyAuthType;

    protected $apiEndPointBase = '/api/tcu';

    public static $connectionTimeout = 5;

    public static $processTimeout = 60;

    public $logger;

    public function __construct(
        $login = null,
        $password = null,
        $server = null
    ) {
        $settings = OpenPAINI::group('OpenpaAgendaPushSettingsTcu');
        $server = $server === null ? $settings['TrentinoCulturaServer'] : $server;
        $this->server = rtrim($server, '/');
        $this->login = $login === null ? $settings['TrentinoCulturaLogin'] : $login;
        $this->password = $password === null ? $settings['TrentinoCulturaPassword'] : $password;

    }

    public function setProxy(
        $proxy,
        $proxyPort,
        $proxyLogin = null,
        $proxyPassword = null,
        $proxyAuthType = 1
    ) {
        $this->proxy = $proxy;
        $this->proxyPort = $proxyPort;
        $this->proxyLogin = $proxyLogin;
        $this->proxyPassword = $proxyPassword;
        $this->proxyAuthType = $proxyAuthType;
    }

    public function create($data)
    {
        return $this->request('POST', $this->buildUrl('/create/event'), json_encode($data));
    }

    public function get($id)
    {
        return $this->request('GET', $this->buildUrl('/get/event/' . $id));
    }

    public function update($id, $data)
    {
        return $this->request('POST', $this->buildUrl('/update/event/' . $id), json_encode($data));
    }

    public function describe($identifier = null)
    {
        if ($identifier) {
            $identifier = '/' . ltrim($identifier, '/');

            return $this->request('GET', $this->buildUrl('/describe/event' . $identifier));
        } else {
            $data = array();
            $class = $this->request('GET', $this->buildUrl('/describe/event' . $identifier));
            foreach ($class as $field) {
                $data[$field] = $this->describe($field);
            }

            return $data;
        }
    }

    protected function buildUrl($path)
    {
        return $this->server . $this->apiEndPointBase . $path;
    }

    public function request($method, $url, $data = null)
    {
        $headers = array();

        if ($this->login && $this->password) {
            $credentials = "{$this->login}:{$this->password}";
            $headers[] = "Authorization: Basic " . base64_encode($credentials);
        }

        $ch = curl_init();
        if ($method == "POST") {
            curl_setopt($ch, CURLOPT_POST, 1);
        }
        if ($data !== null) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
            $headers[] = 'Content-Type: application/json';
            $headers[] = 'Content-Length: ' . strlen($data);
        }
        curl_setopt($ch, CURLOPT_HEADER, 1);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, self::$connectionTimeout);
        curl_setopt($ch, CURLOPT_TIMEOUT, self::$processTimeout);
        curl_setopt($ch, CURLINFO_HEADER_OUT, true);

        if ($this->proxy !== null) {
            curl_setopt($ch, CURLOPT_PROXY, $this->proxy . ':' . $this->proxyPort);
            if ($this->proxyLogin !== null) {
                curl_setopt(
                    $ch,
                    CURLOPT_PROXYUSERPWD,
                    $this->proxyLogin . ':' . $this->proxyPassword
                );
                curl_setopt($ch, CURLOPT_PROXYAUTH, $this->proxyAuthType);
            }
        }

        $data = curl_exec($ch);

        if ($data === false) {
            $errorCode = curl_errno($ch) * -1;
            $errorMessage = curl_error($ch);
            curl_close($ch);
            throw new \Exception($errorMessage, $errorCode);
        }

        $info = curl_getinfo($ch);
        if (class_exists('eZDebug')) {
            eZDebug::writeDebug($info['request_header'], __METHOD__);
        }

        curl_close($ch);

        $headers = substr($data, 0, $info['header_size']);
        $body = substr($data, -$info['download_content_length']);

        return $this->parseResponse($info, $headers, $body);
    }

    protected function parseResponse($info, $headers, $body)
    {
        $data = json_decode($body);

        if (isset( $data->error_message )) {
            $errorMessage = '';
            if (isset( $data->error_type )) {
                $errorMessage = $data->error_type . ': ';
            }
            $errorMessage .= $data->error_message;
            throw new \Exception($errorMessage);
        }

        if ($info['http_code'] == 401) {
            throw new \Exception("Authorization Required");
        }

        if (!in_array($info['http_code'], array(100, 200, 201, 202))) {
            throw new \Exception("Unknown error");
        }
        $data = json_decode($body, true);

        return $data['result'];
    }

    public static function definition($refresh = false)
    {
        $cacheFilePath = OpenPAAgenda::instance()->getAgendaCacheDir() . '/tcu_event_definition.cache';
        $cacheFile = eZClusterFileHandler::instance($cacheFilePath);
        $retrieveCallback = $refresh ? null : array('OpenPAAgendaTCUHttpClient', 'retrieveEventDefinitionCache');
        $generateCallback = array('OpenPAAgendaTCUHttpClient', 'generateEventDefinitionCache');

        return $cacheFile->processCache($retrieveCallback, $generateCallback);
    }

    public static function retrieveEventDefinitionCache($filePath, $mtime)
    {
        $cache = include( $filePath );

        return $cache;
    }

    public static function generateEventDefinitionCache()
    {
        $client = new OpenPAAgendaTCUHttpClient();
        $cacheData = $client->describe();

        if ($cacheData !== null) {
            $cacheData = array(
                'content' => $cacheData,
                'scope' => 'tcu_event-cache',
                'datatype' => 'php',
                'store' => true
            );
        }

        return $cacheData;
    }

    public function isAlreadyPushed(eZContentObjectTreeNode $node)
    {
        try{
            $data = $this->get($this->getRemoteId($node));
            return isset( $data['metadata'] );
        }catch(Exception $e){
            return false;
        }
    }

    private function getRemoteId(eZContentObjectTreeNode $node)
    {
        $mainNode = $node->object()->attribute('main_node');

        return str_replace(self::REMOTE_ID_PREFIX, '', $mainNode->attribute('remote_id'));
    }

    private function storeRemoteId(eZContentObjectTreeNode $node, $data)
    {
        $mainNode = $node->object()->attribute('main_node');
        $mainNode->setAttribute('remote_id', self::REMOTE_ID_PREFIX . $data);
        $mainNode->store();
    }

    public function push(eZContentObjectTreeNode $node)
    {
        $converter = new OpenPAAgendaTCUEventConverter($node);
        $data = $converter->convert();

        if ($this->isAlreadyPushed($node)) {

            $result = $this->update(
                $this->getRemoteId($node),
                $data
            );

        }else {

            $result = $this->create($data);
            if (isset( $result['metadata'] )) {
                $this->storeRemoteId($node, $result['metadata']['id']);
            }
        }

        return $result;

    }

}
