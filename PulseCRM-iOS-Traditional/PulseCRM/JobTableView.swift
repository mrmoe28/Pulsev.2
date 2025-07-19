import SwiftUI

struct JobTableView: View {
    @ObservedObject var jobManager: JobManager
    @State private var selectedJob: Job?
    @State private var showingJobDetails = false
    @State private var sortBy: JobSortOption = .updatedDate
    @State private var sortAscending = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Table Header
            JobTableHeader(sortBy: $sortBy, sortAscending: $sortAscending)
            
            // Table Content
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(sortedJobs) { job in
                        JobTableRow(job: job) {
                            selectedJob = job
                            showingJobDetails = true
                        }
                    }
                }
            }
            .background(Color(.systemGray6))
        }
        .sheet(isPresented: $showingJobDetails) {
            if let job = selectedJob {
                JobFormView(jobManager: jobManager, job: job)
            }
        }
    }
    
    private var sortedJobs: [Job] {
        let jobs = jobManager.filteredJobs
        return jobs.sorted { job1, job2 in
            let comparison: Bool
            switch sortBy {
            case .title:
                comparison = job1.title.localizedCompare(job2.title) == .orderedAscending
            case .client:
                comparison = job1.client.localizedCompare(job2.client) == .orderedAscending
            case .status:
                comparison = job1.status.rawValue.localizedCompare(job2.status.rawValue) == .orderedAscending
            case .priority:
                comparison = job1.priority.rawValue.localizedCompare(job2.priority.rawValue) == .orderedAscending
            case .startDate:
                comparison = job1.startDate < job2.startDate
            case .updatedDate:
                comparison = job1.updatedAt < job2.updatedAt
            }
            return sortAscending ? comparison : !comparison
        }
    }
}

struct JobTableHeader: View {
    @Binding var sortBy: JobSortOption
    @Binding var sortAscending: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            TableHeaderButton(
                title: "Title",
                sortOption: .title,
                currentSort: $sortBy,
                ascending: $sortAscending,
                width: 120
            )
            
            TableHeaderButton(
                title: "Client",
                sortOption: .client,
                currentSort: $sortBy,
                ascending: $sortAscending,
                width: 100
            )
            
            TableHeaderButton(
                title: "Status",
                sortOption: .status,
                currentSort: $sortBy,
                ascending: $sortAscending,
                width: 90
            )
            
            TableHeaderButton(
                title: "Priority",
                sortOption: .priority,
                currentSort: $sortBy,
                ascending: $sortAscending,
                width: 80
            )
            
            TableHeaderButton(
                title: "Start Date",
                sortOption: .startDate,
                currentSort: $sortBy,
                ascending: $sortAscending,
                width: 100
            )
            
            TableHeaderButton(
                title: "Updated",
                sortOption: .updatedDate,
                currentSort: $sortBy,
                ascending: $sortAscending,
                width: 80
            )
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
        .border(Color(.systemGray4), width: 0.5)
    }
}

struct TableHeaderButton: View {
    let title: String
    let sortOption: JobSortOption
    @Binding var currentSort: JobSortOption
    @Binding var ascending: Bool
    let width: CGFloat
    
    var body: some View {
        Button(action: {
            if currentSort == sortOption {
                ascending.toggle()
            } else {
                currentSort = sortOption
                ascending = true
            }
        }) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if currentSort == sortOption {
                    Image(systemName: ascending ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .frame(width: width, alignment: .leading)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JobTableRow: View {
    let job: Job
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Title
                VStack(alignment: .leading, spacing: 2) {
                    Text(job.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !job.location.isEmpty {
                        Text(job.location)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(width: 120, alignment: .leading)
                
                // Client
                Text(job.client)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 100, alignment: .leading)
                
                // Status
                HStack(spacing: 4) {
                    Circle()
                        .fill(job.status.color)
                        .frame(width: 8, height: 8)
                    
                    Text(job.status.rawValue)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(width: 90, alignment: .leading)
                
                // Priority
                HStack(spacing: 4) {
                    Image(systemName: job.priority.systemImage)
                        .font(.caption)
                        .foregroundColor(job.priority.color)
                    
                    Text(job.priority.rawValue)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                .frame(width: 80, alignment: .leading)
                
                // Start Date
                Text(job.startDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                
                // Updated Date
                Text(job.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .leading)
                
                Spacer()
                
                // Actions
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum JobSortOption: String, CaseIterable {
    case title = "Title"
    case client = "Client"
    case status = "Status"
    case priority = "Priority"
    case startDate = "Start Date"
    case updatedDate = "Updated"
}

#Preview {
    JobTableView(jobManager: JobManager())
}