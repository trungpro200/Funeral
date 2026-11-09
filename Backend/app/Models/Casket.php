<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Casket extends Model {
    protected $fillable = ['name','category','description','material','dimensions','image_url','price','available','options'];
    protected function casts(): array { return ['price'=>'decimal:2','available'=>'boolean','options'=>'array']; }
}
