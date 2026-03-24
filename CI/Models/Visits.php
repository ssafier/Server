<?php

namespace App\Models;

use CodeIgniter\Model;
use App\Entities\Visitor;

class Visits extends Model
{
    protected $table      = 'visits';
    protected $primaryKey = 'id';

    protected $useAutoIncrement = true;

    protected $returnType     = '\App\Entities\Visit';
    protected $useSoftDeletes = false;

    protected $allowedFields = ['avi', 'where_x', 'where_y', 'where_z', 'arrive_at', 'leave_at'];

    // Dates
    protected $useTimestamps = true;
    protected $dateFormat    = 'datetime';
    protected $createdField  = 'arrive_at';
    protected $updatedField  = 'leave_at';
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
