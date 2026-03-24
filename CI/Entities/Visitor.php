<?php

namespace App\Entities;
use CodeIgniter\Entity\Entity;

class Visitor extends Entity {
    protected $attributes = [
        'id' => 0,
        'avi' => null,
        'inserted_at' => null,
        'updated_at' => null,
    ];
    protected $casts = [
        'id' => 'integer',
        'avi' => 'string',
    ];
}
