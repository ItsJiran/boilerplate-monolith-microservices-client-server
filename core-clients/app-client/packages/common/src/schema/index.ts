// src/index.ts
import { z } from 'zod';

// Example: Common Auth Schema
export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8, 'Password must be at least 8 characters'),
});

export type LoginPayload = z.infer<typeof LoginSchema>;

// Example: User Profile Schema
export const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  role: z.enum(['admin', 'user']),
  created_at: z.string(),
});

export type User = z.infer<typeof UserSchema>;