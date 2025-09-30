<%@ page import="java.sql.*, java.util.ArrayList, java.util.HashMap" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR STUDENT APPLICATION PAGE
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("user_roll_no") == null) {
        response.sendRedirect("user_login.jsp?error=Please login first");
        return;
    }
    String userRollNo = (String) session.getAttribute("user_roll_no");

    // --- 2. INITIALIZE VARIABLES ---
    String studentFullName = "";
    String studentEmail = "";
    String studentDepartment = "";
    String studentCourse = "";
    String studentGender = "";
    
    boolean isProfileComplete = false;
    int completionPercentage = 33;
    String applicationStatus = null;
    ArrayList<HashMap<String, String>> eligibleHostels = new ArrayList<>();

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
        
        // --- HANDLE FORM SUBMISSION (POST REQUEST) ---
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String insertSql = "INSERT INTO applications (stud_roll, applied_date, status) VALUES (?, CURDATE(), 'Pending')";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, userRollNo);
            pstmt.executeUpdate();
            pstmt.close();
        }

        // --- FETCH DATA FOR PAGE DISPLAY (runs for both GET and after POST) ---
        pstmt = conn.prepareStatement("SELECT COUNT(*) FROM student_profiles WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next() && rs.getInt(1) > 0) {
            isProfileComplete = true;
            completionPercentage = 100;
        }
        rs.close(); pstmt.close();

        pstmt = conn.prepareStatement("SELECT fullname FROM student_auth WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if(rs.next()) { studentFullName = rs.getString("fullname"); }
        rs.close(); pstmt.close();

        if (isProfileComplete) {
            pstmt = conn.prepareStatement("SELECT status FROM applications WHERE stud_roll = ? AND (status = 'Pending' OR status = 'Approved')");
            pstmt.setString(1, userRollNo);
            rs = pstmt.executeQuery();
            if (rs.next()) { applicationStatus = rs.getString("status"); }
            rs.close(); pstmt.close();

            if (applicationStatus == null) {
                String profileSql = "SELECT sa.email, sp.department, sp.course, sp.gender FROM student_auth sa JOIN student_profiles sp ON sa.roll_no = sp.roll_no WHERE sa.roll_no = ?";
                pstmt = conn.prepareStatement(profileSql);
                pstmt.setString(1, userRollNo);
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    studentEmail = rs.getString("email");
                    studentDepartment = rs.getString("department");
                    studentCourse = rs.getString("course");
                    studentGender = rs.getString("gender");
                }
                rs.close(); pstmt.close();

                if (studentGender != null && !studentGender.isEmpty() && studentCourse != null && !studentCourse.isEmpty()) {
                    String targetGender = "Male".equalsIgnoreCase(studentGender) ? "Boys" : "Girls";
                    String hostelSql = "SELECT hostel_id, hostel_name, gender_eligibility FROM hostels WHERE gender_eligibility = ? AND FIND_IN_SET(?, course_eligibility)";
                    pstmt = conn.prepareStatement(hostelSql);
                    pstmt.setString(1, targetGender);
                    pstmt.setString(2, studentCourse);
                    rs = pstmt.executeQuery();
                    
                    while (rs.next()) {
                        HashMap<String, String> hostel = new HashMap<>();
                        hostel.put("id", rs.getString("hostel_id"));
                        hostel.put("name", rs.getString("hostel_name"));
                        hostel.put("type", rs.getString("gender_eligibility"));
                        eligibleHostels.add(hostel);
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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Hostel Application</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --success-color: #10b981; --info-color: #3b82f6; --warning-color: #f59e0b;
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
        .main-content { grid-area: main; padding: 2.5rem; overflow-y: auto; display: flex; justify-content: center; }
        .apply-container { width: 100%; max-width: 800px; }
        .page-header h1 { font-size: 2rem; font-weight: 800; margin: 0 0 0.5rem 0; }
        .page-header p { font-size: 1.1rem; color: var(--light-text-color); margin-bottom: 1.5rem; }
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 1.5rem; }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 2rem 1.5rem; }
        .details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; }
        .detail-item .label { font-size: 0.9rem; color: var(--light-text-color); font-weight: 500; margin-bottom: 0.25rem; }
        .detail-item .value { font-size: 1rem; font-weight: 600; padding: 0.75rem 1rem; background-color: var(--secondary-color); border-radius: 6px; border: 1px solid var(--border-color); }
        .selection-group { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }
        .selection-group input[type="radio"] { display: none; }
        .selection-card { display: flex; align-items: center; padding: 1.5rem; border: 2px solid var(--border-color); border-radius: 8px; cursor: pointer; transition: all 0.2s ease-in-out; gap: 1rem; }
        .selection-card:hover { border-color: var(--accent-color); }
        .selection-card i { font-size: 2rem; color: var(--accent-color); }
        .selection-card .name { font-weight: 600; font-size: 1.1rem; }
        .selection-card .type { font-size: 0.9rem; color: var(--light-text-color); }
        .selection-group input[type="radio"]:checked + .selection-card { border-color: var(--accent-color); background-color: #eff6ff; box-shadow: 0 0 0 2px var(--accent-color); }
        .declaration { display: flex; align-items: flex-start; gap: 0.75rem; }
        .declaration input[type="checkbox"] { margin-top: 5px; width: 1.2em; height: 1.2em; }
        .declaration label { font-size: 1rem; line-height: 1.6; color: var(--light-text-color); }
        .declaration label a { color: var(--accent-color); font-weight: 600; text-decoration: none; }
        .button, .button-submit { width: 100%; text-align: center; display: inline-block; text-decoration: none; padding: 1rem; border: none; border-radius: 8px; background-color: var(--accent-color); color: white; font-size: 1.1rem; font-weight: 700; cursor: pointer; transition: all 0.2s ease; }
        .button:hover, .button-submit:hover:not(:disabled) { background-color: #1d4ed8; }
        .button-submit:disabled { background-color: #9ca3af; cursor: not-allowed; }
        .status-message { padding: 1.5rem; margin-bottom: 2rem; border-radius: 8px; display: flex; align-items: center; gap: 1rem; }
        .status-message.pending { background-color: #fefce8; border: 1px solid var(--warning-color); color: #ca8a04; }
        .status-message.approved, .status-message.submitted { background-color: #f0fdf4; border: 1px solid var(--success-color); color: #16a34a; } /* Modified */
        .status-message .icon { font-size: 1.5rem; }
        .status-message .text { font-weight: 500; line-height: 1.6; } /* Modified */
        .status-message .text a { color: #15803d; font-weight: 700; text-decoration: none; } /* Modified */
        .status-message .text a:hover { text-decoration: underline; } /* Modified */
        .completion-bar-container { margin-bottom: 2.5rem; }
        .completion-bar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; }
        .completion-bar-header .title { font-weight: 600; }
        .completion-bar-header .percent { font-weight: 700; color: var(--accent-color); }
        .progress-bar { background-color: var(--border-color); height: 10px; border-radius: 5px; overflow: hidden; }
        .progress-bar-inner { height: 100%; background-color: var(--accent-color); border-radius: 5px; transition: width 0.5s ease-in-out; }
        @media (max-width: 992px) {
            body { grid-template-columns: 1fr; grid-template-rows: auto auto 1fr; grid-template-areas: "header" "sidebar" "main"; }
            .side-panel { border-right: none; border-bottom: 1px solid var(--border-color); }
        }
    </style>
</head>
<body>
    <header class="top-panel">
        <div class="logo-title"><h1>Hostel Mate</h1></div>
        <div class="user-menu"><span class="user-info"><i class="fas fa-user-circle"></i> Welcome, <%= studentFullName %></span><a href="user_login.jsp" class="logout-btn"><i class="fas fa-sign-out-alt"></i> Logout</a></div>
    </header>
    <aside class="side-panel">
        <h2>Student Menu</h2>
        <ul class="side-panel-nav">
            <li><a href="user_dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="user_apply.jsp" class="active"><i class="fas fa-file-alt"></i> Apply</a></li>
            <li><a href="user_profile.jsp"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="user_downloads.jsp"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="apply-container">
            <div class="page-header">
                <h1>New Hostel Application</h1>
                <p>Check your profile status and follow the steps to apply.</p>
            </div>
            <div class="completion-bar-container">
                <div class="completion-bar-header">
                    <span class="title">Profile Completion</span>
                    <span class="percent"><%= completionPercentage %>%</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-bar-inner" style="width: <%= completionPercentage %>%;"></div>
                </div>
            </div>

            <% if (!isProfileComplete) { %>
                <div class="card">
                    <div class="card-header"><h2>Action Required</h2></div>
                    <div class="card-body" style="text-align: center;">
                        <p style="font-size: 1.1rem; color: var(--light-text-color); margin-top:0; margin-bottom: 2rem;">Your profile is incomplete. Please complete your profile before you can apply for a hostel.</p>
                        <a href="user_profile.jsp" class="button">Complete Profile Now</a>
                    </div>
                </div>
            <% } else { %>
                <% if (applicationStatus != null) { %>
                    <div class="status-message <%= "Approved".equals(applicationStatus) ? "approved" : "submitted" %>">
                        <div class="icon"><i class="fas fa-check-circle"></i></div>
                        <div class="text">
                            Your application has been submitted successfully.
                            <br>
                            You can <a href="user_status.jsp">check your application status here</a>.
                        </div>
                    </div>
                <% } else { %>
                    <form action="user_apply.jsp" method="POST">
                        <div class="card">
                            <div class="card-header"><h2>Step 1: Verify Your Details</h2></div>
                            <div class="card-body">
                                <div class="details-grid">
                                    <div class="detail-item"><div class="label">Full Name</div><div class="value"><%= studentFullName %></div></div>
                                    <div class="detail-item"><div class="label">Roll Number</div><div class="value"><%= userRollNo %></div></div>
                                    <div class="detail-item"><div class="label">Email Address</div><div class="value"><%= studentEmail %></div></div>
                                    <div class="detail-item"><div class="label">Department</div><div class="value"><%= studentDepartment %></div></div>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header"><h2>Step 2: Select Your Hostel</h2></div>
                            <div class="card-body">
                                <div class="selection-group">
                                    <% if (eligibleHostels.isEmpty()) { %>
                                        <p>Sorry, no hostels are available matching your profile (Course: <%= studentCourse %>, Gender: <%= studentGender %>).</p>
                                    <% } else { %>
                                        <% for (HashMap<String, String> hostel : eligibleHostels) { %>
                                            <input type="radio" id="hostel<%= hostel.get("id") %>" name="hostel_choice" value="<%= hostel.get("id") %>" required <%= eligibleHostels.size() == 1 ? "checked" : "" %>>
                                            <label for="hostel<%= hostel.get("id") %>" class="selection-card">
                                                <i class="fas <%= "Boys".equals(hostel.get("type")) ? "fa-male" : "fa-female" %>"></i>
                                                <div>
                                                    <div class="name"><%= hostel.get("name") %></div>
                                                    <div class="type"><%= hostel.get("type") %> Hostel</div>
                                                </div>
                                            </label>
                                        <% } %>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <div class="card">
                            <div class="card-header"><h2>Step 3: Declaration</h2></div>
                            <div class="card-body">
                                <div class="declaration">
                                    <input type="checkbox" id="terms" name="terms" required onchange="document.getElementById('submitBtn').disabled = !this.checked;">
                                    <label for="terms">I have read and agree to the <a href="downloads/Hostel-Rulebook.pdf" target="_blank">Hostel Rules and Regulations</a> and confirm that the details provided are correct.</label>
                                </div>
                            </div>
                        </div>
                        <button type="submit" id="submitBtn" class="button-submit" style="margin-top: 1.5rem;" disabled>Submit Application</button>
                    </form>
                <% } %>
            <% } %>
        </div>
    </main>
</body>
</html>