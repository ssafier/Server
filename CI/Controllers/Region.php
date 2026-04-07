<?php

namespace App\Controllers;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\I18n\Time;
use Psr\Log\LoggerInterface;

use App\Models\Visits;
use App\Models\Visitors;
use App\Models\Roleplay;
    
use App\Entities\Visitor;
use App\Entities\Visit;
use App\Entities\Role;

class Region extends BaseController
{
    protected $helpers = ['url'];
    private $visitors;
    private $visits;
    private $rp;
    
    public function initController(
        RequestInterface $request,
        ResponseInterface $response,
        LoggerInterface $logger) {
        parent::initController($request, $response, $logger);
        $this->visitors = new Visitors();
        $this->visits = new Visits();
        $this->rp = new Roleplay();
    }

    public function enter() {
        $json = $this->request->getJSON(true); // Get JSON as an associative array
        if (!$json) {
            log_message('debug', 'invalid json');
            return;
        }
        $retval = array();
        $result = $this->visitors->where('avi =',$json['id'])->findAll();
        $vid = 0;
        if (!$result || count($result) == 0) {
            $visitor = new \App\Entities\Visitor();
            $visitor->avi = $json['id'];
            $visitor->updated_at = time();
            $visitor->inserted_at = time();
            $vid = $this->visitors->insert($visitor);
            $retval['recognized'] = 'false';
            $retval['roleplay'] = json_encode(array('enabled' => 0));
        } else {
            $visitor = $result[0];
            $vid = $visitor->id;
            $retval['recognized'] = 'true';
            $result = $this->rp->where('avi =',$vid)->findAll();
            if (!$result || count($result) == 0) {
                $retval['roleplay'] = json_encode(array('enabled' => 0));
            } else {
                $r = $result[0];
                $role = array('enabled' => $r->enabled);
                $role['strength'] = $r->strength;
                $role['intelligence'] = $r->intelligence;
                $role['combat'] = $r->combat;
                $role['power'] = $r->power;
                $role['durability'] = $r->durability;
                $role['alignment'] = $r->alignment;
                $role['speed'] = $r->speed;
                $role['tier'] = $r->tier;
                $role['str_source'] = $r->str_source;
                $retval['roleplay'] = json_encode($role);
            }
        }
        $visit = new \App\Entities\Visit();
        $visit->avi = $vid;
        $visit->where_x = $json['x'];
        $visit->where_y = $json['y'];
        $visit->where_z = $json['z'];
        $visit->arrive_at = time();
        $visit->leave_at = time();
        $retval['index'] = $this->visits->insert($visit);
        return $this->response->setJSON($retval);        
    }

    public function leave() {
        $json = $this->request->getJSON(true); // Get JSON as an associative array
        if (!$json) {
            log_message('debug', 'invalid json');
            return;
        }
        $retval = array();
        $result = $this->visits->where('id =',$json['index'])->findAll();
        $visit = $result[0];
        $visit->leave_at = time();
        $this->visits->update($visit->id, $visit);
        $retval['status'] = 'ok';
        return $this->response->setJSON($retval);        
    }
}
