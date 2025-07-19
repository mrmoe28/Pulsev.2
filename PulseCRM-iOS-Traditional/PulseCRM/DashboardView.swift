import SwiftUI

struct JobCalendarView: View {
    @ObservedObject var jobManager: JobManager
    @State private var selectedDate = Date()
    @State private var currentDate = Date()
    @State private var showingJobDetails = false
    @State private var selectedJob: Job?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar Header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Days of the week
            HStack(spacing: 0) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 1) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isCurrentMonth: calendar.isDate(date, equalTo: currentDate, toGranularity: .month),
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        jobs: jobsForDate(date)
                    )
                    .onTapGesture {
                        selectedDate = date
                        if let job = jobsForDate(date).first {
                            selectedJob = job
                            showingJobDetails = true
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .sheet(isPresented: $showingJobDetails) {
            if let job = selectedJob {
                JobFormView(jobManager: jobManager, job: job)
            }
        }
    }
    
    private var calendarDays: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [Date] = []
        var currentDay = startOfWeek
        
        // Generate 42 days (6 weeks)
        for _ in 0..<42 {
            days.append(currentDay)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay) ?? currentDay
        }
        
        return days
    }
    
    private func jobsForDate(_ date: Date) -> [Job] {
        guard !jobManager.jobs.isEmpty else { return [] }
        return jobManager.jobs.filter { job in
            calendar.isDate(job.startDate, inSameDayAs: date) ||
            (job.endDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false) ||
            (job.endDate.map { date >= job.startDate && date <= $0 } ?? false)
        }
    }
    
    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }
    
    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }
}

struct CalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isToday: Bool
    let jobs: [Job]
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayFormatter.string(from: date))
                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                .foregroundColor(dayTextColor)
            
            // Job indicators
            HStack(spacing: 2) {
                ForEach(Array(jobs.prefix(3)), id: \.id) { job in
                    Circle()
                        .fill(job.priority.color)
                        .frame(width: 4, height: 4)
                }
                
                if jobs.count > 3 {
                    Text("+\(jobs.count - 3)")
                        .font(.system(size: 8))
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 8)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isSelected ? 2 : 0)
                )
        )
    }
    
    private var dayTextColor: Color {
        if isToday {
            return .white
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var backgroundColor: Color {
        if isToday {
            return .orange
        } else if isSelected {
            return .orange.opacity(0.2)
        } else if !jobs.isEmpty {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        return isSelected ? .orange : .clear
    }
}

struct DashboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if navigationManager.navigationStyle == .fullPage {
                FullPageNavigationView()
            } else {
                TabView(selection: $selectedTab) {
                    DashboardHomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Dashboard")
                        }
                        .tag(0)
                    
                    ContactView()
                        .tabItem {
                            Image(systemName: "person.3.fill")
                            Text("Contact")
                        }
                        .tag(1)
                    
                    JobsView()
                        .tabItem {
                            Image(systemName: "hammer.fill")
                            Text("Jobs")
                        }
                        .tag(2)
                    
                    DocumentsView()
                        .tabItem {
                            Image(systemName: "doc.fill")
                            Text("Documents")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                        .tag(4)
                }
                .accentColor(.orange)
            }
        }
    }
}

