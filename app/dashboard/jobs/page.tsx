'use client';

import dynamic from 'next/dynamic';
import { Suspense } from 'react';
import { DashboardLayout } from '@/components/core/layouts/DashboardLayout';

// Dynamically import the main jobs component to prevent build-time execution
const JobsContent = dynamic(
  () => import('./jobs-content'),
  { 
    ssr: false,
    loading: () => (
      <DashboardLayout title="Jobs" subtitle="Manage your solar installation projects">
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
        </div>
      </DashboardLayout>
    )
  }
);

export default function JobsPage() {
  return (
    <Suspense fallback={
      <DashboardLayout title="Jobs" subtitle="Manage your solar installation projects">
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
        </div>
      </DashboardLayout>
    }>
      <JobsContent />
    </Suspense>
  );
}
