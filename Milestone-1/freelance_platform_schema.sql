-- =============================================================
--  PakEscrow — Table Creation Statements
-- =============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================
-- ENUM TYPES
-- =============================================================

CREATE TYPE user_role AS ENUM (
    'FREELANCER', 'CLIENT', 'ADMIN', 'MODERATOR', 'COMPLIANCE_OFFICER'
);

CREATE TYPE document_type AS ENUM (
    'CNIC_FRONT', 'CNIC_BACK', 'SELFIE', 'PROOF_OF_ADDRESS'
);

CREATE TYPE kyc_status AS ENUM (
    'PENDING', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'EXPIRED'
);

CREATE TYPE contract_status AS ENUM (
    'DRAFT', 'PENDING_ACCEPTANCE', 'FUNDED', 'IN_PROGRESS',
    'DELIVERED', 'COMPLETED', 'DISPUTED', 'CANCELLED', 'REFUNDED'
);

CREATE TYPE payment_gateway AS ENUM (
    'JAZZCASH', 'EASYPAISA', 'HBL', 'BANK_TRANSFER'
);

CREATE TYPE payment_status AS ENUM (
    'PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'
);

CREATE TYPE payment_direction AS ENUM (
    'DEPOSIT', 'WITHDRAWAL', 'RELEASE'
);

CREATE TYPE milestone_status AS ENUM (
    'PENDING', 'IN_PROGRESS', 'DELIVERED', 'APPROVED', 'DISPUTED', 'CANCELLED'
);

CREATE TYPE dispute_reason AS ENUM (
    'NON_DELIVERY', 'QUALITY_NOT_MET', 'SCOPE_DISAGREEMENT',
    'LATE_DELIVERY', 'PAYMENT_WITHHELD', 'OTHER'
);

CREATE TYPE dispute_status AS ENUM (
    'RAISED', 'UNDER_REVIEW', 'EVIDENCE_SUBMITTED',
    'DECISION_PENDING', 'RESOLVED', 'ESCALATED'
);

CREATE TYPE resolution_type AS ENUM (
    'FULL_RELEASE', 'FULL_REFUND', 'PARTIAL_SPLIT'
);

CREATE TYPE notification_channel AS ENUM (
    'EMAIL', 'SMS', 'IN_APP'
);

CREATE TYPE notification_status AS ENUM (
    'PENDING', 'SENT', 'FAILED'
);

CREATE TYPE notification_event AS ENUM (
    'CONTRACT_FUNDED', 'DELIVERY_SUBMITTED', 'DISPUTE_RAISED',
    'FUNDS_RELEASED', 'KYC_APPROVED'
);

-- =============================================================
-- TABLE 1: users
-- =============================================================

CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone         VARCHAR(20)  NOT NULL UNIQUE,
    role          user_role    NOT NULL,
    kyc_tier      SMALLINT     NOT NULL DEFAULT 1 CHECK (kyc_tier BETWEEN 1 AND 3),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    profile_data  JSONB,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- =============================================================
-- TABLE 2: wallets
-- =============================================================

CREATE TABLE wallets (
    id              UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID           NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance         NUMERIC(20, 4) NOT NULL DEFAULT 0.0000 CHECK (balance >= 0),
    locked_balance  NUMERIC(20, 4) NOT NULL DEFAULT 0.0000 CHECK (locked_balance >= 0),
    currency        VARCHAR(10)    NOT NULL DEFAULT 'PKR',
    is_frozen       BOOLEAN        NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ    NOT NULL DEFAULT NOW()
);

-- =============================================================
-- TABLE 3: kyc_documents
-- =============================================================

CREATE TABLE kyc_documents (
    id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    document_type  document_type NOT NULL,
    file_s3_key    TEXT          NOT NULL,
    status         kyc_status    NOT NULL DEFAULT 'PENDING',
    reviewed_by    UUID          REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at    TIMESTAMPTZ
);

