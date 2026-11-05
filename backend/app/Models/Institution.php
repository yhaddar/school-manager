<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Concerns\HasUlids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

#[Fillable(['name', 'status'])]
class Institution extends Model
{
    use HasUlids;

    protected $keyType = 'string';

    public $incrementing = false;

    public function memberships(): HasMany
    {
        return $this->hasMany(InstitutionMembership::class);
    }
}
