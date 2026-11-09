<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void { Schema::create('bookings', function (Blueprint $table) { $table->id(); $table->foreignId('user_id')->constrained()->cascadeOnDelete(); $table->foreignId('funeral_service_id')->constrained()->restrictOnDelete(); $table->dateTime('requested_at'); $table->string('location'); $table->string('contact_name'); $table->string('contact_phone',30); $table->text('notes')->nullable(); $table->string('status')->default('new')->index(); $table->text('staff_note')->nullable(); $table->dateTime('proposed_at')->nullable(); $table->timestamps(); }); }
    public function down(): void { Schema::dropIfExists('bookings'); }
};
