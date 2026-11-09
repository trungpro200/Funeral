<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        DB::table('caskets')->where('name', 'Classic wooden casket')->update([
            'image_url' => '/casket/polished-wood-casket-in-funeral-home-display-room.webp',
        ]);
        DB::table('caskets')->where('name', 'Simple wooden casket')->update([
            'image_url' => '/casket/Mahogany.jpg',
        ]);
    }

    public function down(): void
    {
        DB::table('caskets')->whereIn('name', [
            'Classic wooden casket',
            'Simple wooden casket',
        ])->update(['image_url' => null]);
    }
};
