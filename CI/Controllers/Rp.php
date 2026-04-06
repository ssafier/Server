<?php

namespace App\Controllers;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\I18n\Time;
use Psr\Log\LoggerInterface;

use App\Models\Prototypes;
use App\Models\Roleplay;
use App\Models\Visitors;

use App\Entities\ProtoHero;
use App\Entities\Role;
use App\Entities\Visitor;

class Rp extends BaseController
{
    protected $helpers = ['url'];
    private $prototypes;
    private $visitors;
    private $rp;
    
    public function initController(
        RequestInterface $request,
        ResponseInterface $response,
        LoggerInterface $logger) {
        parent::initController($request, $response, $logger);
        $this->prototypes = new Prototypes();
        $this->rp = new Roleplay();
        $this->visitors = new Visitors();
    }

    public function save() {
        $json = $this->request->getJSON(true); // Get JSON as an associative array
        if (!$json) {
            log_message('debug', 'invalid json');
            return;
        }
        $v = $this->visitors->where('avi =',$json['player'])->findAll();
        $visitor = $v[0];
        $v = $this->rp->where('avi =',$visitor->id)->findAll();
        $rp = null;
        if (!$v || count($v) == 0) {
            $rp = new \App\Entities\Role();
            $rp->avi = $visitor->id;
            $rp->enabled = 0;
            $rp->str_source = 0;
            $rp->str = 0;
            $rp->strength = $json['strength'];
            $rp->intelligence = $json['intelligence'];
            $rp->speed = $json['speed'];
            $rp->durability = $json['durability'];
            $rp->power = $json['energy'];
            $rp->combat = $json['combat'];
            $rp->alignment = $json['alignment'];
            $rp->tier = random_int(1,7);
            $rp->inserted_at = time();
            $rp->updated_at = time();
            $this->rp->insert($rp);
        } else {
            $rp = $v[0];
            $rp->strength = $json['strength'];
            $rp->intelligence = $json['intelligence'];
            $rp->speed = $json['speed'];
            $rp->durability = $json['durability'];
            $rp->power = $json['energy'];
            $rp->combat = $json['combat'];
            $rp->alignment = $json['alignment'];
            $rp->updated_at = time();
            $this->rp->update($rp->id, $rp);
        }
        $retval = array();
        $retval['strength'] = $rp->strength;
        $retval['intelligence'] = $rp->intelligence;
        $retval['speed'] = $rp->speed;
        $retval['durability'] = $rp->durability;
        $retval['power'] = $rp->power;
        $retval['combat'] = $rp->combat;
        $retval['alignment'] = $rp->alignment;
        $retval['tier'] = $rp->tier;
        return $this->response->setJSON($retval);        
    }

    public function getProtoHero($id) {
        $proto = $this->prototypes->where('id >', $id)->findAll();
        $hero = $proto[0];
        $count = count($proto) - 1;
        $result = array();
        $result['remaining'] = $count;
        $result['name'] = $hero->name;
        $result['json'] = json_encode($hero);
        return $this->response->setJSON($result);        
    }
}
