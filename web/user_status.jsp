<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR APPLICATION STATUS PAGE (CORRECTED)
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
    HashMap<String, Object> appData = new HashMap<>();
    String paymentStatus = null;
    boolean isRoomAllocated = false;
    int progressStep = 0; 

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

        // --- Query 1: Get Full Name for header ---
        pstmt = conn.prepareStatement("SELECT fullname FROM student_auth WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("fullname");
        }

        // --- Query 2: Get the most recent application ---
        pstmt = conn.prepareStatement("SELECT * FROM applications WHERE stud_roll = ? ORDER BY applied_date DESC LIMIT 1");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            appData.put("status", rs.getString("status"));
            appData.put("applied_date", rs.getDate("applied_date"));
            appData.put("review_date", rs.getDate("review_date"));
            appData.put("remark", rs.getString("remark"));
            progressStep = 1;

            String appStatus = (String) appData.get("status");

            if ("Pending".equals(appStatus) || "Approved".equals(appStatus) || "Rejected".equals(appStatus)) {
                progressStep = 2;
            }
            if ("Approved".equals(appStatus) || "Rejected".equals(appStatus)) {
                progressStep = 3;
            }

            if ("Approved".equals(appStatus)) {
                pstmt = conn.prepareStatement("SELECT payment_status FROM fees WHERE roll_no = ?");
                pstmt.setString(1, userRollNo);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    paymentStatus = rs.getString("payment_status");
                }
                
                if("Paid".equals(paymentStatus)) {
                    progressStep = 4;
                    pstmt = conn.prepareStatement("SELECT COUNT(*) FROM room_allocations WHERE roll_no = ?");
                    pstmt.setString(1, userRollNo);
                    rs = pstmt.executeQuery();
                    if (rs.next() && rs.getInt(1) > 0) {
                        isRoomAllocated = true;
                        progressStep = 5;
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }

    SimpleDateFormat sdf = new SimpleDateFormat("MMMM d, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Status</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --success-color: #10b981; --warning-color: #f59e0b; --danger-color: #ef4444;
        }
        * { box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; margin: 0; background-color: var(--secondary-color); color: var(--primary-color); height: 100vh; display: grid; grid-template-rows: auto 1fr; grid-template-columns: 260px 1fr; grid-template-areas: "header header" "sidebar main"; }
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
        .page-header h1 { font-size: 2rem; font-weight: 800; margin: 0 0 2.5rem 0; }
        .status-container { max-width: 800px; }
        .status-tracker { position: relative; padding-left: 2.5rem; }
        .status-tracker::before { content: ''; position: absolute; left: 2px; top: 25px; bottom: 25px; width: 4px; background-color: var(--border-color); border-radius: 2px; }
        .timeline-progress { content: ''; position: absolute; left: 2px; top: 25px; width: 4px; background-color: var(--success-color); border-radius: 2px; transition: height 0.5s ease-in-out; }
        .status-tracker.rejected-flow .timeline-progress { background-color: var(--danger-color); }
        .status-step { position: relative; margin-bottom: 2.5rem; }
        .status-step:last-child { margin-bottom: 0; }
        .status-icon { position: absolute; left: -2.5rem; top: 0; transform: translateX(-50%); width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; background-color: var(--card-bg); border: 4px solid var(--border-color); }
        .status-content { padding-left: 1.5rem; }
        .status-title { font-size: 1.25rem; font-weight: 700; margin: 0 0 0.25rem 0; }
        .status-date { font-size: 0.9rem; color: var(--light-text-color); margin-bottom: 0.75rem; }
        .status-description { font-size: 1rem; line-height: 1.6; color: var(--light-text-color); }
        .status-description a { color: var(--accent-color); font-weight: 600; text-decoration: none; }
        .status-description a:hover { text-decoration: underline; }
        .status-step.complete .status-icon { border-color: var(--success-color); background-color: var(--success-color); color: white; }
        .status-step.in-progress .status-icon { border-color: var(--warning-color); background-color: var(--warning-color); color: white; animation: pulse 1.5s infinite; }
        .status-step.pending .status-icon { color: var(--light-text-color); }
        .status-step.rejected .status-icon { border-color: var(--danger-color); background-color: var(--danger-color); color: white; }
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; margin-top: 2.5rem; }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 1.5rem; font-size: 1rem; color: var(--light-text-color); line-height: 1.6; }
        .no-app-card { text-align: center; }
        .button { display: inline-block; text-decoration: none; padding: 0.75rem 1.5rem; border-radius: 8px; background-color: var(--accent-color); color: white; font-size: 1rem; font-weight: 700; cursor: pointer; transition: all 0.2s ease; }
        @keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0.7); } 70% { box-shadow: 0 0 0 10px rgba(245, 158, 11, 0); } 100% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0); } }
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
            <li><a href="user_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="user_apply.jsp"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="user_profile.jsp"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="user_downloads.jsp"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp" class="active"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <div class="status-container">
            <div class="page-header">
                <h1>Your Application Journey</h1>
            </div>

            <% if (appData.isEmpty()) { %>
                <div class="card no-app-card">
                    <div class="card-body">
                        <h2>No Application Found</h2>
                        <p style="margin-bottom: 2rem;">You haven't submitted a hostel application yet. Click the button below to start.</p>
                        <a href="user_apply.jsp" class="button">Apply Now</a>
                    </div>
                </div>
            <% } else { 
                String appStatus = (String) appData.get("status");
                double progressHeight = (progressStep > 1) ? ((progressStep - 1) * 110.0) + 25 : 0;
            %>
                <div class="status-tracker <%= "Rejected".equals(appStatus) ? "rejected-flow" : "" %>">
                    <div class="timeline-progress" style="height: <%= progressHeight %>px;"></div>
                    
                    <%-- Step 1: Application Submitted --%>
                    <div class="status-step complete">
                        <div class="status-icon"><i class="fas fa-check"></i></div>
                        <div class="status-content">
                            <h3 class="status-title">Application Submitted</h3>
                            <p class="status-date">Submitted on: <%= sdf.format((java.util.Date)appData.get("applied_date")) %></p>
                            <p class="status-description">We have received your application. It will be reviewed by the administration shortly.</p>
                        </div>
                    </div>

                    <%-- Step 2: Application Review --%>
                    <%
                        String step2Class = "pending";
                        if ("Pending".equals(appStatus)) step2Class = "in-progress";
                        if ("Approved".equals(appStatus) || "Rejected".equals(appStatus)) step2Class = "complete";
                    %>
                    <div class="status-step <%= step2Class %>">
                        <div class="status-icon"><i class="fas <%= "complete".equals(step2Class) ? "fa-check" : "fa-hourglass-half" %>"></i></div>
                        <div class="status-content">
                            <h3 class="status-title">Under Review</h3>
                             <p class="status-date"><% if (appData.get("review_date") != null) { %>Reviewed on: <%= sdf.format((java.util.Date)appData.get("review_date")) %><% } else { %>Awaiting review...<% } %></p>
                            <p class="status-description">Your application is being reviewed. This may take a few business days.</p>
                        </div>
                    </div>

                    <%-- Step 3: Application Decision --%>
                    <% if (!"Pending".equals(appStatus)) { %>
                        <div class="status-step <%= "Approved".equals(appStatus) ? "complete" : "rejected" %>">
                            <div class="status-icon"><i class="fas <%= "Approved".equals(appStatus) ? "fa-check" : "fa-times" %>"></i></div>
                            <div class="status-content">
                                <h3 class="status-title">Application <%= appStatus %></h3>
                                <p class="status-date">Decision made on: <% if (appData.get("review_date") != null) { %><%= sdf.format((java.util.Date)appData.get("review_date")) %><% } %></p>
                                <p class="status-description"><% if("Approved".equals(appStatus)) { %>Congratulations! Your application is approved. Please proceed with the fee payment to secure your spot.<% } else { %>Your application has been rejected. Please see the administrator remarks below for more details.<% } %></p>
                            </div>
                        </div>
                    <% } %>

                    <%-- Step 4 & 5 --%>
                    <% if ("Approved".equals(appStatus) || "Rejected".equals(appStatus)) { 
                        String step4Class = "pending";
                        if("Approved".equals(appStatus) && !"Paid".equals(paymentStatus)) step4Class = "in-progress";
                        if("Paid".equals(paymentStatus)) step4Class = "complete";
                        if("Rejected".equals(appStatus)) step4Class = "pending";
                    %>
                        <div class="status-step <%= step4Class %>">
                            <div class="status-icon"><i class="fas <%= "complete".equals(step4Class) ? "fa-check" : "fa-credit-card" %>"></i></div>
                            <div class="status-content">
                                <h3 class="status-title">Fee Payment</h3>
                                <p class="status-description"><% if ("complete".equals(step4Class)) { %>Your fee payment has been successfully confirmed.<% } else if ("in-progress".equals(step4Class)) { %>Your application is approved. Please <a href="user_payfees.jsp">pay your fees</a> to proceed.<% } else { %>Awaiting application approval.<% } %></p>
                            </div>
                        </div>
                    <% } %>

                    <% if ("Paid".equals(paymentStatus)) {
                        String step5Class = isRoomAllocated ? "complete" : "in-progress";
                    %>
                    <div class="status-step <%= step5Class %>">
                        <div class="status-icon"><i class="fas <%= "complete".equals(step5Class) ? "fa-check" : "fa-key" %>"></i></div>
                        <div class="status-content">
                            <h3 class="status-title">Room Allocated</h3>
                            <p class="status-description"><% if (isRoomAllocated) { %>Your room has been allocated. You can view the details on your <a href="user_dashboard.jsp">dashboard</a>.<% } else { %>Your payment is confirmed. Room allocation is in progress.<% } %></p>
                        </div>
                    </div>
                    <% } %>
                </div>

                <% String remarks = (String) appData.get("remark");
                   if (remarks != null && !remarks.trim().isEmpty()) { %>
                    <div class="card">
                        <div class="card-header"><h2>Administrator Remarks</h2></div>
                        <div class="card-body"><%= remarks %></div>
                    </div>
                <% } %>
            <% } %>
        </div>
    </main>
</body>
</html>