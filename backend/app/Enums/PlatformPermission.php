<?php

namespace App\Enums;

enum PlatformPermission: string
{
    case SuperAdmin = 'super-admin';
    case ViewInstitutions = 'institutions.view';
    case CreateSubscriptions = 'subscriptions.create';
    case ViewAnalytics = 'analytics.view';
    case ManageUsers = 'users.manage';
}
