<?php

namespace App\Enums;

enum InstitutionPermission: string
{
    case ManageAccounts = 'accounts.manage';
    case ManageInstitution = 'institution.manage';
    case ProvisionAccounts = 'accounts.provision';
    case IssueParentInvitations = 'parent.invite';
    case ManageParentLinks = 'parent.links.manage';
    case ViewAuditLog = 'audit.view';

    /** @return list<string> */
    public function roles(): array
    {
        return match ($this) {
            self::ManageAccounts,
            self::ManageInstitution,
            self::ProvisionAccounts,
            self::ManageParentLinks,
            self::ViewAuditLog => [
                InstitutionRole::Director->value,
                InstitutionRole::Administrator->value,
            ],
            self::IssueParentInvitations => [
                InstitutionRole::Director->value,
                InstitutionRole::Administrator->value,
                InstitutionRole::Teacher->value,
                InstitutionRole::Professor->value,
                InstitutionRole::Staff->value,
            ],
        };
    }
}
