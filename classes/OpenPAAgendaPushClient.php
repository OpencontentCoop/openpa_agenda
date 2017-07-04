<?php

interface OpenPAAgendaPushClient
{
    public function push(OCEditorialStuffPost $post);

    public function convert(OCEditorialStuffPost $post);

    public function getRemote(OCEditorialStuffPost $post);

    public function name();

    public function getRemoteUrl($response);

}
