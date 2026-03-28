<?php

namespace App\Entities;
use CodeIgniter\Entity\Entity;

class ProtoHero extends Entity {
    protected $attributes = [
        'id' => 0,
        'name' => '',
        'strength' => 0,
        'intelligence' => 0,
        'speed' => 0,
        'durability' => 0,
        'power' => 0,
        'combat' => 0,
        'alignment' => 0,
        'tier' => 0,
        'inserted_at' => null,
        'updated_at' => null,
        'deleted_at' => null,
    ];
    protected $casts = [
        'id' => 'integer',
        'name' => 'string',
        'strength' => 'integer',
        'intelligence' => 'integer',
        'speed' => 'integer',
        'durability' => 'integer',
        'power' => 'integer',
        'combat' => 'integer',
        'alignment' => 'integer',
        'tier' => 'integer',
    ];
}
