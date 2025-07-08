#!/bin/bash

# Fix all dashboard-layout import paths
cd /Users/edwardharrison/Desktop/Pulsev.2-main/apps/web

echo "Fixing dashboard-layout import paths..."

# Replace all occurrences of '../../../components/dashboard-layout' with '../../../components/layout/dashboard-layout'
find . -name "*.tsx" -type f -exec sed -i '' 's|../../../components/dashboard-layout|../../../components/layout/dashboard-layout|g' {} \;

# Replace any remaining wrong paths
find . -name "*.tsx" -type f -exec sed -i '' 's|../../components/dashboard-layout|../../components/layout/dashboard-layout|g' {} \;
find . -name "*.tsx" -type f -exec sed -i '' 's|../components/dashboard-layout|../components/layout/dashboard-layout|g' {} \;

echo "Import paths fixed!"
