<?php

interface OpenPAAgendaPushClient
{
    public function push(AgendaItem $post);

    public function name();

    public function getRemoteUrl($response);

}
