<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void { Schema::create('customization_requests', function (Blueprint $table) { $table->id(); $table->foreignId('user_id')->constrained()->cascadeOnDelete(); $table->foreignId('casket_id')->constrained()->restrictOnDelete(); $table->json('configuration'); $table->text('notes')->nullable(); $table->string('status')->default('pending_confirmation')->index(); $table->decimal('quoted_price',12,2)->nullable(); $table->unsignedInteger('lead_time_days')->nullable(); $table->text('staff_note')->nullable(); $table->timestamps(); }); }
    public function down(): void { Schema::dropIfExists('customization_requests'); }
};
