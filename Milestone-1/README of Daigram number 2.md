# Database Schema — Entity Relationship Diagram (ERD)

## Overview

This ERD represents the full database schema for a **freelance marketplace platform** that connects clients and freelancers. It covers user management, contract lifecycle, payment processing, dispute resolution, and system auditing. The schema is built around UUID primary keys and uses PostgreSQL-compatible data types throughout.

---

## Tables & Features

### 1. `users`
The central entity of the platform. Stores all registered users (both clients and freelancers).

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `email` | VARCHAR | User's email address |
| `phone` | VARCHAR | Contact phone number |
| `role` | ENUM | Role on the platform (client / freelancer) |
| `kyc_tier` | SMALLINT | Know Your Customer verification level |
| `is_active` | BOOLEAN | Account status |
| `created_at` | TIMESTAMP | Registration timestamp |

---

### 2. `user_profiles`
Extends `users` with professional and personal details.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `user_id` | UUID (FK → users) | Reference to the user |
| `bio` | TEXT | Professional biography |
| `skills` | TEXT[] | Array of skill tags |
| `portfolio_url` | VARCHAR | Link to portfolio |
| `city` | VARCHAR | City of residence |
| `country` | VARCHAR | Country of residence |

> Relationship: **1 : N** with `users` (one user can have one profile; the profile links back).

---

### 3. `wallets`
Manages the financial balances of each user on the platform.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `user_id` | UUID (FK → users) | Wallet owner (1:1 for client, 1:N for freelancer) |
| `balance` | NUMERIC(20,4) | Available funds |
| `locked_balance` | NUMERIC(20,4) | Funds held in escrow |
| `currency_code` | VARCHAR (FK → currencies) | Wallet currency |
| `is_frozen` | BOOLEAN | Whether the wallet is frozen |
| `updated_at` | TIMESTAMPTZ | Last update timestamp |

> Relationships: **1:1** with client users, **1:N** with freelancer users. Also linked to `currencies`.

---

### 4. `currencies`
A reference table for supported currencies on the platform.

| Column | Type | Description |
|---|---|---|
| `code` | VARCHAR (PK) | ISO currency code (e.g., USD) |
| `name` | VARCHAR | Full currency name |
| `symbol` | VARCHAR | Display symbol (e.g., $) |
| `is_active` | BOOLEAN | Whether the currency is currently supported |

> Used by `wallets` and `contracts` to normalize currency references.

---

### 5. `contracts`
The core business entity representing an agreement between a client and a freelancer.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `ref1` | VARCHAR (UQ) | Human-readable reference number |
| `client_id` | UUID (FK → users) | Contracting client |
| `freelancer_id` | UUID (FK → users) | Assigned freelancer |
| `title` | VARCHAR(255) | Contract title |
| `scope` | TEXT | Detailed scope of work |
| `total_amount` | NUMERIC(20,4) | Total contract value |
| `platform_fee` | NUMERIC(20,4) | Platform's fee amount |
| `currency_code` | VARCHAR (FK → currencies) | Contract currency |
| `status` | ENUM | Current contract status |
| `max_revisions / revision_count` | — | Allowed and used revision counts |
| `delivery_deadline` | TIMESTAMP | Final delivery date |
| `funded_at / completed_at / cancelled_at` | TIMESTAMP | Key lifecycle timestamps |
| `created_at / updated_at` | TIMESTAMP | Audit timestamps |

> Relationships: **N:1** with `users` (client & freelancer), **N:1** with `currencies`, **1:N** with `payments`, `milestones`, `contract_terms`, and `disputes`.

---

### 6. `contract_terms`
Stores structured terms and policies attached to a contract.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `contract_id` | UUID (FK → contracts) | Parent contract |
| `file_format_req` | TEXT | Required file format for deliverables |
| `revision_policy` | TEXT | Revision rules and conditions |
| `communication_notes` | TEXT | Notes on communication expectations |
| `late_penalty_pct` | NUMERIC | Percentage penalty for late delivery |

> Relationship: **1:1** with `contracts`.

---

### 7. `milestones`
Breaks contracts into trackable, fundable stages.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `contract_id` | UUID (FK → contracts) | Parent contract |
| `title` | VARCHAR(255) | Milestone name |
| `amount` | NUMERIC(20,4) | Amount tied to this milestone |
| `sequence` | SMALLINT | Order of the milestone |
| `status` | ENUM | Current milestone status |
| `due_date` | TIMESTAMP | Deadline for the milestone |
| `funded_at / released_at` | TIMESTAMP | Payment lifecycle timestamps |

> Relationship: **N:1** with `contracts`.

---

### 8. `payments`
Records all financial transactions on the platform.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `contract_id` | UUID (FK → contracts) | Associated contract |
| `user_id` | UUID (FK → users) | User involved in the payment |
| `amount` | NUMERIC(20,4) | Transaction amount |
| `gateway_code` | VARCHAR (FK → payment_gateways) | Payment gateway used |
| `status` | ENUM | Payment status |
| `direction` | ENUM | Inbound or outbound |
| `created_at` | TIMESTAMP | Transaction timestamp |

