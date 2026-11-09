<?php
namespace App\Http\Controllers;
use App\Models\Booking;
use App\Models\Casket;
use App\Models\CustomizationRequest;
use App\Models\FuneralService;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
class ApiController extends Controller {
    public function register(Request $r) {
        $data = $r->validate(['name'=>'required|string|max:120','email'=>'required|email|max:255|unique:users','phone'=>'nullable|string|max:30','password'=>'required|string|min:8|confirmed']);
        $user=User::create([...$data,'role'=>'customer']); return response()->json(['user'=>$user,'token'=>$user->createToken('mobile')->plainTextToken],201);
    }
    public function login(Request $r) {
        $data=$r->validate(['email'=>'required|email','password'=>'required|string']); $user=User::where('email',$data['email'])->first();
        if (!$user || !Hash::check($data['password'],$user->password)) return response()->json(['message'=>'Invalid credentials.'],422);
        return response()->json(['user'=>$user,'token'=>$user->createToken('mobile')->plainTextToken]);
    }
    public function logout(Request $r) { $r->user()->currentAccessToken()->delete(); return response()->json(['message'=>'Signed out.']); }
    public function me(Request $r) { return $r->user(); }
    public function services() { return FuneralService::where('active',true)->orderBy('name')->paginate(30); }
    public function service(FuneralService $service) { abort_unless($service->active,404); return $service; }
    public function caskets(Request $r) {
        $q=Casket::query(); if ($s=$r->string('search')->trim()->toString()) $q->where(fn($w)=>$w->where('name','like',"%$s%")->orWhere('category','like',"%$s%"));
        if ($r->filled('category')) $q->where('category',$r->input('category')); if ($r->filled('available')) $q->where('available',$r->boolean('available'));
        if ($r->filled('min_price')) $q->where('price','>=',$r->input('min_price')); if ($r->filled('max_price')) $q->where('price','<=',$r->input('max_price'));
        return $q->orderBy('name')->paginate(30);
    }
    public function casket(Casket $casket) { return $casket; }
    public function casketImage(string $filename) {
        $allowed = ['chicken.jpg', 'crime_scene_coffin.webp', 'Frederick-Poplar.png', 'Mahogany.jpg', 'polished-wood-casket-in-funeral-home-display-room.webp'];
        abort_unless(in_array($filename, $allowed, true), 404);
        $path = public_path('casket/'.$filename);
        abort_unless(is_file($path), 404);
        return response()->file($path);
    }
    public function bookings(Request $r) { return $r->user()->bookings()->with('service')->latest()->paginate(30); }
    public function createBooking(Request $r) {
        $d=$r->validate(['funeral_service_id'=>'required|exists:funeral_services,id','requested_at'=>'required|date|after:now','location'=>'required|string|max:255','contact_name'=>'required|string|max:120','contact_phone'=>'required|string|max:30','notes'=>'nullable|string|max:2000']);
        $booking=$r->user()->bookings()->create([...$d,'status'=>'new']); return response()->json($booking->load('service'),201);
    }
    public function staffBookings(Request $r) {
        $q=Booking::with(['service','user'])->latest(); if($r->filled('status')) $q->where('status',$r->input('status')); if($r->filled('date')) $q->whereDate('requested_at',$r->input('date')); if($r->filled('service_id')) $q->where('funeral_service_id',$r->input('service_id')); return $q->paginate(30);
    }
    public function updateBooking(Request $r, Booking $booking) {
        $d=$r->validate(['status'=>['required',Rule::in(['confirmed','proposed','in_progress','completed','cancelled'])],'staff_note'=>'nullable|string|max:2000','proposed_at'=>'nullable|required_if:status,proposed|date|after:now']); $booking->update($d); return $booking->fresh()->load(['service','user']);
    }
    public function customization(Request $r) {
        $d=$r->validate(['casket_id'=>'required|exists:caskets,id','configuration'=>'required|array','notes'=>'nullable|string|max:2000']);
        $request=$r->user()->customizationRequests()->create([...$d,'status'=>'pending_confirmation']); return response()->json($request->load('casket'),201);
    }
    public function myCustomizations(Request $r) { return $r->user()->customizationRequests()->with('casket')->latest()->paginate(30); }
    public function staffCustomizations() { return CustomizationRequest::with(['casket','user'])->latest()->paginate(30); }
    public function reviewCustomization(Request $r, CustomizationRequest $request) { $d=$r->validate(['status'=>['required',Rule::in(['confirmed','rejected'])],'quoted_price'=>'nullable|required_if:status,confirmed|numeric|min:0','lead_time_days'=>'nullable|integer|min:1','staff_note'=>'nullable|string|max:2000']); $request->update($d); return $request->fresh()->load(['casket','user']); }
    public function orders(Request $r) { return $r->user()->orders()->with('casket')->latest()->paginate(30); }
    public function createOrder(Request $r) {
        $d=$r->validate(['casket_id'=>'required|exists:caskets,id','configuration'=>'nullable|array','quantity'=>'required|integer|min:1|max:20','delivery_address'=>'required|string|max:255','contact_phone'=>'required|string|max:30']);
        $c=Casket::findOrFail($d['casket_id']); abort_unless($c->available,422,'This item is currently unavailable.');
        $d['total_estimate']=$c->price*$d['quantity']; $order=$r->user()->orders()->create([...$d,'status'=>'new']); return response()->json($order->load('casket'),201);
    }
    public function updateOrder(Request $r, Order $order) { $d=$r->validate(['status'=>['required',Rule::in(['confirmed','preparing','completed','cancelled'])],'staff_note'=>'nullable|string|max:2000']); $order->update($d); return $order->fresh()->load('casket'); }
    public function createService(Request $r) { $d=$r->validate(['name'=>'required|string|max:150','description'=>'required|string','process'=>'nullable|string','contact_info'=>'nullable|string|max:255','price_from'=>'nullable|numeric|min:0','image_url'=>'nullable|url|max:2048','active'=>'boolean']); return response()->json(FuneralService::create($d),201); }
    public function updateService(Request $r, FuneralService $service) { $d=$r->validate(['name'=>'sometimes|required|string|max:150','description'=>'sometimes|required|string','process'=>'nullable|string','contact_info'=>'nullable|string|max:255','price_from'=>'nullable|numeric|min:0','image_url'=>'nullable|url|max:2048','active'=>'boolean']); $service->update($d); return $service->fresh(); }
    public function deleteService(FuneralService $service) { $service->update(['active'=>false]); return response()->json(['message'=>'Service deactivated.']); }
    public function createCasket(Request $r) { $d=$r->validate(['name'=>'required|string|max:150','category'=>'required|string|max:100','description'=>'required|string','material'=>'nullable|string|max:100','dimensions'=>'nullable|string|max:100','image_url'=>'nullable|url|max:2048','price'=>'required|numeric|min:0','available'=>'boolean','options'=>'nullable|array']); return response()->json(Casket::create($d),201); }
    public function updateCasket(Request $r, Casket $casket) { $d=$r->validate(['name'=>'sometimes|required|string|max:150','category'=>'sometimes|required|string|max:100','description'=>'sometimes|required|string','material'=>'nullable|string|max:100','dimensions'=>'nullable|string|max:100','image_url'=>'nullable|url|max:2048','price'=>'sometimes|required|numeric|min:0','available'=>'boolean','options'=>'nullable|array']); $casket->update($d); return $casket->fresh(); }
    public function deleteCasket(Casket $casket) { $casket->update(['available'=>false]); return response()->json(['message'=>'Casket marked unavailable.']); }
    public function staffOrders(Request $r) { $q=Order::with(['casket','user'])->latest(); if($r->filled('status')) $q->where('status',$r->input('status')); return $q->paginate(30); }
}
