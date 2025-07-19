import SwiftUI

struct JobTimelineView: View {
    @ObservedObject var jobManager: JobManager
    @State private var selectedJob: Job?
    @State private var showingJobDetails = false
    @State private var timelineFilter: TimelineFilter = .all
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 0) {
            // Timeline Controls
            TimelineControls(
                filter: $timelineFilter,
                selectedDate: $selectedDate
            )
            
            // Timeline Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(groupedJobs.keys.sorted(by: >), id: \.self) { date in
                        TimelineDateSection(
                            date: date,
                            jobs: groupedJobs[date] ?? [],
                            onJobTap: { job in
                                selectedJob = job
                                showingJobDetails = true
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingJobDetails) {
            if let job = selectedJob {
                JobFormView(jobManager: jobManager, job: job)
            }
        }
    }
    
    private var filteredJobs: [Job] {
        let calendar = Calendar.current
        let jobs = jobManager.filteredJobs
        
        switch timelineFilter {
        case .all:
            return jobs
        case .thisWeek:
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? selectedDate
            let weekEnd = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.end ?? selectedDate
            return jobs.filter { job in
                job.startDate >= weekStart && job.startDate <= weekEnd
            }
        case .thisMonth:
            let monthStart = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
            let monthEnd = calendar.dateInterval(of: .month, for: selectedDate)?.end ?? selectedDate
            return jobs.filter { job in
                job.startDate >= monthStart && job.startDate <= monthEnd
            }
        case .upcoming:
            return jobs.filter { job in
                job.startDate > Date() && job.status != .completed && job.status != .cancelled
            }
        case .overdue:
            return jobs.filter { job in
                if let endDate = job.endDate {
                    return endDate < Date() && job.status != .completed && job.status != .cancelled
                }
                return false
            }
        }
    }
    
    private var groupedJobs: [Date: [Job]] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredJobs) { job in
            calendar.startOfDay(for: job.startDate)
        }
        return grouped
    }
}

struct TimelineControls: View {
    @Binding var filter: TimelineFilter
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 12) {
            // Filter Picker
            Picker("Timeline Filter", selection: $filter) {
                ForEach(TimelineFilter.allCases, id: \.self) { filter in
                    HStack {
                        Image(systemName: filter.systemImage)
                        Text(filter.rawValue)
                    }
                    .tag(filter)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Date Picker (for week/month filters)
            if filter == .thisWeek || filter == .thisMonth {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

struct TimelineDateSection: View {
    let date: Date
    let jobs: [Job]
    let onJobTap: (Job) -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dateFormatter.string(from: date))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(relativeDateFormatter.localizedString(for: date, relativeTo: Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Job count badge
                Text("\(jobs.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
            
            // Timeline Line and Jobs
            HStack(alignment: .top, spacing: 12) {
                // Timeline Line
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 12)
                    
                    Rectangle()
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: 2)
                        .frame(minHeight: CGFloat(jobs.count * 80))
                }
                
                // Jobs for this date
                VStack(spacing: 8) {
                    ForEach(jobs.sorted(by: { $0.startDate < $1.startDate })) { job in
                        TimelineJobCard(job: job, onTap: { onJobTap(job) })
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct TimelineJobCard: View {
    let job: Job
    let onTap: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Job Status Indicator
                VStack(spacing: 4) {
                    Circle()
                        .fill(job.status.color)
                        .frame(width: 8, height: 8)
                    
                    Text(timeFormatter.string(from: job.startDate))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 50)
                
                // Job Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !job.client.isEmpty {
                        Text(job.client)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    if !job.location.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(job.location)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                // Priority and Status
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: job.priority.systemImage)
                            .font(.caption)
                            .foregroundColor(job.priority.color)
                        
                        Text(job.priority.rawValue)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: job.status.systemImage)
                            .font(.caption)
                            .foregroundColor(job.status.color)
                        
                        Text(job.status.rawValue)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(job.priority.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum TimelineFilter: String, CaseIterable {
    case all = "All"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case upcoming = "Upcoming"
    case overdue = "Overdue"
    
    var systemImage: String {
        switch self {
        case .all:
            return "list.bullet"
        case .thisWeek:
            return "calendar.badge.clock"
        case .thisMonth:
            return "calendar"
        case .upcoming:
            return "arrow.up.circle"
        case .overdue:
            return "exclamationmark.triangle"
        }
    }
}

#Preview {
    JobTimelineView(jobManager: JobManager())
}