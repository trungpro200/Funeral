<?php
namespace Tests\Feature;
use App\Models\Booking;
use App\Models\Casket;
use App\Models\FuneralService;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
class CustomerApiTest extends TestCase {
    use RefreshDatabase;

    private function customer(string $email='customer@example.com'): User {
        return User::create(['name'=>'Customer','email'=>$email,'password'=>'secret-pass-123']);
    }

    public function test_service_and_casket_catalogs_are_public_and_support_search(): void {
        FuneralService::create(['name'=>'Family Ceremony','description'=>'Family support','active'=>true]);
        Casket::create(['name'=>'Oak Classic','category'=>'Wood','description'=>'Oak wood','price'=>12000000,'available'=>true]);
        $this->getJson('/api/v1/services')->assertOk()->assertJsonPath('data.0.name','Family Ceremony');
        $this->getJson('/api/v1/caskets?search=Oak')->assertOk()->assertJsonPath('data.0.name','Oak Classic');
        $this->getJson('/api/v1/caskets?search=unmatched')->assertOk()->assertJsonPath('data',[]);
    }

    public function test_customer_can_create_booking_and_only_sees_their_own_history(): void {
        $customer=$this->customer();
        $other=$this->customer('other@example.com');
        $service=FuneralService::create(['name'=>'Family Ceremony','description'=>'Family support','active'=>true]);
        $this->actingAs($customer,'sanctum')->postJson('/api/v1/bookings',[
            'funeral_service_id'=>$service->id,'requested_at'=>now()->addDays(2)->toIso8601String(),
            'location'=>'District 1','contact_name'=>'Customer','contact_phone'=>'0900000000','notes'=>'Please call first',
        ])->assertCreated()->assertJsonPath('status','new')->assertJsonPath('service.id',$service->id);
        $this->actingAs($customer,'sanctum')->getJson('/api/v1/bookings')->assertOk()->assertJsonCount(1,'data');
        $this->actingAs($other,'sanctum')->getJson('/api/v1/bookings')->assertOk()->assertJsonCount(0,'data');
        $this->assertDatabaseCount('bookings',1);
    }

    public function test_customer_can_order_available_casket_and_unavailable_products_are_rejected(): void {
        $customer=$this->customer();
        $available=Casket::create(['name'=>'Oak Classic','category'=>'Wood','description'=>'Oak wood','price'=>12000000,'available'=>true]);
        $unavailable=Casket::create(['name'=>'Out of stock','category'=>'Wood','description'=>'Unavailable','price'=>7000000,'available'=>false]);
        $this->actingAs($customer,'sanctum')->postJson('/api/v1/orders',[
            'casket_id'=>$available->id,'quantity'=>2,'delivery_address'=>'District 1','contact_phone'=>'0900000000',
        ])->assertCreated()->assertJsonPath('status','new')->assertJsonPath('total_estimate','24000000.00');
        $this->actingAs($customer,'sanctum')->postJson('/api/v1/orders',[
            'casket_id'=>$unavailable->id,'quantity'=>1,'delivery_address'=>'District 1','contact_phone'=>'0900000000',
        ])->assertStatus(422);
        $this->actingAs($customer,'sanctum')->getJson('/api/v1/orders')->assertOk()->assertJsonCount(1,'data');
    }

    public function test_customization_request_is_persisted_for_customer_and_staff_review(): void {
        $customer=$this->customer();
        $casket=Casket::create(['name'=>'Oak Classic','category'=>'Wood','description'=>'Oak wood','price'=>12000000,'available'=>true]);
        $this->actingAs($customer,'sanctum')->postJson('/api/v1/customization-requests',[
            'casket_id'=>$casket->id,'configuration'=>['material'=>'Oak','color'=>'Dark'],'notes'=>'Add a simple engraving',
        ])->assertCreated()->assertJsonPath('status','pending_confirmation');
        $this->actingAs($customer,'sanctum')->getJson('/api/v1/customization-requests')->assertOk()->assertJsonPath('data.0.configuration.material','Oak');
        $this->assertDatabaseCount('customization_requests',1);
    }

    public function test_booking_requires_complete_contact_and_schedule_details(): void {
        $customer=$this->customer();
        $service=FuneralService::create(['name'=>'Family Ceremony','description'=>'Family support','active'=>true]);
        $this->actingAs($customer,'sanctum')->postJson('/api/v1/bookings',[
            'funeral_service_id'=>$service->id,'requested_at'=>now()->addDay()->toIso8601String(),
        ])->assertUnprocessable()->assertJsonValidationErrors(['location','contact_name','contact_phone']);
    }
}
