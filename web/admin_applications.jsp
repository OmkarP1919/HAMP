<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR APPLICATION MANAGEMENT (WITH FEE GENERATION)
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }
    String adminName = (String) session.getAttribute("admin_name");

    // --- 2. INITIALIZE VARIABLES ---
    List<HashMap<String, Object>> applications = new ArrayList<>();
    String successMessage = null;
    String errorMessage = null;

    // --- 3. DATABASE OPERATIONS ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String url = "jdbc:mysql://localhost:3306/hamp";
        String dbUsername = "root";
        String dbPassword = "root";
        // Using the modern driver for MySQL Connector/J 8.0+
        String driver = "com.mysql.jdbc.Driver"; // Corrected driver name
        Class.forName(driver);
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        // --- 3A. HANDLE ACTIONS (APPROVE/REJECT) ---
        String action = request.getParameter("action");
        String appIdStr = request.getParameter("app_id");

        if (action != null && appIdStr != null) {
            int appId = Integer.parseInt(appIdStr);
            String studentRollNo = null;

            // Get the student's roll number for the given application (must be Pending)
            pstmt = conn.prepareStatement("SELECT stud_roll FROM applications WHERE app_id = ? AND status = 'Pending'");
            pstmt.setInt(1, appId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                studentRollNo = rs.getString("stud_roll");
            }
            rs.close(); // Close ResultSet after use
            if (pstmt != null) pstmt.close(); // Close PreparedStatement after use - important for subsequent statements

            if (studentRollNo != null) { // Proceed only if a pending application was found
                String newStatus = "approve".equals(action) ? "Approved" : "Rejected";
                
                // Use a transaction to ensure both tables are updated correctly
                conn.setAutoCommit(false); // Start transaction
                
                try {
                    // 1. Update the application status
                    pstmt = conn.prepareStatement("UPDATE applications SET status = ?, review_date = CURDATE() WHERE app_id = ?");
                    pstmt.setString(1, newStatus);
                    pstmt.setInt(2, appId);
                    pstmt.executeUpdate();
                    if (pstmt != null) pstmt.close();

                    // 2. If approved, create the fee record if one doesn't already exist
                    if ("Approved".equals(newStatus)) {
                        // Check to prevent creating duplicate 'Unpaid' fees
                        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM fees WHERE roll_no = ? AND payment_status = 'Unpaid'");
                        pstmt.setString(1, studentRollNo);
                        rs = pstmt.executeQuery();
                        rs.next();
                        if (rs.getInt(1) == 0) { // If no existing unpaid fee for this student
                            double totalFees = 21000.00; // Example fee amount - adjust as needed
                            pstmt = conn.prepareStatement(
                                "INSERT INTO fees (roll_no, total_fees, paid_fees, payment_status) VALUES (?, ?, 0.00, 'Unpaid')"
                            );
                            pstmt.setString(1, studentRollNo);
                            pstmt.setDouble(2, totalFees);
                            pstmt.executeUpdate();
                            if (pstmt != null) pstmt.close();
                            successMessage = "Application #" + appId + " approved and fee generated.";
                        } else {
                            successMessage = "Application #" + appId + " approved. Fee already generated for this student.";
                        }
                        if (rs != null) rs.close(); // Close ResultSet
                    } else { // If rejected
                        successMessage = "Application #" + appId + " has been rejected.";
                    }
                    
                    conn.commit(); // Finalize the changes if all succeeded

                } catch (SQLException e) {
                    if (conn != null) conn.rollback(); // Undo changes if anything fails
                    errorMessage = "Database update failed. Transaction rolled back. Error: " + e.getMessage();
                    e.printStackTrace();
                } finally {
                    if (conn != null) conn.setAutoCommit(true); // Restore default auto-commit behavior
                    // Ensure pstmt and rs are closed again even in finally block after a rollback
                    try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            } else {
                errorMessage = "Application not found or already processed.";
            }
        }

        // --- 3B. FETCH ALL APPLICATIONS FOR DISPLAY ---
        // Fetch application details along with payment status from the fees table
        // AND room allocation status from the room_allocations table
        String sql = "SELECT a.app_id, sa.fullname, a.stud_roll, a.applied_date, a.status, " +
                     "       COALESCE(f.payment_status, 'N/A') as payment_status, " +
                     "       CASE WHEN ra.room_no IS NOT NULL THEN 'Allocated' ELSE 'Not Allocated' END as room_allocation_status " +
                     "FROM applications a " +
                     "JOIN student_auth sa ON a.stud_roll = sa.roll_no " +
                     "LEFT JOIN fees f ON a.stud_roll = f.roll_no " +
                     "LEFT JOIN room_allocations ra ON a.stud_roll = ra.roll_no " + // LEFT JOIN to get allocation status
                     "ORDER BY a.applied_date DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            HashMap<String, Object> app = new HashMap<>();
            app.put("app_id", rs.getInt("app_id"));
            app.put("student_name", rs.getString("fullname"));
            app.put("roll_no", rs.getString("stud_roll"));
            app.put("applied_on", rs.getDate("applied_date"));
            app.put("status", rs.getString("status"));
            app.put("payment_status", rs.getString("payment_status"));
            app.put("room_allocation_status", rs.getString("room_allocation_status")); // Store allocation status
            applications.add(app);
        }

    } catch (Exception e) {
        errorMessage = "An error occurred: " + e.getMessage();
        e.printStackTrace();
    } finally {
        // Ensure all JDBC resources are closed
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Application Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --pending-color: #f59e0b; --pending-bg: #fffbeb; --pending-border: #fde68a;
            --approved-color: #10b981; --approved-bg: #f0fdf4; --approved-border: #a7f3d0;
            --rejected-color: #ef4444; --rejected-bg: #fef2f2; --rejected-border: #fca5a5;
            --info-color: #3b82f6; --info-bg: #eff6ff; --info-border: #bfdbfe;
            --allocate-color: #6366f1; /* Indigo for allocate button */
            --view-color: #4b5563; /* Gray for view button */
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
        .page-header h1 { font-size: 2rem; font-weight: 800; margin: 0 0 1.5rem 0; }
        .message-box { padding: 1rem; margin-bottom: 1.5rem; border-radius: 8px; font-weight: 500; }
        .message-box.success { background-color: var(--approved-bg); border: 1px solid var(--approved-border); color: var(--approved-color); }
        .message-box.error { background-color: var(--rejected-bg); border: 1px solid var(--rejected-border); color: var(--rejected-color); }
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 2rem; }
        .table-container { width: 100%; overflow-x: auto; }
        .applications-table { width: 100%; border-collapse: collapse; }
        .applications-table th, .applications-table td { padding: 1.25rem 1.5rem; text-align: left; border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        .applications-table thead { background-color: var(--secondary-color); }
        .applications-table th { font-size: 0.85rem; font-weight: 600; text-transform: uppercase; color: var(--light-text-color); }
        .applications-table tbody tr:hover { background-color: var(--secondary-color); }
        .status-badge { padding: 0.3rem 0.8rem; border-radius: 1rem; font-size: 0.85rem; font-weight: 600; color: white; }
        .status-badge.Pending { background-color: var(--pending-color); }
        .status-badge.Approved { background-color: var(--approved-color); }
        .status-badge.Rejected { background-color: var(--rejected-color); }
        /* New badge for payment status */
        .status-badge.Paid { background-color: var(--approved-color); }
        .status-badge.Unpaid { background-color: var(--pending-color); }
        .status-badge.N\/A { background-color: var(--light-text-color); }


        .action-buttons { display: flex; gap: 0.5rem; }
        .action-button { padding: 0.6rem 1rem; border-radius: 6px; font-weight: 500; text-decoration: none; cursor: pointer; transition: background-color 0.2s ease; font-size: 0.9rem; }
        .action-button.approve { background-color: var(--approved-color); color: white; border: 1px solid var(--approved-color); }
        .action-button.approve:hover { background-color: #0c8a66; }
        .action-button.reject { background-color: var(--rejected-color); color: white; border: 1px solid var(--rejected-color); }
        .action-button.reject:hover { background-color: #b91c1c; }
        .action-button.allocate { background-color: var(--allocate-color); color: white; border: 1px solid var(--allocate-color); }
        .action-button.allocate:hover { background-color: #4338ca; }
        .action-button.view-form { background-color: var(--view-color); color: white; border: 1px solid var(--view-color); }
        .action-button.view-form:hover { background-color: #374151; }
        /* Style for disabled buttons */
        .action-button.disabled {
            background-color: #e0e0e0;
            color: #a0a0a0;
            border-color: #e0e0e0;
            cursor: not-allowed;
            pointer-events: none;
            opacity: 0.6;
        }

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
            <span class="user-info"><i class="fas fa-user-circle"></i> Welcome, <%= adminName %></span>
            <a href="admin_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </header>
    <aside class="side-panel">
        <h2>Admin Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="admin_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="admin_profile.jsp"><i class="fas fa-user-cog"></i> Profile</a></li>
            <li><a href="admin_applications.jsp" class="active"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="admin_slist.jsp"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp"><i class="fas fa-bed"></i> Rooms</a></li>
            <%-- Removed "Allocate Room" from here --%>
            <%-- <li><a href="admin_allocate_room.jsp"><i class="fas fa-person-booth"></i> Allocate Room</a></li> --%>
        </ul>
    </aside>
    <main class="main-content">
        <div class="page-header">
            <h1>Manage Applications</h1>
            <%-- Display success or error messages --%>
            <% if (successMessage != null) { %>
                <div class="message-box success"><%= successMessage %></div>
            <% } else if (errorMessage != null) { %>
                <div class="message-box error"><%= errorMessage %></div>
            <% } %>
        </div>

        <div class="card">
            <div class="table-container">
                <table class="applications-table">
                    <thead>
                        <tr>
                            <th>App ID</th>
                            <th>Student Name</th>
                            <th>Roll No</th>
                            <th>Applied On</th>
                            <th>App. Status</th>
                            <th>Payment Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (applications.isEmpty()) { %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--light-text-color); padding: 2rem;">No applications found.</td>
                            </tr>
                        <% } else {
                                for (HashMap<String, Object> app : applications) {
                        %>
                                <tr>
                                    <td><%= app.get("app_id") %></td>
                                    <td><%= app.get("student_name") %></td>
                                    <td><%= app.get("roll_no") %></td>
                                    <td><%= sdf.format((java.util.Date)app.get("applied_on")) %></td>
                                    <td><span class="status-badge <%= app.get("status") %>"><%= app.get("status") %></span></td>
                                    <td><span class="status-badge <%= app.get("payment_status") %>"><%= app.get("payment_status") %></span></td>
                                    <td class="action-buttons">
                                        <%
                                            String appStatus = (String)app.get("status");
                                            String paymentStatus = (String)app.get("payment_status");
                                            String roomAllocationStatus = (String)app.get("room_allocation_status"); // Get the new status
                                            String currentRollNo = (String)app.get("roll_no");
                                            int currentAppId = (Integer)app.get("app_id");
                                        %>

                                        <% if ("Pending".equals(appStatus)) { %>
                                            <a href="view_application.jsp?app_id=<%= currentAppId %>" class="action-button view-form"><i class="fas fa-eye"></i> View Form</a>
                                            <a href="admin_applications.jsp?action=approve&app_id=<%= currentAppId %>" class="action-button approve" onclick="return confirm('Are you sure you want to approve this application and generate fee?');">Approve</a>
                                            <a href="admin_applications.jsp?action=reject&app_id=<%= currentAppId %>" class="action-button reject" onclick="return confirm('Are you sure you want to reject this application?');">Reject</a>
                                        <% } else if ("Approved".equals(appStatus) && "Paid".equals(paymentStatus) && "Not Allocated".equals(roomAllocationStatus)) { %>
                                            <%-- Show Allocate Room button ONLY if Approved, Paid, AND Not Allocated --%>
                                            <a href="admin_allocate_room.jsp?stud_roll=<%= currentRollNo %>" class="action-button allocate"><i class="fas fa-person-booth"></i> Allocate Room</a>
                                        <% } else if ("Approved".equals(appStatus) && "Paid".equals(paymentStatus) && "Allocated".equals(roomAllocationStatus)) { %>
                                            <%-- Show a re-allocate button or just "Allocated" status if already allocated --%>
                                            <a href="admin_allocate_room.jsp?stud_roll=<%= currentRollNo %>" class="action-button allocate" title="Student is already allocated a room. Click to re-allocate if needed."><i class="fas fa-exchange-alt"></i> Re-allocate Room</a>
                                        <% } else { %>
                                            <%-- For Rejected, or Approved but Unpaid/N/A applications, or Approved/Paid/Allocated, show no actions --%>
                                            <span class="action-button view disabled" style="opacity: 0.7; cursor: not-allowed;">No Actions</span>
                                        <% } %>
                                    </td>
                                </tr>
                        <%
                                }
                            } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</body>
</html>