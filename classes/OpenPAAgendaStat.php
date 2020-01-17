<?php

class OpenPAAgendaStat
{
    /**
     * @var AbstractOpenPAAgendaStatFactory[]
     */
    private $factories = [];

    public function __construct()
    {
        $this->factories = [
            new OpenPAAgendaStatPerTopic(),
            new OpenPAAgendaStatPerPlace(),
            new OpenPAAgendaStatPerTarget(),
            new OpenPAAgendaStatPerOrganization(),
        ];
    }

    public function getStatisticFactories()
    {
        return $this->factories;
    }

    public function getStatisticFactory($identifier)
    {
        foreach ($this->factories as $factory) {
            if ($factory->getIdentifier() == $identifier) {
                return $factory;
            }
        }

        throw new InvalidArgumentException("Stat $identifier not found");
    }
}
