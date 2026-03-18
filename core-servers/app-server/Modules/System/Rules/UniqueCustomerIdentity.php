<?php

namespace Modules\System\Rules;

use Modules\System\Enums\CustomerType;
use Modules\System\Enums\IdentityType;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Support\Facades\DB;

class UniqueCustomerIdentity implements ValidationRule
{
    public function __construct(
        private int $tenantId,
        private string $customerType,
        private string $identityType, // 'EMAIL' or 'PHONE'
        private ?string $excludeSlug = null
    ) {}

    public function validate(string $attribute, mixed $value, \Closure $fail): void
    {
        if (empty($value)) {
            return; // Skip validation if value is empty (handled by nullable rule)
        }

        // Normalize phone numbers for comparison
        if (in_array($this->identityType, ['PHONE', 'WA'])) {
            $value = $this->normalizePhoneNumber($value);
        }

        $customerType = CustomerType::from($this->customerType);
        
        // For ORGANIZATION customers, only validate EMAIL
        if ($customerType === CustomerType::ORGANIZATION && $this->identityType === 'PHONE') {
            return; // Phone numbers can be duplicated for organizations
        }

        // Build query to check for duplicates
        $query = DB::table('customer_identities')
            ->join('customers', 'customer_identities.customer_id', '=', 'customers.id')
            ->where('customers.tenant_id', $this->tenantId)
            ->where('customers.customer_type', $customerType->value)
            ->where('customer_identities.identity_value', $value);

        // For EMAIL type, check EMAIL identity
        if ($this->identityType === 'EMAIL') {
            $query->where('customer_identities.identity_type', IdentityType::EMAIL->value);
        }
        
        // For PHONE type, check both PHONE and WA identities
        if ($this->identityType === 'PHONE') {
            $query->whereIn('customer_identities.identity_type', [
                IdentityType::PHONE->value,
                IdentityType::WA->value
            ]);
        }

        // Exclude current customer when updating
        if ($this->excludeSlug) {
            $query->where('customers.slug', '!=', $this->excludeSlug);
        }

        $exists = $query->exists();

        if ($exists) {
            $typeLabel = $customerType->label();
            $identityLabel = $this->identityType === 'EMAIL' ? 'email' : 'nomor telepon';
            
            $fail("Sudah ada customer {$typeLabel} dengan {$identityLabel} yang sama di tenant ini.");
        }
    }

    /**
     * Normalize phone number to +62 format
     */
    private function normalizePhoneNumber(string $value): ?string
    {
        // Remove all non-digit characters
        $digits = preg_replace('/\D+/', '', $value);

        if (!$digits) {
            return null;
        }

        // Normalize prefix
        if (str_starts_with($digits, '0')) {
            // Remove leading 0
            $digits = substr($digits, 1);
        } elseif (str_starts_with($digits, '62')) {
            // Remove 62 prefix
            $digits = substr($digits, 2);
        }

        return '+62' . $digits;
    }
}
