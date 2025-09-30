<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%-- =================================================================
     SERVER-SIDE LOGIC FOR VIEWING A SINGLE APPLICATION
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }
    String adminName = (String) session.getAttribute("admin_name");

    // --- 2. INITIALIZE VARIABLES ---
    HashMap<String, Object> applicationDetails = null;
    String viewErrorMessage = null;
    int appId = -1; // Default invalid ID

    // --- 3. GET APPLICATION ID FROM REQUEST ---
    String appIdStr = request.getParameter("app_id");
    if (appIdStr != null && !appIdStr.trim().isEmpty()) {
        try {
            appId = Integer.parseInt(appIdStr);
        } catch (NumberFormatException e) {
            viewErrorMessage = "Invalid Application ID provided.";
        }
    } else {
        viewErrorMessage = "No Application ID provided.";
    }

    // --- 4. DATABASE OPERATIONS ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    if (appId != -1 && viewErrorMessage == null) {
        try {
            String url = "jdbc:mysql://localhost:3306/hamp";
            String dbUsername = "root";
            String dbPassword = "root";
            String driver = "com.mysql.jdbc.Driver";
            Class.forName(driver);
            conn = DriverManager.getConnection(url, dbUsername, dbPassword);

            // Fetch comprehensive details for the application by joining applications, student_auth, student_profiles, and fees
            String sql = "SELECT a.app_id, a.stud_roll, a.applied_date, a.status, a.review_date, a.remark, " +
                         "       sa.fullname, sa.email, sa.mobile, " + // From student_auth
                         "       sp.gender, sp.dob, sp.aadhar_no, sp.address, sp.parents_mobile, sp.course, sp.year, sp.department, " + // From student_profiles
                         "       COALESCE(f.payment_status, 'N/A') as payment_status, " +
                         "       COALESCE(f.total_fees, 0.00) as total_fees, " +
                         "       COALESCE(f.paid_fees, 0.00) as paid_fees " + // From fees
                         "FROM applications a " +
                         "JOIN student_auth sa ON a.stud_roll = sa.roll_no " +
                         "LEFT JOIN student_profiles sp ON a.stud_roll = sp.roll_no " + // LEFT JOIN for profiles
                         "LEFT JOIN fees f ON a.stud_roll = f.roll_no " + // LEFT JOIN for fees
                         "WHERE a.app_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, appId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                applicationDetails = new HashMap<>();
                applicationDetails.put("app_id", rs.getInt("app_id"));
                applicationDetails.put("stud_roll", rs.getString("stud_roll"));
                applicationDetails.put("applied_date", rs.getDate("applied_date"));
                applicationDetails.put("status", rs.getString("status"));
                applicationDetails.put("review_date", rs.getDate("review_date"));
                applicationDetails.put("remark", rs.getString("remark")); // Get remark from applications table
                
                // Student_auth details
                applicationDetails.put("fullname", rs.getString("fullname"));
                applicationDetails.put("email", rs.getString("email"));
                applicationDetails.put("mobile", rs.getString("mobile"));

                // Student_profiles details
                applicationDetails.put("gender", rs.getString("gender"));
                applicationDetails.put("dob", rs.getDate("dob"));
                applicationDetails.put("aadhar_no", rs.getString("aadhar_no"));
                applicationDetails.put("address", rs.getString("address"));
                applicationDetails.put("parents_mobile", rs.getString("parents_mobile"));
                applicationDetails.put("course", rs.getString("course"));
                applicationDetails.put("year", rs.getInt("year")); // Year is int
                applicationDetails.put("department", rs.getString("department")); // Changed from branch to department

                // Fees details
                applicationDetails.put("payment_status", rs.getString("payment_status"));
                applicationDetails.put("total_fees", rs.getDouble("total_fees"));
                applicationDetails.put("paid_fees", rs.getDouble("paid_fees"));

            } else {
                viewErrorMessage = "Application with ID " + appId + " not found.";
            }

        } catch (Exception e) {
            viewErrorMessage = "An error occurred while fetching application details: " + e.getMessage();
            e.printStackTrace();
        } finally {
            // Ensure all JDBC resources are closed
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Application - #<%= appId %></title>
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
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 2rem; padding: 2rem; }
        
        .detail-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }
        .detail-item {
            display: flex;
            flex-direction: column;
            padding: 0.75rem 0;
            border-bottom: 1px solid var(--border-color);
        }
        .detail-item:last-of-type { border-bottom: none; } /* Use last-of-type to handle grid layout */
        .detail-label {
            font-size: 0.85rem;
            color: var(--light-text-color);
            margin-bottom: 0.25rem;
            font-weight: 500;
        }
        .detail-value {
            font-size: 1rem;
            color: var(--primary-color);
            font-weight: 600;
        }
        .status-badge { padding: 0.3rem 0.8rem; border-radius: 1rem; font-size: 0.85rem; font-weight: 600; color: white; }
        .status-badge.Pending { background-color: var(--pending-color); }
        .status-badge.Approved { background-color: var(--approved-color); }
        .status-badge.Rejected { background-color: var(--rejected-color); }
        .status-badge.Paid { background-color: var(--approved-color); }
        .status-badge.Unpaid { background-color: var(--pending-color); }
        .status-badge.N\/A { background-color: var(--light-text-color); }
        
        .form-actions {
            margin-top: 2rem;
            display: flex;
            gap: 1rem;
            justify-content: flex-end; /* Align buttons to the right */
        }
        .form-actions .action-button {
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: background-color 0.2s ease, transform 0.2s ease;
            font-size: 1rem;
        }
        .form-actions .action-button:hover {
            transform: translateY(-2px);
        }
        .form-actions .action-button.back {
            background-color: var(--light-text-color);
            color: white;
            border: 1px solid var(--light-text-color);
        }
        .form-actions .action-button.back:hover {
            background-color: #4b5563;
        }
        .form-actions .action-button.approve {
            background-color: var(--approved-color);
            color: white;
            border: 1px solid var(--approved-color);
        }
        .form-actions .action-button.approve:hover {
            background-color: #0c8a66;
        }
        .form-actions .action-button.reject {
            background-color: var(--rejected-color);
            color: white;
            border: 1px solid var(--rejected-color);
        }
        .form-actions .action-button.reject:hover {
            background-color: #b91c1c;
        }
        
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
            .detail-grid { grid-template-columns: 1fr; }
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
        </ul>
    </aside>
    <main class="main-content">
        <div class="page-header">
            <h1>Application Details</h1>
            <% if (viewErrorMessage != null) { %>
                <div class="message-box error"><%= viewErrorMessage %></div>
                <div class="form-actions">
                    <a href="admin_applications.jsp" class="action-button back"><i class="fas fa-arrow-left"></i> Back to Applications</a>
                </div>
            <% } else if (applicationDetails != null) { %>
                <div class="card">
                    <h2>Application #<%= applicationDetails.get("app_id") %></h2>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Student Name</span>
                            <span class="detail-value"><%= applicationDetails.get("fullname") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Roll Number</span>
                            <span class="detail-value"><%= applicationDetails.get("stud_roll") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Applied On</span>
                            <span class="detail-value"><%= sdf.format((java.util.Date)applicationDetails.get("applied_date")) %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Application Status</span>
                            <span class="detail-value"><span class="status-badge <%= applicationDetails.get("status") %>"><%= applicationDetails.get("status") %></span></span>
                        </div>
                        
                        <%-- Conditionally display Review Date, Remark, Payment Status, and Fee details --%>
                        <% String appStatus = (String)applicationDetails.get("status"); %>
                        <% if (!"Pending".equals(appStatus)) { %>
                            <div class="detail-item">
                                <span class="detail-label">Review Date</span>
                                <span class="detail-value">
                                    <% if (applicationDetails.get("review_date") != null) { %>
                                        <%= sdf.format((java.util.Date)applicationDetails.get("review_date")) %>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Remark</span>
                                <span class="detail-value">
                                    <% if (applicationDetails.get("remark") != null && !((String)applicationDetails.get("remark")).isEmpty()) { %>
                                        <%= applicationDetails.get("remark") %>
                                    <% } else { %>
                                        N/A
                                    <% } %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Payment Status</span>
                                <span class="detail-value"><span class="status-badge <%= applicationDetails.get("payment_status") %>"><%= applicationDetails.get("payment_status") %></span></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Total Fees</span>
                                <span class="detail-value">?<%= String.format("%.2f", applicationDetails.get("total_fees")) %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Paid Fees</span>
                                <span class="detail-value">?<%= String.format("%.2f", applicationDetails.get("paid_fees")) %></span>
                            </div>
                        <% } %> <%-- End of conditional display for Review Date, Remark, Fees --%>
                    </div>

                    <h3 style="margin-top: 2rem; margin-bottom: 1rem; color: var(--primary-color);">Student Personal Details</h3>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Email</span>
                            <span class="detail-value"><%= applicationDetails.get("email") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Mobile (Student)</span>
                            <span class="detail-value"><%= applicationDetails.get("mobile") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Gender</span>
                            <span class="detail-value"><%= applicationDetails.get("gender") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Date of Birth</span>
                            <span class="detail-value">
                                <% if (applicationDetails.get("dob") != null) { %>
                                    <%= sdf.format((java.util.Date)applicationDetails.get("dob")) %>
                                <% } else { %>
                                    N/A
                                <% } %>
                            </span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Aadhar Number</span>
                            <span class="detail-value"><%= applicationDetails.get("aadhar_no") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Parent's Mobile</span>
                            <span class="detail-value"><%= applicationDetails.get("parents_mobile") %></span>
                        </div>
                        <div class="detail-item" style="grid-column: 1 / -1;">
                            <span class="detail-label">Address</span>
                            <span class="detail-value"><%= applicationDetails.get("address") %></span>
                        </div>
                    </div>

                    <h3 style="margin-top: 2rem; margin-bottom: 1rem; color: var(--primary-color);">Academic Details</h3>
                    <div class="detail-grid">
                        <div class="detail-item">
                            <span class="detail-label">Course</span>
                            <span class="detail-value"><%= applicationDetails.get("course") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Department</span>
                            <span class="detail-value"><%= applicationDetails.get("department") %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Year</span>
                            <span class="detail-value"><%= applicationDetails.get("year") %></span>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="admin_applications.jsp" class="action-button back"><i class="fas fa-arrow-left"></i> Back to Applications</a>
                        <% if ("Pending".equals(appStatus)) { %>
                            <a href="admin_applications.jsp?action=approve&app_id=<%= applicationDetails.get("app_id") %>" class="action-button approve" onclick="return confirm('Are you sure you want to approve this application and generate fee?');"><i class="fas fa-check-circle"></i> Approve</a>
                            <a href="admin_applications.jsp?action=reject&app_id=<%= applicationDetails.get("app_id") %>" class="action-button reject" onclick="return confirm('Are you sure you want to reject this application?');"><i class="fas fa-times-circle"></i> Reject</a>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
    </main>
</body>
</html>