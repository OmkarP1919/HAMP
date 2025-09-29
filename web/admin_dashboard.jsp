<%@ page import="java.sql.*, java.time.*, java.time.format.*, java.text.NumberFormat, java.util.Locale, java.util.ArrayList, java.util.HashMap, java.text.SimpleDateFormat, java.util.Date" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR ADMIN DASHBOARD
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }

    // --- 2. GATHER DYNAMIC DATA ---
    String adminName = (String) session.getAttribute("admin_name");
    LocalDate today = LocalDate.now();
    String formattedDate = today.format(DateTimeFormatter.ofPattern("MMMM d, yyyy"));

    int totalStudents = 0;
    int availableSlots = 0;
    double pendingFees = 0.0;
    int newApplications = 0;
    ArrayList<HashMap<String, String>> recentActivity = new ArrayList<>();
    
    // --- 3. DATABASE CONNECTION & QUERIES ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String url = "jdbc:mysql://localhost:3306/hamp";
        String dbUsername = "root";
        String dbPassword = "root";
        String driver = "com.mysql.jdbc.Driver";
        Class.forName(driver);
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        // --- STAT CARD QUERIES ---
        // Query 1: Get Total Students
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM fees WHERE payment_status = 'Paid'");
        rs = pstmt.executeQuery();
        if (rs.next()) { totalStudents = rs.getInt(1); }
        rs.close(); pstmt.close();
        
        // Query 2: Get Total Available Slots (MODIFIED LOGIC)
        // Calculates the sum of (total_slots - occupied_slots) for all rooms.
        pstmt = conn.prepareStatement("SELECT SUM(total_slots - occupied_slots) FROM room");
        rs = pstmt.executeQuery();
        if (rs.next()) { availableSlots = rs.getInt(1); }
        rs.close(); pstmt.close();

        // Query 3: Get Total Pending Fees
        pstmt = conn.prepareStatement("SELECT SUM(total_fees-paid_fees) FROM fees");
        rs = pstmt.executeQuery();
        if (rs.next()) { pendingFees = rs.getDouble(1); }
        rs.close(); pstmt.close();
        
        // Query 4: Get New Applications
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM applications WHERE status = 'Pending'");
        rs = pstmt.executeQuery();
        if (rs.next()) { newApplications = rs.getInt(1); }
        rs.close(); pstmt.close();

        // --- ACTIVITY FEED QUERY ---
        String activitySql = 
            "SELECT t1.activity_type, t1.roll_no, t1.activity_date, t1.details, sa.fullname " +
            "FROM (" +
            "    (SELECT 'Application' AS activity_type, stud_roll AS roll_no, applied_date AS activity_date, 'Submitted' AS details FROM applications) " +
            "    UNION ALL " +
            "    (SELECT 'Payment' AS activity_type, roll_no, payment_date AS activity_date, CAST(paid_fees AS CHAR) AS details FROM fees WHERE payment_status = 'Paid' AND payment_date IS NOT NULL) " +
            ") AS t1 " +
            "JOIN student_auth sa ON sa.roll_no = t1.roll_no " +
            "ORDER BY t1.activity_date DESC " +
            "LIMIT 4";

        pstmt = conn.prepareStatement(activitySql);
        rs = pstmt.executeQuery();
        
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM, yyyy");
        NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));

        while (rs.next()) {
            HashMap<String, String> activity = new HashMap<>();
            String type = rs.getString("activity_type");
            String fullname = rs.getString("fullname");
            Date activityDate = rs.getDate("activity_date");

            if ("Application".equals(type)) {
                activity.put("title", "New Application");
                activity.put("description", fullname + " has submitted an application.");
                activity.put("icon", "fa-file-signature");
                activity.put("icon_class", "icon-apps");
            } else if ("Payment".equals(type)) {
                double amountPaid = Double.parseDouble(rs.getString("details"));
                activity.put("title", "Fee Payment Received");
                activity.put("description", fullname + " paid " + currencyFormatter.format(amountPaid));
                activity.put("icon", "fa-file-invoice-dollar");
                activity.put("icon_class", "icon-fees");
            }
            
            activity.put("time", sdf.format(activityDate));
            recentActivity.add(activity);
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }

    String formattedFees = NumberFormat.getCurrencyInstance(new Locale("en", "IN")).format(pendingFees);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --success-color: #10b981; --warning-color: #f59e0b; --danger-color: #ef4444;
        }
        * { box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif; margin: 0; background-color: var(--secondary-color);
            color: var(--primary-color); height: 100vh; display: grid;
            grid-template-rows: auto 1fr; grid-template-columns: 260px 1fr;
            grid-template-areas: "header header" "sidebar main";
        }
        .top-panel {
            grid-area: header; background: linear-gradient(135deg, var(--accent-color), #4f87ff);
            color: #ffffff; padding: 1rem 2rem; display: flex;
            justify-content: space-between; align-items: center; z-index: 10;
        }
        .top-panel h1 { margin: 0; font-size: 1.8em; }
        .user-menu { display: flex; align-items: center; gap: 1.5rem; }
        .user-info { display: flex; align-items: center; gap: 0.75rem; font-weight: 500; }
        .user-info .fa-user-circle { font-size: 1.5rem; }
        .logout-btn {
            display: flex; align-items: center; gap: 0.5rem; background-color: rgba(255, 255, 255, 0.15);
            color: white; padding: 0.5rem 1rem; border-radius: 6px; text-decoration: none;
            font-weight: 500; transition: background-color 0.3s ease;
        }
        .logout-btn:hover { background-color: rgba(255, 255, 255, 0.25); }
        .side-panel {
            grid-area: sidebar; background-color: var(--card-bg); border-right: 1px solid var(--border-color);
            padding: 2rem; display: flex; flex-direction: column;
        }
        .side-panel h2 {
            font-size: 1.2rem; color: var(--primary-color); margin: 0 0 1.5rem 0;
            border-bottom: 1px solid var(--border-color); padding-bottom: 1rem;
        }
        .side-panel-nav { list-style: none; padding: 0; margin: 0; }
        .side-panel-nav li a {
            display: flex; align-items: center; gap: 1rem; padding: 0.8rem 1rem;
            margin-bottom: 0.5rem; text-decoration: none; color: var(--light-text-color);
            font-weight: 500; border-radius: 6px; transition: all 0.3s ease;
        }
        .side-panel-nav li a:hover { background-color: var(--secondary-color); color: var(--primary-color); }
        .side-panel-nav li a.active { background-color: var(--accent-color); color: white; font-weight: 600; }
        .side-panel-nav li a i { width: 20px; text-align: center; }
        .main-content {
            grid-area: main; padding: 2.5rem; overflow-y: auto;
        }
        .welcome-banner {
            background: linear-gradient(100deg, #3b82f6, #60a5fa); color: white;
            padding: 2rem; border-radius: 12px; margin-bottom: 2.5rem;
            display: flex; justify-content: space-between; align-items: center;
        }
        .welcome-banner h2 { font-size: 1.8rem; margin: 0; font-weight: 700; }
        .welcome-banner p { margin: 0.25rem 0 0; opacity: 0.9; }
        .date-display {
            background-color: rgba(255,255,255,0.2); padding: 0.75rem 1.25rem;
            border-radius: 8px; font-weight: 600; text-align: center;
        }
        .date-display .label { font-size: 0.8rem; opacity: 0.8; }
        .date-display .date { font-size: 1.1rem; }
        .stats-grid {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem; margin-bottom: 2.5rem;
        }
        .stat-card {
            background-color: var(--card-bg); border: 1px solid var(--border-color);
            border-radius: 12px; padding: 1.5rem; display: flex;
            justify-content: space-between; align-items: center;
        }
        .stat-card .number { font-size: 2rem; font-weight: 800; }
        .stat-card .label { font-size: 1rem; color: var(--light-text-color); font-weight: 500; }
        .stat-card .icon-wrapper {
            width: 50px; height: 50px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center; font-size: 1.5rem;
        }
        .icon-students { background-color: #e0e7ff; color: #3730a3; }
        .icon-rooms { background-color: #d1fae5; color: #047857; }
        .icon-fees { background-color: #fef3c7; color: #b45309; }
        .icon-apps { background-color: #fee2e2; color: #b91c1c; }
        .activity-card {
            background-color: var(--card-bg); border: 1px solid var(--border-color);
            border-radius: 12px;
        }
        .activity-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .activity-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .activity-list { list-style: none; padding: 0; margin: 0; }
        .activity-item {
            display: flex; align-items: center; gap: 1rem;
            padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color);
        }
        .activity-item:last-child { border-bottom: none; }
        .activity-item .icon-wrapper {
            width: 40px; height: 40px; flex-shrink: 0; font-size: 1rem;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
        }
        .activity-item .details { flex-grow: 1; }
        .activity-item .title { font-weight: 600; }
        .activity-item .description { color: var(--light-text-color); font-size: 0.9rem; }
        .activity-item .time { color: var(--light-text-color); font-size: 0.9rem; white-space: nowrap; }
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
        @media (max-width: 768px) {
            .welcome-banner { flex-direction: column; align-items: flex-start; gap: 1rem; }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu">
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, <%= adminName %></span>
            <a href="admin_logout.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>

    <aside class="side-panel">
        <h2>Admin Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="admin_dashboard.jsp" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="admin_profile.jsp"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="admin_applications.jsp"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="admin_slist.jsp"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <div class="welcome-banner">
            <div>
                <h2>Welcome back, <%= adminName %>!</h2>
                <p>Here's what's happening in your hostel today.</p>
            </div>
            <div class="date-display">
                <div class="label">TODAY'S DATE</div>
                <div class="date"><%= formattedDate %></div>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div>
                    <div class="number"><%= totalStudents %></div>
                    <div class="label">Total Students</div>
                </div>
                <div class="icon-wrapper icon-students"><i class="fas fa-users"></i></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="number"><%= availableSlots %></div>
                    <div class="label">Available Slots</div>
                </div>
                <div class="icon-wrapper icon-rooms"><i class="fas fa-bed"></i></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="number"><%= formattedFees %></div>
                    <div class="label">Pending Fees</div>
                </div>
                <div class="icon-wrapper icon-fees"><i class="fas fa-exclamation-triangle"></i></div>
            </div>
            <div class="stat-card">
                <div>
                    <div class="number"><%= newApplications %></div>
                    <div class="label">New Applications</div>
                </div>
                <div class="icon-wrapper icon-apps"><i class="fas fa-file-alt"></i></div>
            </div>
        </div>

        <div class="activity-card">
            <div class="activity-header"><h2>Last Activity</h2></div>
            <ul class="activity-list">
                <% for(HashMap<String, String> activity : recentActivity) { %>
                    <li class="activity-item">
                        <div class="icon-wrapper <%= activity.get("icon_class") %>"><i class="fas <%= activity.get("icon") %>"></i></div>
                        <div class="details">
                            <div class="title"><%= activity.get("title") %></div>
                            <div class="description"><%= activity.get("description") %></div>
                        </div>
                        <div class="time"><%= activity.get("time") %></div>
                    </li>
                <% } %>
                <% if(recentActivity.isEmpty()) { %>
                    <li class="activity-item">
                        <div class="details">No recent applications or payments.</div>
                    </li>
                <% } %>
            </ul>
        </div>
    </main>
</body>
</html>