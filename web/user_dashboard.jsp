<%@ page import="java.sql.*, java.util.HashMap" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR STUDENT DASHBOARD
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("user_roll_no") == null) {
        response.sendRedirect("user_login.jsp?error=Please login first");
        return;
    }
    String userRollNo = (String) session.getAttribute("user_roll_no");

    // --- 2. INITIALIZE VARIABLES ---
    String fullName = "";
    boolean isProfileComplete = false;
    String applicationStatus = "Not Applied"; // Default status
    String paymentStatus = "Unpaid"; // Default status
    HashMap<String, String> roomDetails = new HashMap<>();

    // --- 3. DATABASE OPERATIONS ---
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

        // Query 1: Get Full Name
        pstmt = conn.prepareStatement("SELECT fullname FROM student_auth WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("fullname");
        }
        rs.close(); pstmt.close();

        // Query 2: Get Profile Status
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM student_profiles WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next() && rs.getInt(1) > 0) {
            isProfileComplete = true;
        }
        rs.close(); pstmt.close();

        // Query 3: Get Application Status (most recent one)
        pstmt = conn.prepareStatement("SELECT status FROM applications WHERE stud_roll = ? ORDER BY applied_date DESC LIMIT 1");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            applicationStatus = rs.getString("status");
        }
        rs.close(); pstmt.close();

        // Query 4: Get Payment Status
        pstmt = conn.prepareStatement("SELECT payment_status FROM fees WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            paymentStatus = rs.getString("payment_status");
        }
        rs.close(); pstmt.close();

        // Query 5: Get Room Allocation (only if application is approved)
        if ("Approved".equals(applicationStatus)) {
            String roomSql = "SELECT ra.room_no, r.floor_no, h.hostel_name " +
                           "FROM room_allocations ra " +
                           "JOIN room r ON ra.room_no = r.room_no " +
                           "JOIN hostels h ON r.hostel_id = h.hostel_id " +
                           "WHERE ra.roll_no = ?";
            pstmt = conn.prepareStatement(roomSql);
            pstmt.setString(1, userRollNo);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                roomDetails.put("hostel_name", rs.getString("hostel_name"));
                roomDetails.put("floor_no", rs.getString("floor_no"));
                roomDetails.put("room_no", rs.getString("room_no"));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard</title>
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
        .top-panel { grid-area: header; background: linear-gradient(135deg, var(--accent-color), #4f87ff); color: #ffffff; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; z-index: 10; }
        .top-panel h1 { margin: 0; font-size: 1.8em; }
        .user-menu { display: flex; align-items: center; gap: 1.5rem; }
        .user-info { display: flex; align-items: center; gap: 0.75rem; font-weight: 500; }
        .user-info .fa-user-circle { font-size: 1.5rem; }
        .logout-btn { display: flex; align-items: center; gap: 0.5rem; background-color: rgba(255, 255, 255, 0.15); color: white; padding: 0.5rem 1rem; border-radius: 6px; text-decoration: none; font-weight: 500; transition: background-color 0.3s ease; }
        .logout-btn:hover { background-color: rgba(255, 255, 255, 0.25); }
        .side-panel { grid-area: sidebar; background-color: var(--card-bg); border-right: 1px solid var(--border-color); padding: 2rem; display: flex; flex-direction: column; }
        .side-panel h2 { font-size: 1.2rem; color: var(--primary-color); margin: 0 0 1.5rem 0; border-bottom: 1px solid var(--border-color); padding-bottom: 1rem; }
        .side-panel-nav { list-style: none; padding: 0; margin: 0; }
        .side-panel-nav li a { display: flex; align-items: center; gap: 1rem; padding: 0.8rem 1rem; margin-bottom: 0.5rem; text-decoration: none; color: var(--light-text-color); font-weight: 500; border-radius: 6px; transition: all 0.3s ease; }
        .side-panel-nav li a:hover { background-color: var(--secondary-color); color: var(--primary-color); }
        .side-panel-nav li a.active { background-color: var(--accent-color); color: white; font-weight: 600; }
        .side-panel-nav li a i { width: 20px; text-align: center; }
        .main-content { grid-area: main; padding: 2.5rem; overflow-y: auto; }
        .dashboard-header { margin-bottom: 2rem; }
        .dashboard-header h1 { font-size: 2.2rem; font-weight: 800; margin: 0; }
        .dashboard-header p { font-size: 1.1rem; color: var(--light-text-color); margin-top: 0.5rem; }
        .quick-actions { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2.5rem; }
        .action-card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 1.5rem; text-decoration: none; color: var(--primary-color); transition: all 0.2s ease-in-out; display: flex; align-items: center; gap: 1rem; }
        .action-card:hover { transform: translateY(-5px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); border-color: var(--accent-color); }
        .action-card .icon { font-size: 1.8rem; color: var(--accent-color); }
        .action-card .title { font-size: 1.1rem; font-weight: 600; }
        .status-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1.5rem; margin-bottom: 2.5rem; }
        .status-card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 1.5rem; }
        .status-card-header { display: flex; align-items: center; gap: 0.75rem; color: var(--light-text-color); font-weight: 500; margin-bottom: 1rem; }
        .status-card-body .status-text { font-size: 1.5rem; font-weight: 700; margin-bottom: 0.5rem; }
        .status-card-body .status-description { margin-top: 0; color: var(--light-text-color); }
        .status-text.approved { color: var(--success-color); }
        .status-text.pending { color: var(--warning-color); }
        .status-text.rejected { color: var(--danger-color); }
        .status-text.incomplete { color: var(--danger-color); }
        .status-text.not-applied, .status-text.unpaid { color: var(--light-text-color); }
        .status-card-footer a { color: var(--accent-color); font-weight: 600; text-decoration: none; }
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 1.5rem; }
        .details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; }
        .detail-item .label { font-size: 0.9rem; color: var(--light-text-color); }
        .detail-item .value { font-size: 1.1rem; font-weight: 600; margin-top: 0.25rem; }
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu">
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, <%= fullName %></span>
            <a href="user_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>

    <aside class="side-panel">
        <h2>Student Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="user_dashboard.jsp" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="user_apply.jsp"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="user_profile.jsp"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="user_downloads.jsp"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <div class="dashboard-header">
            <h1>Welcome back, <%= fullName.split(" ")[0] %>!</h1>
            <p>Here's an overview of your hostel application status and actions.</p>
        </div>

        <div class="quick-actions">
            <a href="user_apply.jsp" class="action-card"><i class="fas fa-file-signature icon"></i><div><span class="title">Apply for Hostel</span></div></a>
            <a href="user_payfees.jsp" class="action-card"><i class="fas fa-credit-card icon"></i><div><span class="title">Pay Fees</span></div></a>
        </div>

        <div class="status-grid">
            <div class="status-card">
                <div class="status-card-header"><i class="fas fa-user"></i><span>Profile Status</span></div>
                <div class="status-card-body">
                    <% if (isProfileComplete) { %>
                        <div class="status-text approved">Complete</div>
                        <p class="status-description">Your profile details are up to date.</p>
                    <% } else { %>
                        <div class="status-text incomplete">Incomplete</div>
                        <p class="status-description">Please complete your profile to apply for a hostel.</p>
                    <% } %>
                </div>
                <div class="status-card-footer"><a href="user_profile.jsp">Update Profile &rarr;</a></div>
            </div>
            
            <div class="status-card">
                <div class="status-card-header"><i class="fas fa-file-alt"></i><span>Application Status</span></div>
                <div class="status-card-body">
                    <% if ("Approved".equals(applicationStatus)) { %>
                        <div class="status-text approved">Approved</div>
                        <p class="status-description">Congratulations! Your application has been approved.</p>
                    <% } else if ("Pending".equals(applicationStatus)) { %>
                        <div class="status-text pending">Pending</div>
                        <p class="status-description">Your application is under review by the administration.</p>
                    <% } else if ("Rejected".equals(applicationStatus)) { %>
                        <div class="status-text rejected">Rejected</div>
                        <p class="status-description">Your application was not approved. Please contact support.</p>
                    <% } else { %>
                        <div class="status-text not-applied">Not Applied</div>
                        <p class="status-description">You have not applied for a hostel yet.</p>
                    <% } %>
                </div>
                <div class="status-card-footer"><a href="user_status.jsp">Check Details &rarr;</a></div>
            </div>

            <div class="status-card">
                <div class="status-card-header"><i class="fas fa-dollar-sign"></i><span>Payment Status</span></div>
                <div class="status-card-body">
                     <% if ("Paid".equals(paymentStatus)) { %>
                        <div class="status-text approved">Paid</div>
                        <p class="status-description">Your fee payment has been successfully received.</p>
                    <% } else { %>
                        <div class="status-text unpaid">Unpaid</div>
                        <p class="status-description">Your fee payment is pending. Please pay to confirm your room.</p>
                    <% } %>
                </div>
                <div class="status-card-footer"><a href="user_payfees.jsp">View History &rarr;</a></div>
            </div>
        </div>

        <%-- This card only appears if a room is allocated --%>
        <% if ("Approved".equals(applicationStatus) && !roomDetails.isEmpty()) { %>
            <div class="card">
                <div class="card-header"><h2>Your Room Allocation</h2></div>
                <div class="card-body">
                    <div class="details-grid">
                        <div class="detail-item">
                            <div class="label">Hostel</div>
                            <div class="value"><%= roomDetails.get("hostel_name") %></div>
                        </div>
                        <div class="detail-item">
                            <div class="label">Floor Number</div>
                            <div class="value"><%= roomDetails.get("floor_no") %></div>
                        </div>
                        <div class="detail-item">
                            <div class="label">Room Number</div>
                            <div class="value"><%= roomDetails.get("room_no") %></div>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
    </main>
</body>
</html>