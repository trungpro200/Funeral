<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Booking extends Model {
    protected $fillable = ['user_id','funeral_service_id','requested_at','location','contact_name','contact_phone','notes','status','staff_note','proposed_at'];
    protected function casts(): array { return ['requested_at'=>'datetime','proposed_at'=>'datetime']; }
    public function service() { return $this->belongsTo(FuneralService::class, 'funeral_service_id'); }
    public function user() { return $this->belongsTo(User::class); }
}