> Relationships: **N:1** with `contracts`, `users`, and `payment_gateways`.

---

### 9. `payment_gateways`
Reference table for available payment processors.

| Column | Type | Description |
|---|---|---|
| `code` | VARCHAR (PK) | Gateway identifier code |
| `display_name` | VARCHAR | Human-readable gateway name |
| `is_active` | BOOLEAN | Whether the gateway is currently enabled |

> Relationship: **1:N** with `payments`.

---

### 10. `disputes`
Handles conflict resolution between clients and freelancers.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `contract_id` | UUID (FK → contracts) | Disputed contract |
| `raised_by` | UUID (FK → users) | User who raised the dispute |
| `reason` | ENUM | Category/reason for the dispute |
| `status` | ENUM | Current dispute status |
| `assigned_to` | UUID (FK → users) | Assigned moderator/admin |
| `resolution_type` | ENUM | How the dispute was resolved |
| `resolution_note` | TEXT | Details of resolution |
| `resolved_at` | TIMESTAMP | Resolution timestamp |

> Relationships: **N:1** with `contracts` and `users`.

---

### 11. `dispute_evidence`
Stores supporting files and documentation submitted during a dispute.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `dispute_id` | UUID (FK → disputes) | Parent dispute |
| `submitted_by` | UUID (FK → users) | User who uploaded the evidence |
| `file_s3_key` | TEXT | S3 storage key for the uploaded file |
| `description` | TEXT | Description of the evidence |
| `submitted_at` | TIMESTAMP | Submission timestamp |

> Relationship: **N:1** with `disputes` and `users`.

---

### 12. `kyc_documents`
Manages identity verification documents for users.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `user_id` | UUID (FK → users) | Document owner |
| `document_type` | ENUM | Type of ID document |
| `file_s3_key` | TEXT | S3 storage key |
| `status` | ENUM | Verification status |
| `reviewed_by` | UUID (FK → users) | Admin who reviewed the document |

> Relationship: **N:1** with `users`.

---

### 13. `notifications`
Tracks system and platform notifications sent to users.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `user_id` | UUID (FK → users) | Notification recipient |
| `event_type` | ENUM | Type of event that triggered the notification |
| `channel` | ENUM | Delivery channel (email, SMS, push, etc.) |
| `payload` | JSONB | Notification content as structured JSON |
| `status` | ENUM | Delivery status |
| `sent_at` | TIMESTAMPTZ | Time the notification was sent |

> Relationship: **N:1** with `users`.

---

### 14. `audit_logs`
Full audit trail for all significant actions performed on the platform.

| Column | Type | Description |
|---|---|---|
| `id` | UUID (PK) | Unique identifier |
| `actor_id` | UUID (FK → users) | User who performed the action |
| `action` | VARCHAR | Action performed (e.g., `contract.created`) |
| `entity_type` | VARCHAR | Type of entity affected |
| `entity_id` | UUID | ID of the affected entity |
| `before_snapshot` | JSONB | State of the entity before the action |
| `after_snapshot` | JSONB | State of the entity after the action |
| `ip_address / user_agent` | — | Request metadata for security tracing |
| `created_at / chain_hash` | — | Timestamp and integrity hash for tamper detection |

> Relationship: **N:1** with `users`.

---

## Entity Relationships Summary

```
users ─────────────────┬──── user_profiles (1:N)
                       ├──── wallets (1:1 client / 1:N freelancer)
                       ├──── kyc_documents (1:N)
                       ├──── notifications (1:N)
                       ├──── audit_logs (1:N)
                       ├──── contracts as client (1:N)
                       └──── contracts as freelancer (1:N)

contracts ─────────────┬──── contract_terms (1:1)
                       ├──── milestones (1:N)
                       ├──── payments (1:N)
                       └──── disputes (1:N)

disputes ──────────────└──── dispute_evidence (1:N)

wallets ───────────────└──── currencies (N:1)
contracts ─────────────└──── currencies (N:1)
payments ──────────────└──── payment_gateways (N:1)
```

---

## Key Design Decisions

- **UUID keys throughout** — all primary keys use UUID for distributed-safe ID generation and security by obscurity.
- **NUMERIC(20,4) for money** — avoids floating-point precision errors in financial calculations.
- **ENUM types** — used for status fields (`contract status`, `payment direction`, `KYC status`, etc.) to enforce data integrity at the database level.
- **JSONB snapshots in audit_logs** — enables full before/after state tracking without a separate history table per entity.
- **S3-based file references** — `kyc_documents`, `dispute_evidence` store S3 keys rather than raw files, keeping the database lean.
- **Locked balance in wallets** — separates available funds from funds held in escrow during active contracts.
- **Chain hash in audit_logs** — supports tamper-evident logging, useful for compliance and fraud detection.
- **Soft deletes via `is_active`** — users, currencies, and payment gateways use boolean flags rather than hard deletes.
