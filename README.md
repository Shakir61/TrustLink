# TrustLink
This is my database lab project in which i am going to make a freelance platform named TrustLink.

Database Systems Lab Project Proposal:

1. Objective of the Proposal
The purpose of this proposal is to outline the development of a Secure Freelance Marketplace & Escrow Management System. This system addresses the lack of trust and financial security in independent digital contracting. By implementing a robust relational database, the system will ensure that project milestones are tracked, payments are held securely in escrow, and user reputations are verified through transaction-linked feedback.

2. Project Team Information:
   
•	Student Name: Shakir Ullah and Abdur Rehman
•	Program and Group: BS Computer Science - “A” (4th Semester)
•	Project Title:TrustLink: A Milestone-Based Freelance Escrow System

3. Introduction & Background:
4. 
In the modern "Gig Economy," the digital service market has grown exponentially, connecting skilled professionals with global clients. However, the decentralized nature of this work often leads to payment disputes, "ghosting," and quality concerns. This area is critical because trust is the primary currency of digital trade. A system that guarantees payment for work done and quality for payment made is essential for sustainable professional growth in the tech and creative sectors.

5. Problem Statement
In the real world, freelancers often complete work only to have clients refuse payment, while clients fear paying upfront for subpar results. Current manual or informal agreements are inefficient and legally difficult to enforce.
•	Affected Parties: Independent developers, designers, and small business owners.
•	Inefficiencies: Lack of centralized tracking, high risk of financial fraud, and unverified reviews.
•	Database Necessity: This problem requires a database to maintain ACID-compliant transactions, ensuring that money is never "lost" during a transfer and that user ratings are mathematically tied to actual completed orders.

6. Proposed Solution
TrustLink is a web-based marketplace that utilizes a "Locked-Funds" (Escrow) model. When an order is placed, the database holds the payment in a virtual vault. The system uses a state-machine logic to move funds only when specific milestones are met. This protects both parties: the freelancer is assured the money exists, and the client is assured they only pay for a finished product.

7. Objectives of the System
•	Secure Financial Ledger: Maintain a flawless record of all debits and credits.
•	Automated Milestone Tracking: Update project states automatically based on user inputs.
•	Data Integrity: Ensure that reviews can only be posted if a corresponding Completed_Order record exists.
•	Efficient Discovery: Provide fast search and filtering for specialized service categories.
•	Concurrency Management: Handle multiple users bidding or purchasing simultaneously without data collisions.

8. Scope of the Project
•	Included: User registration (Client/Freelancer), Gig creation, Order management, Escrow simulation, and Review systems.
•	Excluded: Real-world banking API integration (will be simulated with a virtual wallet), Real-time video calling, and Legal dispute arbitration.

9. Role of Database System
•	Data Stored: User credentials, service listings (Gigs), transactional logs, delivery timestamps, and encrypted message metadata.
•	Necessity: Relational integrity is required to link every dollar in escrow to a specific user and order ID.
•	Operations: CRUD for profiles and gigs; complex Reporting for monthly earnings and platform analytics.
•	Integrity: Use of Foreign Keys to prevent "orphaned" orders and Triggers to update user ratings.

10. System Features / Functional Requirements
1.	Role-Based Access Control: Secure login for Clients and Freelancers.
2.	Service Catalog: Searchable database of "Gigs" with pricing tiers.
3.	Order Workflow: A multi-stage pipeline (Pending -> Active -> Delivered -> Completed).
4.	Escrow Vault: A simulated wallet system that "locks" funds.
5.	Evidence/Delivery Portal: Storing URLs to delivered work files.
6.	Review Integrity System: Verified feedback linked to transaction IDs.
7.	Dashboard Analytics: Freelancers can view pending vs. cleared earnings.
8.	Internal Messaging: Record of communication for dispute resolution.

10. Preliminary Data Design
•	Users: (PK: UserID) – Handles profiles and roles.
•	Gigs: (PK: GigID, FK: SellerID) – Stores service descriptions.
•	Orders: (PK: OrderID, FK: BuyerID, FK: GigID) – Tracks the status of the deal.
•	Transactions: (PK: TransID, FK: OrderID) – Manages the flow of virtual currency.

11. Existing Systems / Comparative Analysis
While platforms like Fiverr and Upwork exist, they are often too complex for localized or niche markets. Existing "simple" job boards lack the Escrow component, leaving users vulnerable. TrustLink improves on this by focusing specifically on the database-level security of funds, making it a "Safety-First" marketplace.

12. Proposed Technology Stack
•	Frontend: React.js / HTML / CSS
•	Backend: Node.js (Express)
•	Database: MySQL 
•	Tools: MySQL Workbench (ERD Design), Postman (API Testing)

13. Expected Outcomes
The system will provide a secure, transparent environment for digital freelancing. It will demonstrate how a well-designed database can solve real-world trust issues, resulting in a functional prototype where a user can safely buy or sell a service with guaranteed financial protection.

