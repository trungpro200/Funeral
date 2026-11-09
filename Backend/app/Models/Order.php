<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Order extends Model {
    protected $fillable = ['user_id','casket_id','configuration','quantity','total_estimate','delivery_address','contact_phone','status','staff_note'];
    protected function casts(): array { return ['configuration'=>'array','total_estimate'=>'decimal:2']; }
    public function casket() { return $this->belongsTo(Casket::class); }
    public function user() { return $this->belongsTo(User::class); }
}