-- =============================================================
-- TABLE 4: contracts
-- =============================================================

CREATE TABLE contracts (
    id                UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_number  VARCHAR(50)     NOT NULL UNIQUE,
    client_id         UUID            NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    freelancer_id     UUID            NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    title             VARCHAR(255)    NOT NULL,
    scope             TEXT            NOT NULL,
    total_amount      NUMERIC(20, 4)  NOT NULL CHECK (total_amount > 0),
    platform_fee      NUMERIC(20, 4)  NOT NULL DEFAULT 0.0000 CHECK (platform_fee >= 0),
    currency          VARCHAR(10)     NOT NULL DEFAULT 'PKR',
    status            contract_status NOT NULL DEFAULT 'DRAFT',
    terms             JSONB,
    max_revisions     SMALLINT        NOT NULL DEFAULT 3 CHECK (max_revisions >= 0),
    revision_count    SMALLINT        NOT NULL DEFAULT 0 CHECK (revision_count >= 0),
    delivery_deadline TIMESTAMPTZ,
    funded_at         TIMESTAMPTZ,
    completed_at      TIMESTAMPTZ,
    cancelled_at      TIMESTAMPTZ,
    created_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at        TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_different_parties CHECK (client_id <> freelancer_id)
);

-- =============================================================
-- TABLE 5: payments
-- =============================================================

CREATE TABLE payments (
    id           UUID               PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id  UUID               NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
    user_id      UUID               NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    amount       NUMERIC(20, 4)     NOT NULL CHECK (amount > 0),
    gateway      payment_gateway    NOT NULL,
    gateway_ref  VARCHAR(255),
    status       payment_status     NOT NULL DEFAULT 'PENDING',
    direction    payment_direction  NOT NULL,
    created_at   TIMESTAMPTZ        NOT NULL DEFAULT NOW()
);

-- =============================================================
-- TABLE 6: milestones
-- =============================================================

CREATE TABLE milestones (
    id           UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id  UUID             NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    title        VARCHAR(255)     NOT NULL,
    description  TEXT,
    amount       NUMERIC(20, 4)   NOT NULL CHECK (amount > 0),
    sequence     SMALLINT         NOT NULL CHECK (sequence >= 1),
    status       milestone_status NOT NULL DEFAULT 'PENDING',
    due_date     TIMESTAMPTZ,
    funded_at    TIMESTAMPTZ,
    released_at  TIMESTAMPTZ,
    UNIQUE (contract_id, sequence)
);

-- =============================================================
-- TABLE 7: disputes
-- =============================================================

CREATE TABLE disputes (
    id               UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id      UUID             NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
    raised_by        UUID             NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    reason           dispute_reason   NOT NULL,
    status           dispute_status   NOT NULL DEFAULT 'RAISED',
    assigned_to      UUID             REFERENCES users(id) ON DELETE SET NULL,
    resolution_type  resolution_type,
    resolution_note  TEXT,
    resolved_at      TIMESTAMPTZ,
    created_at       TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

-- =============================================================
-- TABLE 8: audit_logs
-- =============================================================

CREATE TABLE audit_logs (
    id               UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id         UUID         REFERENCES users(id) ON DELETE SET NULL,
    action           VARCHAR(100) NOT NULL,
    entity_type      VARCHAR(50)  NOT NULL,
    entity_id        UUID         NOT NULL,
    before_snapshot  JSONB,
    after_snapshot   JSONB,
    ip_address       INET,
    user_agent       TEXT,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    chain_hash       TEXT         NOT NULL
);

-- =============================================================
-- TABLE 9: notifications
-- =============================================================

CREATE TABLE notifications (
    id          UUID                 PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID                 NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type  notification_event   NOT NULL,
    channel     notification_channel NOT NULL,
    payload     JSONB                NOT NULL,
    status      notification_status  NOT NULL DEFAULT 'PENDING',
    sent_at     TIMESTAMPTZ
);
