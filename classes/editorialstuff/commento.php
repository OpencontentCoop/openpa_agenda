<?php

class Commento extends OCEditorialStuffPost
{
    public function onCreate()
    {
        if ( OpenpaAgenda::instance()->needModeration($this->getObject()) ){
            $states = $this->states();
            $default = 'moderation.waiting';
            if ( isset( $states[$default] ) ) {
                $this->getObject()->assignState($states[$default]);
            }
            eZSearch::addObject( $this->object, true );
            OpenPAAgenda::notifyEventOwner($this);     
            OpenPAAgenda::notifyCommentOwner($this);     
        }
    }
    
    public function onChangeState( eZContentObjectState $beforeState, eZContentObjectState $afterState )
    {
        if ($beforeState->attribute('id') !== $afterState->attribute('id'))
        {
            OpenPAAgenda::notifyCommentOwner($this);     
        }
    }
    
}
