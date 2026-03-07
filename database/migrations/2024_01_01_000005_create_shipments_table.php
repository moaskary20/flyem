<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shipments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->decimal('price_min', 15, 2)->nullable();
            $table->foreignId('currency_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('from_country_id')->constrained('countries')->cascadeOnDelete();
            $table->foreignId('from_city_id')->constrained('cities')->cascadeOnDelete();
            $table->foreignId('to_country_id')->constrained('countries')->cascadeOnDelete();
            $table->foreignId('to_city_id')->constrained('cities')->cascadeOnDelete();
            $table->decimal('weight', 8, 2)->nullable();
            $table->enum('weight_unit', ['kg', 'lb'])->default('kg');
            $table->enum('type', ['documents', 'fragile', 'electronics', 'clothing', 'food', 'other'])->default('other');
            $table->date('deadline_date')->nullable();
            $table->enum('status', ['pending', 'active', 'in_progress', 'delivered', 'cancelled'])->default('pending');
            $table->json('images')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shipments');
    }
};
