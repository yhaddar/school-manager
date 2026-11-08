<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Institution extends Model
{
    use HasUlids, HasFactory;

    protected $keyType = "string";
    public $incrementing = false;

    protected $fillable = [
        "name",
        "status",
        "archived_at",
    ];

    protected $casts = [
        "archived_at" => "datetime",
    ];

    public function memberships(): HasMany
    {
        return $this->hasMany(InstitutionMembership::class);
    }
}
