<?php

class OpenPAAttributeSocialHandler extends OpenPAAttributeContactsHandler
{
    public static function getContactsFields()
    {
        return array(
            "Facebook",
            "Twitter",
            "Linkedin",
            "Instagram",
            "Youtube",
        );
    }
}
