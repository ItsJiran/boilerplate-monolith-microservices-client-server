<?php

namespace Modules\System\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateTenantRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'slug' => [
                'required',
                'string',
                'max:255',
                Rule::unique('tenants', 'slug')->ignore($this->tenant),
            ],
            'profile_path' => ['nullable', 'string', 'max:255'],
        ];
    }
}
