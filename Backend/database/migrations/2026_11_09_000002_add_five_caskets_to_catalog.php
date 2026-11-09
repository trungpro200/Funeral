<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    private array $caskets = [
        ['Chicken Casket', 'Novelty', 'A playful chicken-shaped novelty casket photo from the design gallery.', 'Painted wood', 4500000, 'chicken.jpg'],
        ['Crime Scene Coffin', 'Novelty', 'A theatrical crime-scene coffin design from the photo collection.', 'Wood', 7000000, 'crime_scene_coffin.webp'],
        ['Frederick Poplar Casket', 'Wood', 'Poplar casket with a traditional polished finish.', 'Poplar', 10000000, 'Frederick-Poplar.png'],
        ['Mahogany Casket', 'Wood', 'Dark mahogany casket with a classic polished finish.', 'Mahogany', 11500000, 'Mahogany.jpg'],
        ['Polished Wood Casket', 'Wood', 'Polished wooden casket shown in a funeral home display.', 'Wood', 12500000, 'polished-wood-casket-in-funeral-home-display-room.webp'],
    ];

    public function up(): void
    {
        foreach ($this->caskets as [$name, $category, $description, $material, $price, $file]) {
            $attributes = [
                'category' => $category,
                'description' => $description,
                'material' => $material,
                'dimensions' => 'Standard',
                'image_url' => '/api/v1/casket-images/'.$file,
                'price' => $price,
                'available' => true,
                'options' => json_encode(['material' => [$material], 'color' => ['Natural', 'Dark'], 'size' => ['Standard']]),
                'updated_at' => now(),
            ];
            $existing = DB::table('caskets')->where('name', $name)->first();
            if ($existing) {
                DB::table('caskets')->where('id', $existing->id)->update($attributes);
            } else {
                $attributes['name'] = $name;
                $attributes['created_at'] = now();
                DB::table('caskets')->insert($attributes);
            }
        }

        DB::table('caskets')->where('name', 'Classic wooden casket')->update([
            'image_url' => '/api/v1/casket-images/polished-wood-casket-in-funeral-home-display-room.webp',
        ]);
        DB::table('caskets')->where('name', 'Simple wooden casket')->update([
            'image_url' => '/api/v1/casket-images/Mahogany.jpg',
        ]);
    }

    public function down(): void
    {
        foreach ($this->caskets as [$name]) {
            DB::table('caskets')->where('name', $name)->delete();
        }
        DB::table('caskets')->where('name', 'Classic wooden casket')->update([
            'image_url' => '/casket/polished-wood-casket-in-funeral-home-display-room.webp',
        ]);
        DB::table('caskets')->where('name', 'Simple wooden casket')->update([
            'image_url' => '/casket/Mahogany.jpg',
        ]);
    }
};
