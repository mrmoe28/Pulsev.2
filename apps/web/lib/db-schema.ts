import { pgTable, text, varchar, timestamp, integer, json, boolean, pgEnum, serial } from 'drizzle-orm/pg-core';

// Users and Organizations tables are already defined in schema.sql
// These are defined here for reference and type safety

export const organizations = pgTable('organizations', {
  id: varchar('id').primaryKey(),
  name: varchar('name').notNull(),
  slug: varchar('slug'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

export const users = pgTable('users', {
  id: varchar('id').primaryKey(),
  email: varchar('email').notNull().unique(),
  password: varchar('password').notNull(),
  firstName: varchar('first_name').notNull(),
  lastName: varchar('last_name').notNull(),
  organizationId: varchar('organization_id')
    .notNull()
    .references(() => organizations.id),
  organizationName: varchar('organization_name').notNull(),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Documents table for file management
export const documents = pgTable('documents', {
  id: varchar('id').primaryKey(),
  title: varchar('title').notNull(),
  description: text('description'),
  fileName: varchar('file_name').notNull(),
  fileSize: integer('file_size'),
  filePath: varchar('file_path').notNull(),
  mimeType: varchar('mime_type'),
  organizationId: varchar('organization_id')
    .notNull()
    .references(() => organizations.id),
  uploadedById: varchar('uploaded_by_id')
    .notNull()
    .references(() => users.id),
  status: varchar('status').default('active'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});

// Document signatures table for e-signature functionality
export const documentSignatures = pgTable('document_signatures', {
  id: varchar('id').primaryKey(),
  documentId: varchar('document_id')
    .notNull()
    .references(() => documents.id),
  signerName: varchar('signer_name').notNull(),
  signerEmail: varchar('signer_email').notNull(),
  signatureData: text('signature_data'),
  status: varchar('status').default('pending'), // pending, signed, declined
  signedAt: timestamp('signed_at'),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
});