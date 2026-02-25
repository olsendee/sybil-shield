# Sybil Shield

A composable on-chain Sybil-resistance module for identity verification on Stacks/Clarity.

## Overview

Sybil Shield provides a lightweight framework for preventing Sybil attacks through authorized identity validation. Users register with unique identity hashes, and authorized validators verify identities on-chain.

## Features

- **Owner-Controlled Validators**: Manage authorized validators with add/remove permissions
- **Identity Registration**: Users can register with a unique 32-byte identity hash
- **Validator Verification**: Authorized validators verify registered identities
- **Status Queries**: Check identity registration and verification status

## Contract Functions

### Admin Functions
- `add-validator(principal)` - Register a new validator
- `remove-validator(principal)` - Revoke validator permissions

### User Functions
- `register-identity(buff 32)` - Register with an identity hash

### Validator Functions
- `verify-identity(principal)` - Verify a registered user identity

### Read-Only Functions
- `identity-status(principal)` - Get user identity details
- `is-verified?(principal)` - Check if user is verified
- `is-validator?(principal)` - Check validator status

## Error Codes

| Code | Meaning |
|------|---------|
| 19001 | Not contract owner |
| 19002 | Identity already registered |
| 19003 | Invalid proof or parameters |
| 19004 | Identity not found or unverified |

## Usage

```clarity
;; Register identity
(contract-call? .sybil-shield register-identity 0x...)

;; Check verification status
(contract-call? .sybil-shield is-verified? user-principal)
