<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class FuneralService extends Model {
    protected $fillable = ['name','description','process','contact_info','price_from','image_url','active'];
    protected function casts(): array { return ['price_from'=>'decimal:2','active'=>'boolean']; }
}
