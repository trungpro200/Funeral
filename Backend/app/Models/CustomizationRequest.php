<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class CustomizationRequest extends Model {
    protected $fillable=['user_id','casket_id','configuration','notes','status','quoted_price','lead_time_days','staff_note'];
    protected function casts(): array { return ['configuration'=>'array','quoted_price'=>'decimal:2']; }
    public function casket() { return $this->belongsTo(Casket::class); }
    public function user() { return $this->belongsTo(User::class); }
}
