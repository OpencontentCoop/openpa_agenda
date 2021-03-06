<?php

class OpenPAAgendaPushClientLoader
{
    private static $instance;

    /**
     * @param string $client
     *
     * @return OpenPAAgendaPushClient
     * @throws Exception
     */
    public static function instance($client)
    {
        $settings = OpenPAINI::variable('OpenpaAgendaPushSettings', 'AvailableEndpoint');
        if (isset($settings[$client]) && class_exists($settings[$client])){
            $className = $settings[$client];
            return new $className();
        }
        
        throw new Exception("Client $client not handled");
    }

}

