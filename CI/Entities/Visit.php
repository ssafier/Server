<?php

namespace App\Entities;
use CodeIgniter\Entity\Entity;

class Visit extends Entity {
    protected $attributes = [
        'id' => 0,
        'avi' => 0,
        'where_x' => 0,
        'where_y' => 0,
        'where_z' => 0,
        'arrive_at' => null,
        'leave_at' => null,
        'deleted_at' => null,
    ];
    protected $dates = ['arrive_at', 'leave_at', 'deleted_at'];
    protected $casts = [
        'id' => 'integer',
        'avi' => 'integer',
        'where_x' => 'float',
        'where_y' => 'float',
        'where_z' => 'float',
        'arrive_at' => 'datetime',
        'leave_at' => 'datetime',
    ];
}
