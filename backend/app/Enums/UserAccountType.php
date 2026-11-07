<?php

namespace App\Enums;

enum UserAccountType: string
{
    case Staff = 'staff';
    case Student = 'student';
    case Parent = 'parent';

    /** @return list<string> */
    public function defaultRole(): array
    {
        return match ($this) {
            self::Staff => ['staff'],
            self::Student => ['student'],
            self::Parent => ['parent'],
        };
    }

    /** @return list<string> */
    public function membershipRoles(): array
    {
        return match ($this) {
            self::Staff => ['staff', 'administrator', 'director', 'teacher'],
            self::Student => ['student'],
            self::Parent => ['parent'],
        };
    }

    /** @return list<string> */
    public static function provisionableTypes(): array
    {
        return [self::Staff->value, self::Student->value];
    }
}
