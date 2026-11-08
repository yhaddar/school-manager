<?php

namespace App\Enums;

enum InstitutionRole: string
{
    case SuperAdmin = 'super-admin';
    case Director = 'director';
    case Administrator = 'administrator';
    case Teacher = 'teacher';
    case Staff = 'staff';
    case Professor = 'professor';
    case Student = 'student';
    case Parent = 'parent';

    /** @return list<string> */
    public function permissions(): array
    {
        if ($this === self::SuperAdmin) {
            return array_map(fn ($p) => $p->value, PlatformPermission::cases());
        }

        return match ($this) {
            self::Director, self::Administrator => [
                InstitutionPermission::ManageAccounts->value,
                InstitutionPermission::ManageInstitution->value,
                InstitutionPermission::ProvisionAccounts->value,
                InstitutionPermission::IssueParentInvitations->value,
                InstitutionPermission::ManageParentLinks->value,
                InstitutionPermission::ViewAuditLog->value,
            ],
            self::Teacher, self::Professor, self::Staff => [
                InstitutionPermission::IssueParentInvitations->value,
            ],
            self::Student, self::Parent => [],
        };
    }

    public function canProvision(): bool
    {
        if ($this === self::SuperAdmin) {
            return true;
        }

        return in_array(InstitutionPermission::ProvisionAccounts->value, $this->permissions(), true);
    }
}
