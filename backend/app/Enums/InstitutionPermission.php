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
    
    // Reports permissions
    case ViewReports = 'reports.view';
    case CreateReports = 'reports.create';
    case ManageReports = 'reports.manage';
    
    // Exports permissions
    case ViewExports = 'exports.view';
    case CreateExports = 'exports.create';
    case ManageExports = 'exports.manage';
    case ViewOwnExports = 'exports.view.own';
    
    // Imports permissions
    case ViewImports = 'imports.view';
    case CreateImports = 'imports.create';
    case ManageImports = 'imports.manage';
    case ViewOwnImports = 'imports.view.own';

    /** @return list<string> */
    public function roles(): array
    {
        // Director and Administrator have all permissions
        if ($this->value == 'reports.manage' 
            || $this->value == 'exports.manage' 
            || $this->value == 'imports.manage'
            || str_contains($this->value, '.own')) {
            return [
                InstitutionRole::Director->value,
                InstitutionRole::Administrator->value,
            ];
        }
        
        // View and create permissions for reports/exports/imports go to director/admin
        if (str_contains($this->value, 'reports') 
            || str_contains($this->value, 'exports') 
            || str_contains($this->value, 'imports')) {
            return [
                InstitutionRole::Director->value,
                InstitutionRole::Administrator->value,
            ];
        }
        
        return match ($this) {
            self::ManageAccounts,
            self::ManageInstitution,
            self::ProvisionAccounts,
            self::ManageParentLinks,
            self::ViewAuditLog,
            self::ViewReports,
            self::CreateReports,
            self::ManageReports => [
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
            self::ViewExports => [
                InstitutionRole::Director->value,
                InstitutionRole::Administrator->value,
            ],
            self::CreateExports => [
                InstitutionRole::Director->value,
                InstitutionRole::Administrator->value,
            ],
            self::ViewOwnExports,
            self::ViewImports,
            self::CreateImports => [
                InstitutionRole::Director->value,
                InstitutionRole::Administrator->value,
                InstitutionRole::Teacher->value,
                InstitutionRole::Professor->value,
            ],
        };
    }
}
