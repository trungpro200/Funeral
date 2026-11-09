<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void { Schema::create('caskets', function (Blueprint $table) { $table->id(); $table->string('name'); $table->string('category')->index(); $table->text('description'); $table->string('material')->nullable(); $table->string('dimensions')->nullable(); $table->string('image_url')->nullable(); $table->decimal('price',12,2); $table->boolean('available')->default(true); $table->json('options')->nullable(); $table->timestamps(); }); }
    public function down(): void { Schema::dropIfExists('caskets'); }
};
