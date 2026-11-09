<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void { Schema::create('funeral_services', function (Blueprint $table) { $table->id(); $table->string('name'); $table->text('description'); $table->text('process')->nullable(); $table->string('contact_info')->nullable(); $table->decimal('price_from',12,2)->nullable(); $table->string('image_url')->nullable(); $table->boolean('active')->default(true); $table->timestamps(); }); }
    public function down(): void { Schema::dropIfExists('funeral_services'); }
};
