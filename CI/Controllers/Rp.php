<?php

namespace App\Controllers;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\I18n\Time;
use Psr\Log\LoggerInterface;

use App\Models\Prototypes;
use App\Models\Roleplay;

use App\Entities\ProtoHero;
use App\Entities\Role;

class Rp extends BaseController
{
    protected $helpers = ['url'];
    private $prototypes;
    private $players;
    
    public function initController(
        RequestInterface $request,
        ResponseInterface $response,
        LoggerInterface $logger) {
        parent::initController($request, $response, $logger);
        $this->prototypes = new Prototypes();
        $this->players = new Roleplay();
    }

    public function update() {
        $json = $this->request->getJSON(true); // Get JSON as an associative array
        if (!$json) {
            log_message('debug', 'invalid json');
            return;
        }
        $retval = array();
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
