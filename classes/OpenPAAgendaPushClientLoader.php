<?php

class OpenPAAgendaPushClientLoader
{
    private static $instance;

    /**
     * @param $client
     *
     * @return OpenPAAgendaPushClient
     */
    public static function instance($client)
    {
        return new OpenPAAgendaTcuPushClient();
    }

}