struct DashboardHomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        Group {
            if navigationManager.navigationStyle == .fullPage {
                dashboardContent
            } else {
                NavigationView {
                    dashboardContent
                        .navigationBarHidden(true)
                }
            }
        }
    }
    
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back,")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text(authManager.currentUser?.name ?? "User")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 15) {
                            QuickThemeToggle()
                            
                            Button(action: {
                                authManager.logout()
                            }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Quick Stats
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    StatCard(title: "Active Crew", value: "24", icon: "person.3.fill", color: .blue) {
                        navigationManager.setCurrentPage(.contacts)
                    }
                    StatCard(title: "Open Jobs", value: "8", icon: "hammer.fill", color: .green) {
                        navigationManager.setCurrentPage(.jobs)
                    }
                    StatCard(title: "Documents", value: "156", icon: "doc.fill", color: .purple) {
                        navigationManager.setCurrentPage(.documents)
                    }
                    StatCard(title: "Tasks", value: "12", icon: "checkmark.circle.fill", color: .orange) {
                        navigationManager.setCurrentPage(.jobs)
                    }
                }
                .padding(.horizontal)
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Recent Activity")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button("View All") {
                            // Action
                        }
                        .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 10) {
                        ActivityRow(title: "New crew member added", subtitle: "John Smith joined Project Alpha", time: "2 hours ago", icon: "person.badge.plus", color: .green)
                        ActivityRow(title: "Document uploaded", subtitle: "Safety checklist updated", time: "4 hours ago", icon: "doc.badge.plus", color: .blue)
                        ActivityRow(title: "Job completed", subtitle: "Electrical work finished", time: "6 hours ago", icon: "checkmark.circle", color: .orange)
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(value)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ContactView: View {
    @StateObject private var contactManager = ContactManager()
    @State private var showingAddContact = false
    @State private var showingSearch = false
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        Group {
            if navigationManager.navigationStyle == .fullPage {
                ContactContentView(
                    contactManager: contactManager,
                    showingAddContact: $showingAddContact,
                    showingSearch: $showingSearch
                )
            } else {
                NavigationView {
                    ContactContentView(
                        contactManager: contactManager,
                        showingAddContact: $showingAddContact,
                        showingSearch: $showingSearch
                    )
                    .navigationTitle("Contacts")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showingSearch.toggle() }) {
                                Image(systemName: "magnifyingglass")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 10) {
                                QuickThemeToggle()
                                
                                Button(action: { showingAddContact = true }) {
                                    Image(systemName: "plus")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddContact) {
            ContactFormView(contactManager: contactManager)
        }
    }
}

struct ContactContentView: View {
    @ObservedObject var contactManager: ContactManager
    @Binding var showingAddContact: Bool
    @Binding var showingSearch: Bool
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Page Header for Full Page Mode
            if navigationManager.navigationStyle == .fullPage {
                HStack {
                    Text("Contacts")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: { showingSearch.toggle() }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        
                        QuickThemeToggle()
                        
                        Button(action: { showingAddContact = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            } else {
                // App Logo Header for Tab Mode
                HeaderLogoView()
            }
            
            // Search Bar
            if showingSearch {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search contacts...", text: $contactManager.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Cancel") {
                        contactManager.searchText = ""
                        showingSearch = false
                    }
                    .foregroundColor(.orange)
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            // Enhanced View Toggle with All Views
            VStack(spacing: 12) {
                HStack {
                    Picker("View Type", selection: $contactManager.currentViewType) {
                        ForEach(ContactViewType.allCases, id: \.self) { viewType in
                            HStack {
                                Image(systemName: viewType.systemImage)
                                Text(viewType.rawValue)
                            }
                            .tag(viewType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                    
                    // Contact count
                    Text("\(contactManager.filteredContacts.count) contacts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Additional Navigation Options
                HStack(spacing: 15) {
                    // Sort options
                    Menu {
                        Button("Sort by Name") {
                            contactManager.sortField = "name"
                        }
                        Button("Sort by Company") {
                            contactManager.sortField = "company"
                        }
                        Button("Sort by Date Added") {
                            contactManager.sortField = "dateAdded"
                        }
                        Button("Sort by Recent Contact") {
                            contactManager.sortField = "lastContact"
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.caption)
                            Text("Sort")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Filter options
                    Menu {
                        Button("All Contacts") {
                            contactManager.filterType = .all
                        }
                        Button("Favorites") {
                            contactManager.filterType = .favorites
                        }
                        Button("Recent") {
                            contactManager.filterType = .recent
                        }
                        Button("By Company") {
                            contactManager.filterType = .company
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.caption)
                            Text("Filter")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Group options
                    Menu {
                        Button("Group by Company") {
                            contactManager.groupBy = .company
                        }
                        Button("Group by Position") {
                            contactManager.groupBy = .position
                        }
                        Button("Group by Location") {
                            contactManager.groupBy = .location
                        }
                        Button("No Grouping") {
                            contactManager.groupBy = .none
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.grid.3x3")
                                .font(.caption)
                            Text("Group")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Export options
                    Menu {
                        Button("Export to CSV") {
                            contactManager.exportToCSV()
                        }
                        Button("Export to vCard") {
                            contactManager.exportToVCard()
                        }
                        Button("Share Selected") {
                            contactManager.shareSelected()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption)
                            Text("Export")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Import button
                    Button(action: {
                        contactManager.showingImport = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.caption)
                            Text("Import")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            // Content Views
            Group {
                switch contactManager.currentViewType {
                case .table:
                    ContactTableView(contactManager: contactManager)
                case .cards:
                    ContactCardView(contactManager: contactManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct JobsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var jobManager = JobManager()
    @State private var showingAddJob = false
    @State private var showingSearch = false
    @State private var selectedJob: Job?
    @State private var showingJobDetail = false
    
    var body: some View {
        Group {
            if navigationManager.navigationStyle == .fullPage {
                JobsContentView(
                    jobManager: jobManager,
                    showingAddJob: $showingAddJob,
                    showingSearch: $showingSearch,
                    selectedJob: $selectedJob,
                    showingJobDetail: $showingJobDetail
                )
            } else {
                NavigationView {
                    JobsContentView(
                        jobManager: jobManager,
                        showingAddJob: $showingAddJob,
                        showingSearch: $showingSearch,
                        selectedJob: $selectedJob,
                        showingJobDetail: $showingJobDetail
                    )
                    .navigationTitle("Jobs")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showingSearch.toggle() }) {
                                Image(systemName: "magnifyingglass")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 10) {
                                QuickThemeToggle()
                                
                                Button(action: { showingAddJob = true }) {
                                    Image(systemName: "plus")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddJob) {
            JobFormView(jobManager: jobManager)
        }
        .sheet(item: $selectedJob) { job in
            JobFormView(jobManager: jobManager, job: job)
        }
    }
}

struct JobsContentView: View {
    @ObservedObject var jobManager: JobManager
    @Binding var showingAddJob: Bool
    @Binding var showingSearch: Bool
    @Binding var selectedJob: Job?
    @Binding var showingJobDetail: Bool
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Page Header for Full Page Mode
            if navigationManager.navigationStyle == .fullPage {
                HStack {
                    Text("Jobs")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: { showingSearch.toggle() }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        
                        QuickThemeToggle()
                        
                        Button(action: { showingAddJob = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            
            // Search Bar
            if showingSearch {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search jobs...", text: $jobManager.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Cancel") {
                            jobManager.searchText = ""
                            showingSearch = false
                        }
                        .foregroundColor(.orange)
                    }
                    
                    // Filters
                    HStack {
                        // Status Filter
                        Menu {
                            Button("All Statuses") {
                                jobManager.filterStatus = nil
                            }
                            ForEach(JobStatus.allCases, id: \.self) { status in
                                Button(action: {
                                    jobManager.filterStatus = status
                                }) {
                                    HStack {
                                        Image(systemName: status.systemImage)
                                        Text(status.rawValue)
                                        if jobManager.filterStatus == status {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text(jobManager.filterStatus?.rawValue ?? "Status")
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Priority Filter
                        Menu {
                            Button("All Priorities") {
                                jobManager.filterPriority = nil
                            }
                            ForEach(JobPriority.allCases, id: \.self) { priority in
                                Button(action: {
                                    jobManager.filterPriority = priority
                                }) {
                                    HStack {
                                        Image(systemName: priority.systemImage)
                                        Text(priority.rawValue)
                                        if jobManager.filterPriority == priority {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text(jobManager.filterPriority?.rawValue ?? "Priority")
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            // Enhanced View Toggle and Job Statistics Cards
            VStack(spacing: 12) {
                HStack {
                    Picker("View Type", selection: $jobManager.currentViewType) {
                        ForEach(JobViewType.allCases, id: \.self) { viewType in
                            HStack {
                                Image(systemName: viewType.systemImage)
                                Text(viewType.rawValue)
                            }
                            .tag(viewType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                    
                    // Job count and stats
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(jobManager.filteredJobs.count) jobs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        let activeJobs = jobManager.filteredJobs.filter { $0.status == .inProgress }.count
                        if activeJobs > 0 {
                            Text("\(activeJobs) active")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Job Statistics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    // Total Jobs Card
                    JobStatCard(
                        title: "Total Jobs",
                        value: "\(jobManager.jobs.count)",
                        icon: "folder.fill",
                        color: .blue,
                        subtext: "All projects"
                    )
                    
                    // Active Jobs Card
                    JobStatCard(
                        title: "Active",
                        value: "\(jobManager.jobs.filter { $0.status == .inProgress }.count)",
                        icon: "hammer.fill",
                        color: Color.green,
                        subtext: "In progress"
                    )
                    
                    // Pending Jobs Card
                    JobStatCard(
                        title: "Pending",
                        value: "\(jobManager.jobs.filter { $0.status == .pending }.count)",
                        icon: "clock.fill",
                        color: Color.orange,
                        subtext: "Not started"
                    )
                    
                    // Completed Jobs Card
                    JobStatCard(
                        title: "Completed",
                        value: "\(jobManager.jobs.filter { $0.status == .completed }.count)",
                        icon: "checkmark.circle.fill",
                        color: .purple,
                        subtext: "Finished"
                    )
                }
                
                // Quick Actions Row
                HStack(spacing: 12) {
                    // Today's Jobs
                    Button(action: {
                        jobManager.filterByDate = .today
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption)
                            Text("Today's Jobs")
                                .font(.caption)
                            Text("(\(jobManager.todaysJobs.count))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // This Week
                    Button(action: {
                        jobManager.filterByDate = .thisWeek
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption)
                            Text("This Week")
                                .font(.caption)
                            Text("(\(jobManager.thisWeeksJobs.count))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Overdue
                    Button(action: {
                        jobManager.filterByDate = .overdue
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("Overdue")
                                .font(.caption)
                            Text("(\(jobManager.overdueJobs.count))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Calendar view quick access
                    Button(action: {
                        jobManager.currentViewType = .calendar
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("Calendar")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            // Content Views
            Group {
                if jobManager.filteredJobs.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("No Jobs Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Create your first job to get started")
                            .foregroundColor(.secondary)
                        
                        Button("Create Job") {
                            showingAddJob = true
                        }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch jobManager.currentViewType {
                    case .cards:
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 16) {
                                ForEach(jobManager.filteredJobs) { job in
                                    JobCard(job: job) {
                                        selectedJob = job
                                    }
                                }
                            }
                            .padding()
                        }
                    case .table:
                        JobTableView(jobManager: jobManager)
                    case .timeline:
                        JobTimelineView(jobManager: jobManager)
                    case .calendar:
                        JobCalendarView(jobManager: jobManager)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct DocumentsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var documentManager = DocumentManager()
    @State private var showingAddDocument = false
    @State private var showingSearch = false
    @State private var selectedDocument: Document?
    @State private var showingDocumentDetail = false
    
    var body: some View {
        Group {
            if navigationManager.navigationStyle == .fullPage {
                DocumentsContentView(
                    documentManager: documentManager,
                    showingAddDocument: $showingAddDocument,
                    showingSearch: $showingSearch,
                    selectedDocument: $selectedDocument,
                    showingDocumentDetail: $showingDocumentDetail
                )
            } else {
                NavigationView {
                    DocumentsContentView(
                        documentManager: documentManager,
                        showingAddDocument: $showingAddDocument,
                        showingSearch: $showingSearch,
                        selectedDocument: $selectedDocument,
                        showingDocumentDetail: $showingDocumentDetail
                    )
                    .navigationTitle("Documents")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showingSearch.toggle() }) {
                                Image(systemName: "magnifyingglass")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            HStack(spacing: 10) {
                                QuickThemeToggle()
                                
                                Button(action: { showingAddDocument = true }) {
                                    Image(systemName: "plus")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddDocument) {
            DocumentFormView(documentManager: documentManager)
        }
        .sheet(item: $selectedDocument) { document in
            DocumentFormView(documentManager: documentManager, document: document)
        }
    }
}

struct DocumentsContentView: View {
    @ObservedObject var documentManager: DocumentManager
    @Binding var showingAddDocument: Bool
    @Binding var showingSearch: Bool
    @Binding var selectedDocument: Document?
    @Binding var showingDocumentDetail: Bool
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Page Header for Full Page Mode
            if navigationManager.navigationStyle == .fullPage {
                HStack {
                    Text("Documents")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Button(action: { showingSearch.toggle() }) {
                            Image(systemName: "magnifyingglass")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        
                        QuickThemeToggle()
                        
                        Button(action: { showingAddDocument = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            
            // Search Bar
            if showingSearch {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search documents...", text: $documentManager.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Cancel") {
                            documentManager.searchText = ""
                            showingSearch = false
                        }
                        .foregroundColor(.orange)
                    }
                    
                    // Filters
                    HStack {
                        // Category Filter
                        Menu {
                            Button("All Categories") {
                                documentManager.filterCategory = nil
                            }
                            ForEach(DocumentCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    documentManager.filterCategory = category
                                }) {
                                    HStack {
                                        Image(systemName: category.systemImage)
                                        Text(category.rawValue)
                                        if documentManager.filterCategory == category {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "folder.circle")
                                Text(documentManager.filterCategory?.rawValue ?? "Category")
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Access Level Filter
                        Menu {
                            Button("All Access Levels") {
                                documentManager.filterAccessLevel = nil
                            }
                            ForEach(AccessLevel.allCases, id: \.self) { level in
                                Button(action: {
                                    documentManager.filterAccessLevel = level
                                }) {
                                    HStack {
                                        Image(systemName: level.systemImage)
                                        Text(level.rawValue)
                                        if documentManager.filterAccessLevel == level {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "lock.circle")
                                Text(documentManager.filterAccessLevel?.rawValue ?? "Access")
                            }
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
            
            // Enhanced View Toggle and Document Statistics
            VStack(spacing: 12) {
                HStack {
                    Picker("View Type", selection: $documentManager.currentViewType) {
                        ForEach(DocumentViewType.allCases, id: \.self) { viewType in
                            HStack {
                                Image(systemName: viewType.systemImage)
                                Text(viewType.rawValue)
                            }
                            .tag(viewType)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                    
                    // Document count and stats
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(documentManager.filteredDocuments.count) documents")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        let totalSize = documentManager.getTotalFileSize()
                        if totalSize > 0 {
                            Text(ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file))
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Document Statistics Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    // Total Documents
                    DocumentStatCard(
                        title: "Total Docs",
                        value: "\(documentManager.documents.count)",
                        icon: "doc.fill",
                        color: Color.blue,
                        subtext: "All files"
                    )
                    
                    // Images Count
                    DocumentStatCard(
                        title: "Images",
                        value: "\(documentManager.documents.filter { $0.isImage() }.count)",
                        icon: "photo.fill",
                        color: Color.green,
                        subtext: "Photos & images"
                    )
                    
                    // PDFs Count
                    DocumentStatCard(
                        title: "PDFs",
                        value: "\(documentManager.pdfCount)",
                        icon: "doc.text.fill",
                        color: Color.red,
                        subtext: "PDF documents"
                    )
                    
                    // Recent Count
                    DocumentStatCard(
                        title: "Recent",
                        value: "\(documentManager.recentDocuments.count)",
                        icon: "clock.fill",
                        color: Color.orange,
                        subtext: "Last 7 days"
                    )
                    
                    // Storage Analytics
                    DocumentStatCard(
                        title: "Storage",
                        value: ByteCountFormatter.string(fromByteCount: documentManager.totalStorageUsed, countStyle: .file),
                        icon: "externaldrive.fill",
                        color: Color.indigo,
                        subtext: "Total used"
                    )
                    
                    // Office Documents
                    DocumentStatCard(
                        title: "Office",
                        value: "\(documentManager.wordDocCount + documentManager.excelCount + documentManager.powerPointCount)",
                        icon: "folder.fill",
                        color: Color.teal,
                        subtext: "Word, Excel, PPT"
                    )
                    
                    // Large Files
                    DocumentStatCard(
                        title: "Large Files",
                        value: "\(documentManager.largeDocuments.count)",
                        icon: "externaldrive.badge.exclamationmark",
                        color: Color.red,
                        subtext: "Over 10MB"
                    )
                    
                    // Average Size
                    DocumentStatCard(
                        title: "Avg Size",
                        value: ByteCountFormatter.string(fromByteCount: documentManager.averageFileSize, countStyle: .file),
                        icon: "chart.bar.fill",
                        color: Color.mint,
                        subtext: "Per document"
                    )
                }
                
                // Quick Actions Row
                HStack(spacing: 12) {
                    // Quick filters
                    Button(action: {
                        documentManager.quickFilter = .images
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "photo.stack")
                                .font(.caption)
                            Text("Images")
                                .font(.caption)
                            Text("(\(documentManager.documents.filter { $0.isImage() }.count))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        documentManager.quickFilter = .pdfs
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text")
                                .font(.caption)
                            Text("PDFs")
                                .font(.caption)
                            Text("(\(documentManager.pdfCount))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        documentManager.quickFilter = .recent
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.caption)
                            Text("Recent")
                                .font(.caption)
                            Text("(\(documentManager.recentDocuments.count))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Word Documents
                    Button(action: {
                        documentManager.filterCategory = nil
                        // Add Word filter logic
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.text.fill")
                                .font(.caption)
                            Text("Word")
                                .font(.caption)
                            Text("(\(documentManager.wordDocCount))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Excel Documents
                    Button(action: {
                        documentManager.filterCategory = nil
                        // Add Excel filter logic
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "tablecells")
                                .font(.caption)
                            Text("Excel")
                                .font(.caption)
                            Text("(\(documentManager.excelCount))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Bulk actions
                    Button(action: {
                        documentManager.showingBulkActions = true
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up.on.square")
                                .font(.caption)
                            Text("Bulk Actions")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            
            // Content Views
            Group {
                if documentManager.filteredDocuments.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("No Documents Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Upload your first document to get started")
                            .foregroundColor(.secondary)
                        
                        Button("Upload Document") {
                            showingAddDocument = true
                        }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch documentManager.currentViewType {
                    case .cards:
                        DocumentCardView(documentManager: documentManager, selectedDocument: $selectedDocument)
                    case .list:
                        DocumentListView(documentManager: documentManager, selectedDocument: $selectedDocument)
                    case .grid:
                        DocumentGridView(documentManager: documentManager, selectedDocument: $selectedDocument)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        Group {
            if navigationManager.navigationStyle == .fullPage {
                SettingsContentView()
            } else {
                NavigationView {
                    SettingsContentView()
                        .navigationTitle("Settings")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                QuickThemeToggle()
                            }
                        }
                }
            }
        }
    }
}

struct SettingsContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            if navigationManager.navigationStyle == .fullPage {
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    QuickThemeToggle()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            
            List {
                Section("Account") {
                    NavigationLink(destination: ProfileSettingsView()) {
                        HStack {
                            // Profile Image or Placeholder
                            if let imageData = UserDefaults.standard.data(forKey: "pulse_user_profile_image"),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.orange, lineWidth: 2)
                                    )
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authManager.currentUser?.name ?? "User")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(authManager.currentUser?.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Organization and Position if available
                                if let organization = UserDefaults.standard.string(forKey: "pulse_user_organization"),
                                   let position = UserDefaults.standard.string(forKey: "pulse_user_position"),
                                   !organization.isEmpty || !position.isEmpty {
                                    Text("\(position)\(!position.isEmpty && !organization.isEmpty ? " at " : "")\(organization)")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            // Edit indicator
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section("Preferences") {
                    NavigationLink(destination: ProfileSettingsView()) {
                        SettingRow(icon: "person.crop.circle.fill", title: "Profile", color: .blue)
                    }
                    NavigationLink(destination: NotificationSettingsView()) {
                        SettingRow(icon: "bell.fill", title: "Notifications", color: .orange)
                    }
                    NavigationLink(destination: PrivacySettingsView()) {
                        SettingRow(icon: "lock.fill", title: "Privacy", color: .green)
                    }
                    ThemeToggleView()
                    NavigationStyleToggleView()
                }
                
                Section("Health & Wellness") {
                    NavigationLink(destination: HealthSupportView()) {
                        SettingRow(icon: "heart.circle.fill", title: "Health Support", color: .red)
                    }
                }
                
                Section("Support") {
                    SettingRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .orange)
                    NavigationLink(destination: AboutView()) {
                        SettingRow(icon: "info.circle.fill", title: "About", color: .gray)
                    }
                }
                
                Section {
                    Button(action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Full Page Navigation

struct FullPageNavigationView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            // Current Page Content
            currentPageView
            
            // Bottom Navigation Bar
            BottomNavigationBar()
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder
    private var currentPageView: some View {
        switch navigationManager.currentPage {
        case .dashboard:
            DashboardHomeView()
        case .contacts:
            ContactView()
        case .jobs:
            JobsView()
        case .documents:
            DocumentsView()
        case .settings:
            SettingsView()
        }
    }
}

struct BottomNavigationBar: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                ForEach(AppPage.allCases, id: \.self) { page in
                    NavigationButton(
                        page: page,
                        isSelected: navigationManager.currentPage == page
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            navigationManager.setCurrentPage(page)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
}

struct NavigationButton: View {
    let page: AppPage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: page.systemImage)
                    .font(.title2)
                    .foregroundColor(isSelected ? .orange : .secondary)
                
                Text(page.rawValue)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .orange : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JobStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtext: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(subtext)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct DocumentStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtext: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text(subtext)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}