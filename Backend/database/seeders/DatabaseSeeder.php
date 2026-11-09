<?php
namespace Database\Seeders;
use App\Models\Casket;
use App\Models\FuneralService;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
class DatabaseSeeder extends Seeder {
 public function run(): void {
  User::updateOrCreate(['email'=>'admin@example.com'],['name'=>'Demo Administrator','phone'=>'0900000000','password'=>Hash::make('password'),'role'=>'admin']);
  User::updateOrCreate(['email'=>'staff@example.com'],['name'=>'Demo Staff','phone'=>'0900000001','password'=>Hash::make('password'),'role'=>'staff']);
  foreach ([['Basic funeral arrangement','Coordination and essential ceremony services.',5000000],['Full funeral service','End-to-end family support and ceremony coordination.',15000000]] as [$name,$description,$price]) FuneralService::firstOrCreate(['name'=>$name],['description'=>$description,'process'=>'A staff member will contact your family to confirm details and timing.','contact_info'=>'Call our support team for assistance.','price_from'=>$price]);
  foreach ([['Classic wooden casket','Wood','Solid wood, polished finish.','Oak',12000000,'polished-wood-casket-in-funeral-home-display-room.webp'],['Simple wooden casket','Wood','Simple and respectful design.','Pine',7000000,'Mahogany.jpg']] as [$name,$category,$description,$material,$price,$image]) Casket::firstOrCreate(['name'=>$name],['category'=>$category,'description'=>$description,'material'=>$material,'dimensions'=>'Standard','image_url'=>'/api/v1/casket-images/'.$image,'price'=>$price,'available'=>true,'options'=>['material'=>['Oak','Pine'],'color'=>['Natural','Dark'],'size'=>['Standard']]]);
  foreach ([
   ['Chicken Casket','Novelty','A playful chicken-shaped novelty casket photo from the design gallery.','Painted wood',4500000,'chicken.jpg'],
   ['Crime Scene Coffin','Novelty','A theatrical crime-scene coffin design from the photo collection.','Wood',7000000,'crime_scene_coffin.webp'],
   ['Frederick Poplar Casket','Wood','Poplar casket with a traditional polished finish.','Poplar',10000000,'Frederick-Poplar.png'],
   ['Mahogany Casket','Wood','Dark mahogany casket with a classic polished finish.','Mahogany',11500000,'Mahogany.jpg'],
   ['Polished Wood Casket','Wood','Polished wooden casket shown in a funeral home display.','Wood',12500000,'polished-wood-casket-in-funeral-home-display-room.webp'],
  ] as [$name,$category,$description,$material,$price,$image]) Casket::firstOrCreate(['name'=>$name],['category'=>$category,'description'=>$description,'material'=>$material,'dimensions'=>'Standard','image_url'=>'/api/v1/casket-images/'.$image,'price'=>$price,'available'=>true,'options'=>['material'=>[$material],'color'=>['Natural','Dark'],'size'=>['Standard']]]);
 }
}
