<?php

$eZTemplateOperatorArray[] = array(
    'script' => 'extension/openpa_agenda/autoloads/OpenPAAgendaOperators.php',
    'class' => 'OpenPAAgendaOperators',
    'operator_names' => array(
        'latest_program',
        'calendar_node_id',
        'agenda_root_node',
        'is_collaboration_enabled',
        'is_comment_enabled',
        'is_header_only_logo_enabled',
        'agenda_root',
        'agenda_browse_helper',
        'current_user_is_agenda_moderator',
        'current_user_has_limited_edit_agenda_event'
    )
);
