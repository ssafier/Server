<?php

namespace App\Models;

use CodeIgniter\Model;
use App\Entities\ProtoHero;

class Prototypes extends Model
{
    protected $table      = 'prototypes';
    protected $primaryKey = 'id';

    protected $useAutoIncrement = true;

    protected $returnType     = '\App\Entities\ProtoHero';
    protected $useSoftDeletes = false;

    protected $allowedFields = ['id', 'name', 'strength', 'intelligence', 'speed', 'durability', 'power', 'combat', 'alignment', 'tier'];

    // Dates
    protected $useTimestamps = true;
    protected $dateFormat    = 'datetime';
    protected $createdField  = 'inserted_at';
    protected $updatedField  = 'updated_at';
    protected $deletedField  = 'deleted_at';

    // Validation
    protected $validationRules      = [];
    protected $validationMessages   = [];
    protected $skipValidation       = false;
    protected $cleanValidationRules = true;

    // Callbacks
    protected $allowCallbacks = true;
    protected $beforeInsert   = [];
    protected $afterInsert    = [];
    protected $beforeUpdate   = [];
    protected $afterUpdate    = [];
    protected $beforeFind     = [];
    protected $afterFind      = [];
    protected $beforeDelete   = [];
    protected $afterDelete    = [];
}
