#!/bin/bash

# Fix all @pulsecrm/db import paths
cd /Users/edwardharrison/Desktop/Pulsev.2-main/apps/web

echo "Fixing @pulsecrm/db import paths..."

# Replace all occurrences of '@pulsecrm/db' with '@/lib/db' and '@/lib/db-schema'
find . -name "*.ts" -type f -exec sed -i '' 's|from "@pulsecrm/db"|from "@/lib/db"|g' {} \;
find . -name "*.ts" -type f -exec sed -i '' 's|import { db } from "@/lib/db"|import { db } from "@/lib/db"|g' {} \;

# For schema imports
find . -name "*.ts" -type f -exec sed -i '' 's|from "@/lib/db-schema"|from "@/lib/db-schema"|g' {} \;

echo "Import paths fixed!"
