<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void { Schema::create('orders', function (Blueprint $table) { $table->id(); $table->foreignId('user_id')->constrained()->cascadeOnDelete(); $table->foreignId('casket_id')->constrained()->restrictOnDelete(); $table->json('configuration')->nullable(); $table->unsignedInteger('quantity')->default(1); $table->decimal('total_estimate',12,2); $table->string('delivery_address'); $table->string('contact_phone',30); $table->string('status')->default('new')->index(); $table->text('staff_note')->nullable(); $table->timestamps(); }); }
    public function down(): void { Schema::dropIfExists('orders'); }
};
