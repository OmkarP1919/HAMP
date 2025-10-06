<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR VIEWING INDIVIDUAL STUDENT DETAILS
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }
    String adminName = (String) session.getAttribute("admin_name");

    // --- 2. INITIALIZE VARIABLES ---
    String studRoll = request.getParameter("stud_roll");
    Map<String, Object> studentDetails = new HashMap<>();
    String errorMessage = null;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Use the modern, recommended driver
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hamp", "root", "root");

        if (studRoll == null || studRoll.trim().isEmpty()) {
            errorMessage = "Student Roll Number is missing.";
        } else {
            // CORRECTED: Added ra.vacating_date to the SELECT statement
            String sql = "SELECT sa.roll_no, sa.fullname, sa.email, sa.mobile, " +
                         "sp.gender, sp.dob, sp.aadhar_no, sp.address, sp.parents_mobile, sp.course, sp.year, sp.department, " +
                         "a.app_id, a.applied_date, a.status AS application_status, a.review_date, " +
                         "f.total_fees, f.paid_fees, f.payment_status, f.payment_date, " +
                         "ra.room_no, ra.allocation_date " + 
                         "FROM student_auth sa " +
                         "LEFT JOIN student_profiles sp ON sa.roll_no = sp.roll_no " +
                         "LEFT JOIN applications a ON sa.roll_no = a.stud_roll " +
                         "LEFT JOIN fees f ON sa.roll_no = f.roll_no " +
                         "LEFT JOIN room_allocations ra ON sa.roll_no = ra.roll_no " +
                         "WHERE sa.roll_no = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studRoll);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // From student_auth
                studentDetails.put("roll_no", rs.getString("roll_no"));
                studentDetails.put("fullname", rs.getString("fullname"));
                studentDetails.put("email", rs.getString("email"));
                studentDetails.put("mobile_no", rs.getString("mobile"));

                // From student_profiles
                studentDetails.put("gender", rs.getString("gender"));
                studentDetails.put("dob", rs.getDate("dob"));
                studentDetails.put("aadhar_no", rs.getString("aadhar_no"));
                studentDetails.put("address", rs.getString("address"));
                studentDetails.put("parents_mobile", rs.getString("parents_mobile"));
                studentDetails.put("course", rs.getString("course"));
                studentDetails.put("year", rs.getObject("year"));
                studentDetails.put("department", rs.getString("department"));

                // Application Details
                studentDetails.put("app_id", rs.getObject("app_id"));
                studentDetails.put("applied_date", rs.getDate("applied_date"));
                studentDetails.put("application_status", rs.getString("application_status"));
                studentDetails.put("review_date", rs.getDate("review_date"));

                // Fee Details
                studentDetails.put("total_fees", rs.getObject("total_fees"));
                studentDetails.put("paid_fees", rs.getObject("paid_fees"));
                studentDetails.put("payment_status", rs.getString("payment_status"));
                studentDetails.put("payment_date", rs.getDate("payment_date"));

                // Room Allocation Details
                studentDetails.put("room_id", rs.getObject("room_no"));
                studentDetails.put("allocation_date", rs.getDate("allocation_date"));
                
                
            } else {
                errorMessage = "Student with Roll Number '" + studRoll + "' not found. Please verify the roll number and try again.";
            }
        }
    } catch (SQLException se) {
        errorMessage = "Database Error: " + se.getMessage() + ". Please check if the column names in the code match the database schema.";
        System.out.println("--- DEBUG: SQLException in view_student_details.jsp ---");
        se.printStackTrace();
        System.out.println("--- END DEBUG ---");
    } catch (Exception e) {
        errorMessage = "An unexpected error occurred: " + e.getMessage();
        System.out.println("--- DEBUG: Exception in view_student_details.jsp ---");
        e.printStackTrace();
        System.out.println("--- END DEBUG ---");
    } finally {
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
    <title>Student Details - <%= (studRoll != null) ? studRoll : "N/A" %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --success-color: #10b981; --success-bg: #f0fdf4; --success-border: #a7f3d0;
            --error-color: #ef4444; --error-bg: #fef2f2; --error-border: #fca5a5;
            --info-color: #3b82f6; --info-bg: #eff6ff; --info-border: #93c5fd; 
            --pending-color: #f59e0b; --pending-bg: #fffbeb; --pending-border: #fde68a;
            --button-secondary-bg: var(--light-text-color); --button-secondary-hover: #4b5563;
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
        .message-box.error { background-color: var(--error-bg); border: 1px solid var(--error-border); color: var(--error-color); }
        .card { 
            background-color: var(--card-bg); border: 1px solid var(--border-color); 
            border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); 
            margin-bottom: 2rem; padding: 2rem; 
            display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
        }
        .card h2 { 
            grid-column: 1 / -1; 
            font-size: 1.5rem; 
            color: var(--primary-color); 
            margin: 0 0 1.5rem 0; 
            padding-bottom: 1rem; 
            border-bottom: 1px solid var(--border-color); 
        }
        .detail-group { margin-bottom: 1rem; }
        .detail-group .detail-label { 
            font-size: 0.85rem; color: var(--light-text-color); 
            margin-bottom: 0.25rem; font-weight: 500; display: block; 
        }
        .detail-group .detail-value { 
            font-size: 1rem; color: var(--primary-color); font-weight: 600; 
            word-wrap: break-word; /* Ensure long values wrap */
        }
        .status-badge { 
            padding: 0.3rem 0.8rem; border-radius: 1rem; font-size: 0.85rem; 
            font-weight: 600; color: white; display: inline-block; 
            margin-top: 0.25rem;
        }
        .status-badge.Pending { background-color: var(--pending-color); }
        .status-badge.Approved { background-color: var(--success-color); }
        .status-badge.Rejected { background-color: var(--error-color); }
        .status-badge.Paid { background-color: var(--success-color); }
        .status-badge.Unpaid { background-color: var(--pending-color); }
        .status-badge.N\/A { background-color: var(--light-text-color); }

        .section-header { 
            grid-column: 1 / -1; 
            font-size: 1.25rem; 
            color: var(--primary-color); 
            margin: 1.5rem 0 1rem 0; 
            padding-bottom: 0.5rem; 
            border-bottom: 1px dashed var(--border-color); 
            font-weight: 700;
        }

        .action-buttons { 
            grid-column: 1 / -1; 
            display: flex; 
            gap: 1rem; 
            justify-content: flex-start; 
            margin-top: 2rem; 
            border-top: 1px solid var(--border-color); 
            padding-top: 1.5rem; 
        }
        .action-buttons .button {
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: background-color 0.2s ease, transform 0.2s ease;
            font-size: 1rem;
            border: none;
        }
        .action-buttons .button:hover { transform: translateY(-2px); }
        .action-buttons .button.secondary { background-color: var(--button-secondary-bg); color: white; }
        .action-buttons .button.secondary:hover { background-color: var(--button-secondary-hover); }

        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
            .card { grid-template-columns: 1fr; }
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
            <li><a href="admin_applications.jsp"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="admin_slist.jsp" class="active"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="page-header">
            <h1>Student Details</h1>
        </div>

        <% if (errorMessage != null) { %>
            <div class="message-box error">
                <%= errorMessage %>
            </div>
            <div class="action-buttons">
                 <% 
                     String referer = request.getHeader("referer");
                     String backLink = "admin_slist.jsp"; // Default back to student list
                     if (referer != null && referer.contains("admin_applications.jsp")) {
                         backLink = "admin_applications.jsp"; 
                     }
                 %>
                <a href="<%= backLink %>" class="button secondary"><i class="fas fa-arrow-left"></i> Back</a>
            </div>
        <% } else if (!studentDetails.isEmpty()) { %>
            <div class="card">
                <h2>Personal Information</h2>
                
                <div class="detail-group">
                    <span class="detail-label">Full Name</span>
                    <span class="detail-value"><%= studentDetails.get("fullname") %></span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Roll Number</span>
                    <span class="detail-value"><%= studentDetails.get("roll_no") %></span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Email</span>
                    <span class="detail-value"><%= studentDetails.get("email") %></span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Mobile Number</span>
                    <span class="detail-value"><%= studentDetails.get("mobile_no") %></span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Gender</span>
                    <span class="detail-value">
                        <% String gender = (String)studentDetails.get("gender"); %>
                        <%= (gender != null) ? gender : "N/A" %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Date of Birth</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("dob") != null) { %>
                            <%= sdf.format((java.util.Date)studentDetails.get("dob")) %>
                        <% } else { %>
                            N/A
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Aadhar No.</span>
                    <span class="detail-value">
                        <% String aadhar = (String)studentDetails.get("aadhar_no"); %>
                        <%= (aadhar != null) ? aadhar : "N/A" %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Address</span>
                    <span class="detail-value">
                        <% String address = (String)studentDetails.get("address"); %>
                        <%= (address != null) ? address : "N/A" %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Parents Mobile</span>
                    <span class="detail-value">
                        <% String parentsMobile = (String)studentDetails.get("parents_mobile"); %>
                        <%= (parentsMobile != null) ? parentsMobile : "N/A" %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Course</span>
                    <span class="detail-value">
                        <% String course = (String)studentDetails.get("course"); %>
                        <%= (course != null) ? course : "N/A" %>
                    </span>
                </div>
                 <div class="detail-group">
                    <span class="detail-label">Year</span>
                    <span class="detail-value">
                        <% Object yearObj = studentDetails.get("year"); %>
                        <%= (yearObj != null) ? yearObj.toString() : "N/A" %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Department</span>
                    <span class="detail-value">
                        <% String department = (String)studentDetails.get("department"); %>
                        <%= (department != null) ? department : "N/A" %>
                    </span>
                </div>

                <h3 class="section-header">Application Details</h3>
                <div class="detail-group">
                    <span class="detail-label">Application ID</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("app_id") != null) { %>
                            <%= studentDetails.get("app_id") %>
                        <% } else { %>
                            No Application
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Applied On</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("applied_date") != null) { %>
                            <%= sdf.format((java.util.Date)studentDetails.get("applied_date")) %>
                        <% } else { %>
                            N/A
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Application Status</span>
                    <span class="detail-value">
                        <% String appStatus = (String)studentDetails.get("application_status"); %>
                        <% if (appStatus != null) { %>
                            <span class="status-badge <%= appStatus %>"><%= appStatus %></span>
                        <% } else { %>
                            <span class="status-badge N/A">N/A</span>
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Review Date</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("review_date") != null) { %>
                            <%= sdf.format((java.util.Date)studentDetails.get("review_date")) %>
                        <% } else { %>
                            N/A
                        <% } %>
                    </span>
                </div>

                <h3 class="section-header">Fee Details</h3>
                <div class="detail-group">
                    <span class="detail-label">Total Fees</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("total_fees") != null) { %>
                            Rs. <%= String.format("%.2f", Double.parseDouble(studentDetails.get("total_fees").toString())) %>
                        <% } else { %>
                            N/A
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Paid Fees</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("paid_fees") != null) { %>
                             Rs. <%= String.format("%.2f", Double.parseDouble(studentDetails.get("paid_fees").toString())) %>
                        <% } else { %>
                            N/A
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Payment Status</span>
                    <span class="detail-value">
                        <% String paymentStatus = (String)studentDetails.get("payment_status"); %>
                        <% if (paymentStatus != null) { %>
                            <span class="status-badge <%= paymentStatus %>"><%= paymentStatus %></span>
                        <% } else { %>
                            <span class="status-badge N/A">N/A</span>
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Payment Date</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("payment_date") != null) { %>
                            <%= sdf.format((java.util.Date)studentDetails.get("payment_date")) %>
                        <% } else { %>
                            N/A
                        <% } %>
                    </span>
                </div>

                <h3 class="section-header">Room Allocation Details</h3>
                <div class="detail-group">
                    <span class="detail-label">Room Number</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("room_id") != null) { %>
                            <%= studentDetails.get("room_id") %>
                        <% } else { %>
                            Not Allocated
                        <% } %>
                    </span>
                </div>
                <div class="detail-group">
                    <span class="detail-label">Allocation Date</span>
                    <span class="detail-value">
                        <% if (studentDetails.get("allocation_date") != null) { %>
                            <%= sdf.format((java.util.Date)studentDetails.get("allocation_date")) %>
                        <% } else { %>
                            N/A
                        <% } %>
                    </span>
                </div>

                <div class="action-buttons">
                    <% 
                        String referer = request.getHeader("referer");
                        String backLink = "admin_slist.jsp"; // Default back to student list
                        if (referer != null && referer.contains("admin_applications.jsp")) {
                            backLink = "admin_applications.jsp"; // If coming from applications, go back there
                        } else if (referer != null && referer.contains("admin_allocate_room.jsp")) {
                            backLink = "admin_allocate_room.jsp?stud_roll=" + studRoll; // If coming from allocate, go back to that page
                        }
                    %>
                    <a href="<%= backLink %>" class="button secondary"><i class="fas fa-arrow-left"></i> Back</a>
                </div>
            </div>
        <% } %>
    </main>
</body>
</html>