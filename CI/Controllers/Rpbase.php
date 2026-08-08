<?php

namespace App\Controllers;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\I18n\Time;
use Psr\Log\LoggerInterface;

use App\Models\Players;
use App\Models\PlayerStats;
use App\Models\Roleplay;
use App\Models\Visitors;
use App\Models\BodyStats;
use App\Models\Lifters;

use App\Entities\Role;
use App\Entities\Visitor;
use App\Entities\Player;
use App\Entities\Statistics;
use App\Entities\Lifter;
use App\Entities\BodyPart;

class Rpbase extends BaseController {
    protected $helpers = ['url'];
    private $smls;
    private $statistics;
    private $rp;
    private $players;
    private $body_parts;
    protected $visitors;
    
    public function initController(
        RequestInterface $request,
        ResponseInterface $response,
        LoggerInterface $logger
    ) {
        parent::initController($request, $response, $logger);
        // SML
        $this->smls = new Players();
        $this->statistics = new PlayerStats();
        // RP
        $this->rp = new Roleplay();
        $this->visitors = new Visitors();
        // SPS
        $this->players = new Lifters();
        $this->body_parts = new BodyStats();
    }
        
    protected function getSML($avikey) {
        $p = $this->smls->where('avi',$avikey)->findAll();
        if ($p == null || count($p) == 0) return 0;
        $p = $p[0];
        $s = $this->statistics->where('id =',$p->stats)->findAll();
        $s = $s[0];
        return $s->strength;
    }

    protected function getRP($avikey) {
        $v = $this->visitors->where('avi =',$avikey)->findAll();
        if ($v == null || count($v) == 0) return array();
        $visitor = $v[0];
        $v = $this->rp->where('avi =',$visitor->id)->findAll();
        if (!$v || count($v) == 0) return;
        $v = $v[0];
        $retval = array();
        $retval['strength'] = $v->strength;
        $retval['intelligence'] = $v->intelligence;
        $retval['combat'] = $v->combat;
        $retval['power'] = $v->power;
        $retval['durability'] = $v->durability;
        $retval['alignment'] = $v->alignment;
        $retval['speed'] = $v->speed;
        $retval['tier'] = $v->tier;

        $db = \Config\Database::connect();
        
        $builder = $db->table('prototypes p');
        $builder->select('p.id AS prototype_id, p.name AS prototype_name, p.strength, p.intelligence, p.speed, p.durability, p.power, p.combat, p.alignment');

        // 2. Use PHP's sprintf() to dynamically inject the player's stats into the math.
        // Because we are injecting standard integers, we can drop the 's.column' CASTs entirely.
        $math = sprintf(
            "SQRT(
            POW(CAST(p.strength AS SIGNED) - %d, 2) +
            POW(CAST(p.intelligence AS SIGNED) - %d, 2) +
            POW(CAST(p.speed AS SIGNED) - %d, 2) +
            POW(CAST(p.durability AS SIGNED) - %d, 2) +
            POW(CAST(p.power AS SIGNED) - %d, 2) +
            POW(CAST(p.combat AS SIGNED) - %d, 2) +
            POW(CAST(p.alignment AS SIGNED) - %d, 2)
        ) AS vector_distance",
            $v->strength,  $v->intelligence, $v->speed, $v->durability,$v->power,   $v->combat, $v->alignment
        );
        
        // Again, pass false to prevent escaping
        $builder->select($math, false);
    
        $builder->orderBy('vector_distance', 'ASC');
        $builder->limit(1);

        $result = $builder->get()->getRow();
        $retval['proto'] = $result->prototype_name;
        return $retval;
    }

    protected function getSPS($avi) {
        $p = $this->players->where('avi =',$avi)->findAll();
        $params = $this->request->getGet();
        if ($p == null || count($p) == 0) return array();
        $player = $p[0];
        $retval = array();
        $s = $this->body_parts->where('player =', $player->id)->findAll();
        if ($s == null) return array();
        $count = count($s);
        $total = 0;
        // TODO: UTC
        date_default_timezone_set('America/Denver');
        $now = Time::now();
        for ($i = 0; $i < $count; $i++) {
            $updated = false;
            $stat = $s[$i];
            $total += $stat->strength;
            switch($stat->bodypart) {
            case 1: // arms
                $retval['arms'] = $stat->strength;
                break;
            case 2: // core
                $retval['core'] = $stat->strength;
                break;
            case 4: // chest
                $retval['chest'] = $stat->strength;
                break;
            case 8: // back
                $retval['back'] = $stat->strength;
                break;
            case 16: // legs
                $retval['legs'] = $stat->strength;
                break;
            default: break;
            }
        }

        $retval['total'] = $total;
        return $retval;
    }
}
