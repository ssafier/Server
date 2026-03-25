<?php

namespace App\Entities;
use CodeIgniter\Entity\Entity;

class Role extends Entity {
    protected $attributes = [
        'id' => 0,
        'avi' => 0,
        'enabled' => 0,
        'str_source' => 0,
        'str' => 0,
        'strength' => 0,
        'intelligence' => 0,
        'speed' => 0,
        'durability' => 0,
        'power' => 0,
        'combat' => 0,
        'tier' => 0,
        'inserted_at' => null,
        'updated_at' => null,
        'deleted_at' => null,
    ];
    protected $casts = [
        'id' => 'integer',
        'avi' => 'integer',
        'enabled' => 'integer',
        'str_source' => 'integer',
        'str' => 'integer',
        'strength' => 'integer',
        'intelligence' => 'integer',
        'speed' => 'integer',
        'durability' => 'integer',
        'power' => 'integer',
        'combat' => 'integer',
        'tier' => 'integer',
    ];
}
