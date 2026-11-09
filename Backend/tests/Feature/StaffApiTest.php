<?php
namespace Tests\Feature;
use App\Models\Booking;
use App\Models\Casket;
use App\Models\FuneralService;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
class StaffApiTest extends TestCase {
    use RefreshDatabase;

    private function user(string $role): User {
        return User::create(['name'=>ucfirst($role),'email'=>"$role@example.com",'password'=>'secret-pass-123','role'=>$role]);
    }

    public function test_staff_can_propose_a_booking_time_but_customers_cannot_manage_the_queue(): void {
        $customer=$this->user('customer');
        $staff=$this->user('staff');
        $service=FuneralService::create(['name'=>'Family Ceremony','description'=>'Family support','active'=>true]);
        $booking=Booking::create([
            'user_id'=>$customer->id,'funeral_service_id'=>$service->id,'requested_at'=>now()->addDays(2),
            'location'=>'District 1','contact_name'=>'Customer','contact_phone'=>'0900000000','status'=>'new',
        ]);
        $this->actingAs($customer,'sanctum')->getJson('/api/v1/staff/bookings')->assertForbidden();
        $this->actingAs($staff,'sanctum')->getJson('/api/v1/staff/bookings')->assertOk()->assertJsonCount(1,'data');
        $this->actingAs($staff,'sanctum')->patchJson("/api/v1/staff/bookings/$booking->id",[
            'status'=>'proposed','proposed_at'=>now()->addDays(3)->toIso8601String(),'staff_note'=>'Please confirm this alternative.',
        ])->assertOk()->assertJsonPath('status','proposed');
        $this->actingAs($staff,'sanctum')->patchJson("/api/v1/staff/bookings/$booking->id",[
            'status'=>'proposed',
        ])->assertUnprocessable()->assertJsonValidationErrors(['proposed_at']);
    }

    public function test_staff_can_review_customization_and_manage_catalog_items(): void {
        $customer=$this->user('customer');
        $staff=$this->user('staff');
        $casket=Casket::create(['name'=>'Oak Classic','category'=>'Wood','description'=>'Oak wood','price'=>12000000,'available'=>true]);
        $request=$customer->customizationRequests()->create(['casket_id'=>$casket->id,'configuration'=>['material'=>'Oak'],'status'=>'pending_confirmation']);
        $this->actingAs($staff,'sanctum')->patchJson("/api/v1/staff/customization-requests/$request->id",[
            'status'=>'confirmed','quoted_price'=>15000000,'lead_time_days'=>10,
        ])->assertOk()->assertJsonPath('status','confirmed')->assertJsonPath('lead_time_days',10);
        $this->actingAs($staff,'sanctum')->postJson('/api/v1/staff/services',[
            'name'=>'Premium Ceremony','description'=>'Full family support','price_from'=>25000000,
        ])->assertCreated()->assertJsonPath('name','Premium Ceremony');
        $this->actingAs($staff,'sanctum')->postJson('/api/v1/staff/caskets',[
            'name'=>'Maple Classic','category'=>'Wood','description'=>'Solid maple','price'=>18000000,
        ])->assertCreated()->assertJsonPath('name','Maple Classic');
    }

    public function test_staff_can_update_order_status_and_customer_cannot(): void {
        $customer=$this->user('customer');
        $staff=$this->user('staff');
        $casket=Casket::create(['name'=>'Oak Classic','category'=>'Wood','description'=>'Oak wood','price'=>12000000,'available'=>true]);
        $order=$customer->orders()->create(['casket_id'=>$casket->id,'quantity'=>1,'total_estimate'=>12000000,'delivery_address'=>'District 1','contact_phone'=>'0900000000','status'=>'new']);
        $this->actingAs($customer,'sanctum')->getJson('/api/v1/staff/orders')->assertForbidden();
        $this->actingAs($staff,'sanctum')->getJson('/api/v1/staff/orders')->assertOk()->assertJsonCount(1,'data');
        $this->actingAs($staff,'sanctum')->patchJson("/api/v1/staff/orders/$order->id",[
            'status'=>'preparing','staff_note'=>'Preparing for delivery.',
        ])->assertOk()->assertJsonPath('status','preparing');
    }
}
