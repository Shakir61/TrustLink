# TrustLink 🔐

> **Pakistan's trusted digital escrow infrastructure — securing transactions between buyers and sellers across freelance, commerce, and B2B markets.**
## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Database Design Overview](#database-design-overview)
- [Escrow Workflow](#escrow-workflow)

---

## Overview

### The Problem: Trust Deficit in Pakistan's Digital Economy

Pakistan's digital commerce ecosystem is growing rapidly — from freelancers on global platforms to local social commerce sellers on Facebook and WhatsApp, to B2B service providers. Yet a fundamental problem persists: **there is no widely accessible, neutral third-party mechanism to hold funds safely while both parties fulfill their obligations**.

The result is systemic:
- Buyers fear paying upfront for goods or services that may never arrive.
- Sellers fear delivering work before receiving payment.
- Disputes are resolved informally, unfairly, or not at all.
- High-value transactions — property deposits, equipment procurement, contract milestones — carry extreme counterparty risk.

This trust gap suppresses transaction volumes, increases friction, and ultimately limits economic participation.

### The Solution: TrustLink

**TrustLink** is a digital escrow platform designed specifically for the Pakistani market. Inspired by the operational model of [Transpact](https://www.transpact.com) (UK), TrustLink introduces a structured, technology-driven escrow layer that sits between transacting parties and acts as a neutral custodian of funds.

When a transaction is initiated:
1. The buyer deposits funds into a secure, platform-held escrow wallet.
2. The seller delivers the agreed product, service, or milestone.
3. The buyer confirms receipt and satisfaction.
4. PakEscrow releases the funds to the seller.
5. If a dispute arises, TrustLink moderation team adjudicates based on submitted evidence.

The platform is purpose-built for **freelancers**, **online marketplaces**, **social commerce sellers**, **B2B service agreements**, and **real estate/rental deposits**.

### Why Escrow Matters in Pakistan

| Context | Problem Without Escrow | How PakEscrow Solves It |
|---|---|---|
| Freelancers | Clients disappear post-delivery | Funds locked in escrow before work starts |
| Social Commerce | Buyers send payment; goods never arrive | Seller proves shipment before funds release |
| B2B Contracts | Partial payment abuse | Milestone-based fund release |
| Real Estate | Security deposit disputes | Neutral custodian with signed conditions |
| Marketplaces | Platform liability for fraud | Built-in escrow as a service (EaaS) |

---

## Features

### Authentication & Identity

- **Email/Phone Registration** with OTP verification via SMS (Jazz/Telenor/Ufone) and email
- **JWT-based stateless authentication** with short-lived access tokens and rotating refresh tokens
- **Role-based access control (RBAC)** with roles: `BUYER`, `SELLER`, `ADMIN`, `MODERATOR`, `COMPLIANCE_OFFICER`
- **Two-Factor Authentication (2FA)** via TOTP (Google Authenticator / Authy)
- **Device fingerprinting** and anomalous login detection
- **Account suspension, deactivation, and re-activation** workflows

### Escrow Transaction Management

- **Create escrow agreements** with defined terms, delivery deadlines, and acceptance criteria
- **Single-payment escrow** for straightforward buyer-seller transactions
- **Milestone-based escrow** for phased services (e.g., software development, construction)
- **Transaction state machine**: `DRAFT → FUNDED → IN_PROGRESS → DELIVERED → COMPLETED | DISPUTED | CANCELLED | REFUNDED`
- **Delivery confirmation** with optional file/evidence upload by seller
- **Buyer approval** or rejection with required justification
- **Automatic expiry** handling with configurable timeout and fund return logic
- **Escrow fee calculation** (platform percentage + fixed component, configurable per tier)
- **Transaction reference numbers** with audit-grade traceability

### Wallet Management

- **Platform-managed virtual wallets** per user with real-time balance tracking
- **Escrow wallet separation** — in-escrow funds are held in isolated sub-wallets, not commingled
- **Ledger-based balance accounting** — every credit/debit is a ledger entry; balance = derived state
- **Withdrawal requests** to linked bank accounts or JazzCash/EasyPaisa mobile wallets
- **Deposit funding** via bank transfer reference or payment gateway
- **Wallet freeze/unfreeze** by admin on suspicious activity
- **Balance reconciliation reports** for internal audit

### Dispute Resolution

- **Buyer or seller can open a dispute** during an active escrow transaction
- **Evidence submission system** — both parties upload documents, screenshots, communications
- **Dispute states**: `RAISED → UNDER_REVIEW → EVIDENCE_SUBMITTED → DECISION_PENDING → RESOLVED | ESCALATED`
- **Moderator assignment** with SLA tracking (target: 72-hour initial response)
- **Decision engine** with resolution options: full release, partial split, full refund
- **Escalation path** to senior compliance officer for high-value or complex disputes
- **Audit trail** of all moderator actions and timeline events

### Admin Dashboard

- **Transaction oversight** with real-time status monitoring and filtering
- **User management** — view, suspend, verify, flag, and manage all user accounts
- **KYC review queue** — approve, reject, or request resubmission of verification documents
- **Dispute management console** — assign moderators, update statuses, log decisions
- **Financial reporting** — daily/monthly transaction volumes, fee revenue, withdrawal summaries
- **Platform configuration** — manage fee structures, transaction limits, supported payment channels
- **Compliance alerts** — flag large transactions, unusual patterns, and SBP-threshold triggers
- **Audit log explorer** — searchable, tamper-evident log of all platform events

### KYC / Identity Verification

- **Tiered KYC model**:
  - Tier 1 (Basic): Phone + email verification → limited transaction caps
  - Tier 2 (Standard): CNIC upload + selfie → standard transaction limits
  - Tier 3 (Enhanced): CNIC + proof of address + business registration → high-value access
- **CNIC OCR extraction** for automated field pre-fill
- **Liveness detection** integration for selfie verification (via third-party provider)
- **Document status tracking**: `PENDING → UNDER_REVIEW → APPROVED | REJECTED | EXPIRED`
- **Re-verification triggers** on suspicious activity or regulatory request
- **Business KYB (Know Your Business)** for merchants and B2B accounts

### Notification System

- **Multi-channel delivery**: Email (SendGrid), SMS (Twilio/Nayatel), In-app push notifications
- **Event-driven notification triggers** for all transaction lifecycle events
- **Notification preferences** per user (opt-in/out per channel and event type)
- **Templated notification engine** with variable injection
- **Delivery status tracking** and retry logic for failed deliveries
- **Admin broadcast notifications** for platform announcements

### Transaction History & Reporting

- **Full transaction ledger** per user with chronological event history
- **Downloadable PDF/CSV statements** for individual or date-range exports
- **Escrow performance metrics** — average completion time, dispute rate, satisfaction score
- **Seller reputation scoring** based on completed transactions and dispute history
- **Search and filter** by status, amount, counterparty, date, transaction ID

### Audit Logging

- **Immutable audit log** for all state-changing operations (transactions, KYC decisions, admin actions)
- **Log entries include**: actor, action, affected entity, timestamp, IP address, before/after state snapshot
- **Tamper detection** via log entry chaining (sequential hash linking)
- **Log retention policy** configurable per regulatory requirement (default: 7 years)
- **Export capability** for compliance investigation and legal discovery

### Payment Integration

- **JazzCash** — Pakistan's leading mobile wallet (API v2.0)
- **EasyPaisa** — Mobile money and bank transfer gateway
- **HBL PayConnect** — Bank-grade card and account payment gateway
- **1Link** — Interbank Fund Transfer (IBFT) support for bank-to-escrow deposits
- **Stripe (optional)** — International card payments for cross-border escrow
- **Webhook-based payment confirmation** with idempotency guarantees
- **Payment retry and failure handling** with user notification

### Security Features

- **AES-256 encryption** for sensitive stored data (CNIC numbers, bank account details)
- **TLS 1.3** enforced on all endpoints
- **OWASP Top 10** hardening on all API surfaces
- **Rate limiting** per IP and per user on all authentication and transaction endpoints
- **SQL injection prevention** via parameterized ORM queries
- **Helmet.js headers** (HSTS, CSP, X-Frame-Options, etc.)
- **CSRF protection** on all state-mutating endpoints
- **Secrets management** via environment isolation (HashiCorp Vault in production)

---

## Tech Stack

### Frontend

| Technology | Purpose |
|---|---|
| **Next.js 14** (App Router) | React-based SSR/SSG framework for buyer/seller portal |
| **TypeScript** | Type safety across all frontend code |
| **Tailwind CSS** | Utility-first styling framework |
| **Shadcn/UI** | Accessible, composable component library |
| **React Query (TanStack)** | Server state management and caching |
| **Zustand** | Lightweight client-side state management |
| **React Hook Form + Zod** | Form management with schema validation |
| **Axios** | HTTP client with interceptors for auth token handling |
| **Recharts** | Data visualization for dashboards and analytics |

### Backend

| Technology | Purpose |
|---|---|
| **NestJS 10** | Opinionated Node.js framework with DI, modular architecture |
| **TypeScript** | Type safety and interface contracts |
| **TypeORM** | Database ORM with entity-based modeling and migrations |
| **Passport.js** | Authentication strategies (JWT, local, OAuth) |
| **Bull (BullMQ)** | Redis-backed job queues for async processing |
| **class-validator / class-transformer** | DTO validation and transformation |
| **Winston** | Structured logging with transport layers |
| **Node.js 18+** | Runtime environment |

### Database

| Technology | Purpose |
|---|---|
| **PostgreSQL 15** | Primary relational database for all financial data |
| **Redis 7** | Session store, caching, rate limiting, job queues |
| **pgcrypto** | PostgreSQL extension for column-level encryption |
| **pg_audit** | Database-level audit logging for compliance |

### Authentication & Security

| Technology | Purpose |
|---|---|
| **JWT (RS256)** | Asymmetric signed access tokens |
| **bcrypt** | Password hashing (cost factor: 12) |
| **Argon2** | Alternative password hashing for new accounts |
| **OTP via SMS** | Phone number verification |
| **TOTP (speakeasy)** | Time-based 2FA for high-privilege actions |
| **Helmet.js** | HTTP security headers middleware |
| **express-rate-limit** | Request throttling |

### Deployment & Infrastructure

| Technology | Purpose |
|---|---|
| **Docker + Docker Compose** | Local development and containerized deployment |
| **AWS EC2 / DigitalOcean Droplets** | Application hosting |
| **AWS RDS (PostgreSQL)** | Managed database with automated backups |
| **AWS ElastiCache (Redis)** | Managed Redis cluster |
| **AWS S3** | KYC document and evidence file storage |
| **NGINX** | Reverse proxy, SSL termination, load balancing |
| **GitHub Actions** | CI/CD pipeline for automated testing and deployment |
| **PM2** | Process management for Node.js in production |

### Payment Integrations

| Gateway | Channel |
|---|---|
| **JazzCash REST API** | Mobile wallet deposits/withdrawals |
| **EasyPaisa API** | Mobile wallet and OTC payments |
| **HBL PayConnect** | Card and bank account payments |
| **1Link IBFT** | Interbank transfers |
| **Stripe (optional)** | International card payments |

### API & Documentation

| Technology | Purpose |
|---|---|
| **Swagger / OpenAPI 3.0** | Auto-generated interactive API documentation |
| **@nestjs/swagger** | NestJS decorator-based Swagger generation |
| **Postman Collections** | Exported API collections for developer onboarding |

---

## System Architecture

TrustLink follows a **modular monolith** architecture for the MVP phase, designed to decompose into microservices as transaction volume scales. The system is organized around clear domain boundaries with strict internal module contracts.

### Architectural Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CLIENT LAYER                               │
│                                                                     │
│   ┌──────────────────┐          ┌──────────────────────────────┐   │
│   │  Buyer/Seller    │          │     Admin Dashboard          │   │
│   │  Portal          │          │     (Next.js)                │   │
│   │  (Next.js)       │          │                              │   │
│   └────────┬─────────┘          └──────────────┬───────────────┘   │
└────────────┼──────────────────────────────────┼───────────────────┘
             │  HTTPS / REST API                 │  HTTPS / REST API
             ▼                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        API GATEWAY LAYER                            │
│              NGINX (Reverse Proxy + Rate Limiting + TLS)            │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
             ┌───────────────────▼──────────────────────┐
             │           NestJS Application              │
             │                                           │
             │  ┌──────────┐  ┌──────────┐  ┌────────┐ │
             │  │   Auth   │  │ Escrow   │  │ Wallet │ │
             │  │  Module  │  │  Module  │  │ Module │ │
             │  └──────────┘  └──────────┘  └────────┘ │
             │                                           │
             │  ┌──────────┐  ┌──────────┐  ┌────────┐ │
             │  │ Dispute  │  │   KYC    │  │ Admin  │ │
             │  │  Module  │  │  Module  │  │ Module │ │
             │  └──────────┘  └──────────┘  └────────┘ │
             │                                           │
             │  ┌──────────┐  ┌──────────┐  ┌────────┐ │
             │  │Notif.    │  │ Audit    │  │Payment │ │
             │  │Module    │  │  Module  │  │Module  │ │
             │  └──────────┘  └──────────┘  └────────┘ │
             └──────┬──────────────┬────────────────────┘
                    │              │
          ┌─────────▼───┐   ┌──────▼─────────┐
          │ PostgreSQL  │   │  Redis          │
          │ (Primary DB)│   │  (Cache/Queue)  │
          └─────────────┘   └────────────────┘
                    │
          ┌─────────▼──────────────────────┐
          │     External Services           │
          │                                 │
          │  ┌──────────┐  ┌─────────────┐ │
          │  │JazzCash  │  │  SendGrid   │ │
          │  │EasyPaisa │  │  (Email)    │ │
          │  │HBL Pay   │  │  Twilio SMS │ │
          │  └──────────┘  └─────────────┘ │
          │                                 │
          │  ┌──────────────────────────┐  │
          │  │     AWS S3               │  │
          │  │  (KYC Docs / Evidence)   │  │
          │  └──────────────────────────┘  │
          └────────────────────────────────┘
```

### Layer Descriptions

**Frontend Architecture**
The buyer/seller portal is a Next.js 14 application using the App Router for file-system routing, Server Components for SEO-critical pages, and Client Components for interactive transaction flows. The admin dashboard is a separate Next.js app with stricter route protection. Both applications communicate exclusively via the REST API with JWT bearer tokens.

**Backend Architecture**
The NestJS backend is organized into domain modules, each encapsulating its own controllers, services, entities, and DTOs. Cross-cutting concerns (authentication guards, logging interceptors, exception filters, validation pipes) are applied globally. Background jobs (notification dispatch, payment status polling, expiry checks) are processed via BullMQ workers backed by Redis.

**Database Layer**
PostgreSQL serves as the single source of truth for all transactional data. TypeORM manages entity definitions, relations, and migrations. All financial operations are executed within database transactions to guarantee ACID compliance. Redis is used for ephemeral state: session tokens, rate limit counters, job queues, and computed cache values.

**Payment Gateway Layer**
Payment integrations are abstracted behind a `PaymentGatewayService` interface. Each gateway (JazzCash, EasyPaisa, HBL) is implemented as a strategy. This allows switching or adding gateways without modifying escrow business logic. Webhook handlers validate HMAC signatures before processing any payment confirmation event.

**Admin Services**
The admin module exposes privileged endpoints accessible only to users with `ADMIN`, `MODERATOR`, or `COMPLIANCE_OFFICER` roles. Admin actions are doubly logged — at the application audit layer and optionally at the database `pg_audit` layer.

**Notification Services**
The notification module is event-driven. Domain services emit events (`EscrowFunded`, `DisputeRaised`, `KycApproved`, etc.) which are consumed by the notification service. Delivery is handled asynchronously via BullMQ to avoid blocking the request-response cycle.

---

## Database Design Overview

### Why PostgreSQL

PostgreSQL was selected as the exclusive persistent store for TrustLink based on its suitability for financial workloads:

- **ACID Transactions**: Every fund movement — deposit, escrow lock, release, refund — must be atomic. PostgreSQL's transaction semantics guarantee that a partial failure at any point rolls back the entire operation, preventing phantom credits or missing debits.
- **Row-level locking**: `SELECT ... FOR UPDATE` allows pessimistic locking on wallet balance rows, preventing double-spend scenarios under concurrent requests.
- **Foreign key constraints**: Relational integrity ensures that a payment cannot reference a non-existent escrow transaction; a dispute cannot be raised without a valid linked transaction.
- **Audit extensions**: `pg_audit` provides statement and object-level auditing at the database layer, independent of application logic.
- **JSON support**: `jsonb` columns store flexible metadata (transaction terms, evidence files, gateway responses) without requiring schema migrations for every variation.
- **Proven financial use**: PostgreSQL underpins major fintech infrastructure globally (Stripe, Wise, and others use PostgreSQL at scale).

### Core Entity Overview

```
┌─────────────┐       ┌──────────────────┐       ┌────────────────┐
│    users    │──────▶│     wallets      │       │  kyc_documents │
│─────────────│       │──────────────────│       │────────────────│
│ id (UUID)   │       │ id               │       │ id             │
│ email       │       │ user_id (FK)     │       │ user_id (FK)   │
│ phone       │       │ balance          │       │ document_type  │
│ role        │       │ locked_balance   │       │ file_s3_key    │
│ kyc_tier    │       │ currency         │       │ status         │
│ is_active   │       │ is_frozen        │       │ reviewed_by    │
│ created_at  │       │ updated_at       │       │ reviewed_at    │
└──────┬──────┘       └─────────┬────────┘       └────────────────┘
       │                        │
       │              ┌─────────▼──────────────────────────────────┐
       │              │         TrustLink_transactions                 │
       │              │─────────────────────────────────────────── │
       │              │ id (UUID)                                   │
       │              │ reference_number (unique, indexed)          │
       │              │ buyer_id (FK → users)                       │
       │              │ seller_id (FK → users)                      │
       │              │ amount (NUMERIC 20,4)                       │
       │              │ platform_fee (NUMERIC 20,4)                 │
       │              │ currency (VARCHAR, default 'PKR')           │
       │              │ status (ENUM)                               │
       │              │ terms (JSONB)                               │
       │              │ delivery_deadline                           │
       │              │ funded_at, completed_at, cancelled_at       │
       │              │ created_at, updated_at                      │
       │              └─────────┬──────────────────────────────────┘
       │                        │
       ├────────────────────────┼───────────────────────────────────┐
       │                        │                                   │
┌──────▼──────────┐   ┌─────────▼─────────┐           ┌───────────▼──────┐
│    payments     │   │    milestones      │           │    disputes      │
│─────────────────│   │────────────────────│           │──────────────────│
│ id              │   │ id                 │           │ id               │
│ escrow_tx_id    │   │ escrow_tx_id (FK)  │           │ escrow_tx_id (FK)│
│ user_id         │   │ title              │           │ raised_by (FK)   │
│ amount          │   │ amount             │           │ reason           │
│ gateway         │   │ sequence           │           │ status (ENUM)    │
│ gateway_ref     │   │ status             │           │ assigned_to (FK) │
│ status          │   │ due_date           │           │ resolution       │
│ direction       │   │ funded_at          │           │ resolved_at      │
│ created_at      │   │ released_at        │           │ created_at       │
└─────────────────┘   └────────────────────┘           └──────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                          audit_logs                                  │
│──────────────────────────────────────────────────────────────────── │
│ id | actor_id | action | entity_type | entity_id | before_snapshot  │
│ after_snapshot | ip_address | user_agent | created_at | chain_hash  │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                        notifications                                 │
│──────────────────────────────────────────────────────────────────── │
│ id | user_id | event_type | channel | payload | status | sent_at    │
└──────────────────────────────────────────────────────────────────────┘
```

### Financial Data Integrity Principles

- All monetary amounts are stored as `NUMERIC(20, 4)` — never `FLOAT` or `DOUBLE PRECISION`, which introduce floating-point rounding errors unacceptable in financial contexts.
- Currency is stored explicitly on every monetary record; no implicit default assumptions.
- Wallet balance is never updated directly. All balance changes flow through ledger entries; the balance column is a materialized snapshot refreshed atomically within the same transaction.
- Soft deletes only — no financial record is ever hard-deleted. `deleted_at` timestamp marks logical deletion.

---

## TrustLink Workflow

### Transaction Lifecycle

```
BUYER                         TrustLink                         SELLER
  │                               │                               │
  │  1. Create Transaction        │                               │
  │──────────────────────────────▶│                               │
  │  (terms, amount, seller info) │                               │
  │                               │  2. Notify Seller             │
  │                               │──────────────────────────────▶│
  │                               │                               │
  │  3. Deposit Funds             │                               │
  │──────────────────────────────▶│                               │
  │  (via JazzCash / EasyPaisa /  │                               │
  │   Bank Transfer)              │                               │
  │                               │  4. Confirm Funding           │
  │                               │──────────────────────────────▶│
  │                               │   [Status: IN_PROGRESS]       │
  │                               │                               │
  │                               │  5. Seller Delivers           │
  │                               │◀──────────────────────────────│
  │                               │  (uploads proof/evidence)     │
  │                               │                               │
  │  6. Delivery Notification     │                               │
  │◀──────────────────────────────│                               │
  │                               │                               │
  │  7a. APPROVE Delivery         │                               │
  │──────────────────────────────▶│                               │
  │                               │                               │
  │                               │  8. Release Funds to Seller   │
  │                               │──────────────────────────────▶│
  │                               │   [Status: COMPLETED]         │
  │                               │                               │
  │  ─────────── OR ───────────── │                               │
  │                               │                               │
  │  7b. RAISE DISPUTE            │                               │
  │──────────────────────────────▶│                               │
  │                               │                               │
  │                               │  Dispute Notified             │
  │                               │──────────────────────────────▶│
  │                               │                               │
  │  Submit Evidence              │  Submit Evidence              │
  │──────────────────────────────▶│◀──────────────────────────────│
  │                               │                               │
  │                               │  [Moderator Reviews]          │
  │                               │                               │
  │  Decision Notification        │  Decision Notification        │
  │◀──────────────────────────────│──────────────────────────────▶│
  │  (Refund / Partial / Release) │                               │
```

### Escrow Status State Machine

```
             ┌──────────┐
             │  DRAFT   │  ← Transaction created, not yet funded
             └────┬─────┘
                  │ Buyer deposits payment
                  ▼
             ┌──────────┐
             │  FUNDED  │  ← Payment confirmed, funds locked
             └────┬─────┘
                  │ Seller accepts & begins work
                  ▼
          ┌─────────────┐
          │ IN_PROGRESS │  ← Work underway, funds locked
          └──────┬──────┘
                 │
        ┌────────▼────────┐
        │    DELIVERED    │  ← Seller marks delivery
        └────────┬────────┘
                 │
     ┌───────────┼───────────────┐
     │           │               │
     ▼           ▼               ▼
┌─────────┐ ┌──────────┐ ┌───────────┐
│COMPLETED│ │DISPUTED  │ │ CANCELLED │
│         │ │          │ │           │
│ Funds   │ │ Moderator│ │  Refunded │
│ Released│ │ Reviews  │ │  to Buyer │
└─────────┘ └────┬─────┘ └───────────┘
                 │
        ┌────────┴────────┐
        │                 │
        ▼                 ▼
  ┌──────────┐     ┌──────────────┐
  │RESOLVED  │     │  ESCALATED   │
  │(Decision)│     │(Sr. Review)  │
  └──────────┘     └──────────────┘
```

### Milestone TrustLink Flow

For phased agreements (e.g., a 3-milestone software project):

```
Total Escrow: PKR 150,000
├── Milestone 1: Requirements & Design    → PKR 30,000  (20%)
│     └── [FUNDED → DELIVERED → RELEASED]
├── Milestone 2: Development              → PKR 90,000  (60%)
│     └── [FUNDED → DELIVERED → RELEASED]
└── Milestone 3: Testing & Handover       → PKR 30,000  (20%)
      └── [FUNDED → DELIVERED → RELEASED]
```

Each milestone independently moves through the `FUNDED → IN_PROGRESS → DELIVERED → COMPLETED` lifecycle. A dispute on one milestone does not freeze the others unless the buyer escalates the full transaction.

---

## Security Considerations

Security in a fintech platform is non-negotiable. PakEscrow applies a **defense-in-depth** strategy across all layers.

### Authentication & Session Security

- **Password hashing**: Passwords are hashed using `bcrypt` with a cost factor of 12 (or `Argon2id` for new registrations). Plaintext passwords are never logged, stored, or transmitted.
- **JWT token strategy**: Access tokens are signed with RS256 (asymmetric) and expire in 15 minutes. Refresh tokens are rotated on each use, stored as `SHA-256` hashed values in the database (never plaintext), and invalidated on logout or suspicious activity.
- **Secure session management**: All authentication state is server-validated. Stateless JWTs are not trusted blindly — revocation lists in Redis allow immediate invalidation of compromised tokens.
- **2FA enforcement**: Sensitive operations (withdrawal requests, KYC approval, admin actions) require TOTP re-verification regardless of active session.
