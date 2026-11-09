<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;
class User extends Authenticatable {
    use HasApiTokens, HasFactory, Notifiable;
    protected $fillable = ['name','email','phone','password','role','address'];
    protected $hidden = ['password','remember_token'];
    protected function casts(): array { return ['password'=>'hashed','email_verified_at'=>'datetime']; }
    public function bookings() { return $this->hasMany(Booking::class); }
    public function orders() { return $this->hasMany(Order::class); }
    public function customizationRequests() { return $this->hasMany(CustomizationRequest::class); }
}
