import SwiftUI

struct JobCardView: View {
    @ObservedObject var jobManager: JobManager
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(jobManager.filteredJobs) { job in
                    JobCard(job: job) {
                        // Handle job selection/editing
                    }
                }
            }
            .padding()
        }
    }
}

struct JobCard: View {
    let job: Job
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text(job.client)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // Priority Badge
                    HStack(spacing: 4) {
                        Image(systemName: job.priority.systemImage)
                            .font(.caption)
                        Text(job.priority.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(job.priority.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(job.priority.color.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Status Badge
                    HStack(spacing: 4) {
                        Image(systemName: job.status.systemImage)
                            .font(.caption)
                        Text(job.status.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(job.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(job.status.color.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Description
            if !job.description.isEmpty {
                Text(job.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Location
            if !job.location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(job.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            // Dates
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Start: \(job.startDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let endDate = job.endDate {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("End: \(endDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Statistics
            HStack(spacing: 16) {
                // Photos count
                if !job.photos.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.purple)
                            .font(.caption)
                        Text("\(job.photos.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Notes count
                if !job.notes.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("\(job.notes.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Last updated
                Text("Updated \(job.updatedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Photo previews
            if !job.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(job.photos.prefix(3)) { photo in
                            if let uiImage = UIImage(data: photo.imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                        
                        if job.photos.count > 3 {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("+\(job.photos.count - 3)")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

struct JobTableView: View {
    @ObservedObject var jobManager: JobManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                // Header
                JobTableHeader()
                
                // Rows
                ForEach(jobManager.filteredJobs) { job in
                    JobTableRow(job: job) {
                        // Handle job selection/editing
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding()
        }
    }
}

struct JobTableHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            // Title
            Text("Job Title")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Client
            Text("Client")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            // Status
            Text("Status")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .center)
            
            // Priority
            Text("Priority")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .center)
            
            // Date
            Text("Start Date")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .center)
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

struct JobTableRow: View {
    let job: Job
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Title and Description
            VStack(alignment: .leading, spacing: 2) {
                Text(job.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if !job.description.isEmpty {
                    Text(job.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Client
            Text(job.client)
                .font(.body)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
            
            // Status
            HStack(spacing: 4) {
                Image(systemName: job.status.systemImage)
                    .font(.caption)
                Text(job.status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(job.status.color)
            .frame(width: 80, alignment: .center)
            
            // Priority
            HStack(spacing: 4) {
                Image(systemName: job.priority.systemImage)
                    .font(.caption)
                Text(job.priority.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(job.priority.color)
            .frame(width: 80, alignment: .center)
            
            // Start Date
            Text(job.startDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .center)
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1),
            alignment: .bottom
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct JobTimelineView: View {
    @ObservedObject var jobManager: JobManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(jobManager.filteredJobs) { job in
                    JobTimelineItem(job: job) {
                        // Handle job selection/editing
                    }
                }
            }
            .padding()
        }
    }
}

struct JobTimelineItem: View {
    let job: Job
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(job.status.color)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            .frame(minHeight: 100)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(job.client)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: job.status.systemImage)
                                .font(.caption)
                            Text(job.status.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(job.status.color)
                        
                        Text(job.startDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !job.description.isEmpty {
                    Text(job.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                // Recent activity
                if let latestNote = job.notes.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: latestNote.type.systemImage)
                            .foregroundColor(latestNote.type.color)
                            .font(.caption)
                        Text(latestNote.content)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}