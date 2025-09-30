<%@ page import="java.sql.*, java.util.*" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR STUDENT PROFILE PAGE
     Handles both displaying (GET) and saving (POST) data.
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("user_roll_no") == null) {
        response.sendRedirect("user_login.jsp?error=Please login first");
        return;
    }
    String userRollNo = (String) session.getAttribute("user_roll_no");

    // --- 2. INITIALIZE VARIABLES & DATA STRUCTURES ---
    String successMessage = null;
    String errorMessage = null;
    
    // Define the relationship between courses and departments
    Map<String, String[]> courseDepartments = new LinkedHashMap<>();
    courseDepartments.put("B.Tech", new String[]{"Computer Science", "Information Technology", "Mechanical Engineering", "Civil Engineering", "Electrical Engineering"});
    courseDepartments.put("M.Tech", new String[]{"Advanced Computing", "Structural Engineering", "Thermal Engineering"});
    courseDepartments.put("BCA", new String[]{"Computer Applications"});
    courseDepartments.put("MCA", new String[]{"Computer Applications"});

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
        
        // --- 3. HANDLE FORM SUBMISSION (POST REQUEST) ---
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            // Get all form parameters
            String gender = request.getParameter("gender");
            String dob = request.getParameter("dob");
            String aadhar = request.getParameter("aadhar_no");
            String parentMobile = request.getParameter("parents_mobile");
            String course = request.getParameter("course");
            String department = request.getParameter("department");
            int year = Integer.parseInt(request.getParameter("year"));
            String address = request.getParameter("address");

            // Check if a profile already exists
            pstmt = conn.prepareStatement("SELECT COUNT(*) FROM student_profiles WHERE roll_no = ?");
            pstmt.setString(1, userRollNo);
            rs = pstmt.executeQuery();
            boolean profileExists = rs.next() && rs.getInt(1) > 0;
            rs.close();
            pstmt.close();

            String sql;
            if (profileExists) {
                // UPDATE existing profile
                sql = "UPDATE student_profiles SET gender=?, dob=?, aadhar_no=?, address=?, parents_mobile=?, course=?, year=?, department=? WHERE roll_no=?";
            } else {
                // INSERT new profile
                sql = "INSERT INTO student_profiles (gender, dob, aadhar_no, address, parents_mobile, course, year, department, roll_no) VALUES (?,?,?,?,?,?,?,?,?)";
            }

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, gender);
            pstmt.setString(2, dob);
            pstmt.setString(3, aadhar);
            pstmt.setString(4, address);
            pstmt.setString(5, parentMobile);
            pstmt.setString(6, course);
            pstmt.setInt(7, year);
            pstmt.setString(8, department);
            pstmt.setString(9, userRollNo);

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                // Redirect with a success status to show the message
                response.sendRedirect("user_profile.jsp?status=success");
                return;
            } else {
                errorMessage = "Failed to update profile. Please try again.";
            }
        }

        // --- Check for success message from redirect ---
        if ("success".equals(request.getParameter("status"))) {
            successMessage = "Profile updated successfully!";
        }

    } catch (Exception e) {
        errorMessage = "An error occurred: " + e.getMessage();
        e.printStackTrace();
    } 

    // --- 4. FETCH DATA FOR DISPLAY (GET REQUEST) ---
    // This part runs for both GET and POST (to refresh data after potential errors)
    String fullName = "";
    String email = "";
    String mobile = "";
    HashMap<String, Object> profileData = new HashMap<>();

    try {
        if(conn == null || conn.isClosed()) {
            // Re-establish connection if it was closed or failed
            String url = "jdbc:mysql://localhost:3306/hamp";
            String dbUsername = "root"; String dbPassword = "root";
            String driver = "com.mysql.cj.jdbc.Driver";
            Class.forName(driver);
            conn = DriverManager.getConnection(url, dbUsername, dbPassword);
        }

        pstmt = conn.prepareStatement("SELECT fullname, email, mobile FROM student_auth WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            fullName = rs.getString("fullname");
            email = rs.getString("email");
            mobile = rs.getString("mobile");
        }
        rs.close(); pstmt.close();

        pstmt = conn.prepareStatement("SELECT * FROM student_profiles WHERE roll_no = ?");
        pstmt.setString(1, userRollNo);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            profileData.put("gender", rs.getString("gender"));
            profileData.put("dob", rs.getDate("dob"));
            profileData.put("aadhar_no", rs.getString("aadhar_no"));
            profileData.put("parents_mobile", rs.getString("parents_mobile"));
            profileData.put("course", rs.getString("course"));
            profileData.put("department", rs.getString("department"));
            profileData.put("year", rs.getInt("year"));
            profileData.put("address", rs.getString("address"));
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
    <title>Student Profile</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --success-color: #10b981; --danger-color: #ef4444;
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
        .profile-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; }
        .profile-header h1 { margin: 0; font-size: 2rem; }
        .message-box { padding: 1rem; margin-bottom: 1.5rem; border-radius: 8px; font-weight: 500; }
        .message-box.success { background-color: #f0fdf4; border: 1px solid var(--success-color); color: #15803d; }
        .message-box.error { background-color: #fef2f2; border: 1px solid var(--danger-color); color: #b91c1c; }
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 2rem; }
        .card-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-color); }
        .card-header h2 { margin: 0; font-size: 1.2rem; font-weight: 600; }
        .card-body { padding: 1.5rem; }
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-weight: 500; margin-bottom: 0.5rem; font-size: 0.9rem; }
        .form-group input, .form-group select, .form-group textarea { padding: 0.8rem 1rem; border: 1px solid var(--border-color); border-radius: 6px; font-size: 1rem; font-family: 'Inter', sans-serif; transition: border-color 0.2s, box-shadow 0.2s; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline: none; border-color: var(--accent-color); box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.2); }
        .form-group input[readonly] { background-color: var(--secondary-color); cursor: not-allowed; }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .full-width { grid-column: 1 / -1; }
        .card-footer { padding: 1.25rem 1.5rem; border-top: 1px solid var(--border-color); background-color: var(--secondary-color); text-align: right; border-bottom-left-radius: 12px; border-bottom-right-radius: 12px; }
        .button { padding: 0.75rem 1.5rem; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: background-color 0.3s ease; }
        .button-primary { background-color: var(--accent-color); color: white; }
        .button-primary:hover { background-color: #1d4ed8; }
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
            <li><a href="user_profile.jsp" class="active"><i class="fas fa-user-circle"></i> Profile</a></li>
            <li><a href="user_downloads.jsp"><i class="fas fa-download"></i> Downloads</a></li>
            <li><a href="user_payfees.jsp"><i class="fas fa-file-invoice-dollar"></i> Payments</a></li>
            <li><a href="user_status.jsp"><i class="fas fa-check-circle"></i> Status</a></li>
        </ul>
    </aside>

    <main class="main-content">
        <form action="user_profile.jsp" method="POST">
            <div class="profile-header"><h1>My Profile</h1></div>
            
            <%-- Display success or error messages --%>
            <% if (successMessage != null) { %>
                <div class="message-box success"><%= successMessage %></div>
            <% } else if (errorMessage != null) { %>
                <div class="message-box error"><%= errorMessage %></div>
            <% } %>

            <div class="card">
                <div class="card-header"><h2>Account Details</h2></div>
                <div class="card-body">
                    <div class="form-grid">
                        <div class="form-group"><label for="fullname">Full Name</label><input type="text" id="fullname" name="fullname" value="<%= fullName %>" readonly></div>
                        <div class="form-group"><label for="roll_no">Roll Number</label><input type="text" id="roll_no" name="roll_no" value="<%= userRollNo %>" readonly></div>
                        <div class="form-group"><label for="email">Email Address</label><input type="email" id="email" name="email" value="<%= email %>" readonly></div>
                        <div class="form-group"><label for="mobile">Mobile Number</label><input type="tel" id="mobile" name="mobile" value="<%= mobile %>" readonly></div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header"><h2>Personal & Academic Information</h2></div>
                <div class="card-body">
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="gender">Gender</label>
                            <select id="gender" name="gender" required>
                                <option value="" disabled <%= profileData.isEmpty() ? "selected" : "" %>>Select Gender</option>
                                <option value="Male" <%= "Male".equals(profileData.get("gender")) ? "selected" : "" %>>Male</option>
                                <option value="Female" <%= "Female".equals(profileData.get("gender")) ? "selected" : "" %>>Female</option>
                                <option value="Other" <%= "Other".equals(profileData.get("gender")) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="dob">Date of Birth</label>
                            <input type="date" id="dob" name="dob" value="<%= profileData.get("dob") != null ? profileData.get("dob").toString() : "" %>" required>
                        </div>
                        <div class="form-group">
                            <label for="aadhar_no">Aadhar Number</label>
                            <input type="text" id="aadhar_no" name="aadhar_no" value="<%= profileData.get("aadhar_no") != null ? profileData.get("aadhar_no") : "" %>" pattern="\d{12}" title="12-digit Aadhar number" required>
                        </div>
                        <div class="form-group">
                            <label for="parents_mobile">Parent's Mobile Number</label>
                            <input type="tel" id="parents_mobile" name="parents_mobile" value="<%= profileData.get("parents_mobile") != null ? profileData.get("parents_mobile") : "" %>" pattern="\d{10}" title="10-digit mobile number" required>
                        </div>
                        <div class="form-group">
                            <label for="course">Course</label>
                            <select id="course" name="course" required onchange="updateDepartments()">
                                <option value="" disabled <%= profileData.get("course") == null ? "selected" : "" %>>Select Course</option>
                                <% for (String course : courseDepartments.keySet()) { %>
                                    <option value="<%= course %>" <%= course.equals(profileData.get("course")) ? "selected" : "" %>><%= course %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="department">Department</label>
                            <select id="department" name="department" required>
                                <option value="" disabled selected>Select a course first</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="year">Year of Study</label>
                            <select id="year" name="year" required>
                                <option value="" disabled <%= profileData.get("year") == null ? "selected" : "" %>>Select Year</option>
                                <option value="1" <%= Integer.valueOf(1).equals(profileData.get("year")) ? "selected" : "" %>>First Year</option>
                                <option value="2" <%= Integer.valueOf(2).equals(profileData.get("year")) ? "selected" : "" %>>Second Year</option>
                                <option value="3" <%= Integer.valueOf(3).equals(profileData.get("year")) ? "selected" : "" %>>Third Year</option>
                                <option value="4" <%= Integer.valueOf(4).equals(profileData.get("year")) ? "selected" : "" %>>Fourth Year</option>
                            </select>
                        </div>
                        <div class="form-group full-width">
                            <label for="address">Full Address</label>
                            <textarea id="address" name="address" placeholder="Enter your complete permanent address" required><%= profileData.get("address") != null ? profileData.get("address") : "" %></textarea>
                        </div>
                    </div>
                </div>
                <div class="card-footer">
                    <button type="submit" class="button button-primary">Save Changes</button>
                </div>
            </div>
        </form>
    </main>

<script>
    // This script handles the cascading dropdowns for Course and Department.
    (function() {
        // 1. Data passed from JSP to JavaScript
        const departmentsByCourse = {
        <%
            boolean firstCourse = true;
            for (Map.Entry<String, String[]> entry : courseDepartments.entrySet()) {
                if (!firstCourse) out.print(",");
                out.print("\"" + entry.getKey() + "\":[");
                boolean firstDept = true;
                for (String dept : entry.getValue()) {
                    if (!firstDept) out.print(",");
                    out.print("\"" + dept + "\"");
                    firstDept = false;
                }
                out.print("]");
                firstCourse = false;
            }
        %>
        };

        const savedDepartment = "<%= profileData.get("department") != null ? profileData.get("department") : "" %>";

        // 2. Get references to the dropdowns
        const courseSelect = document.getElementById('course');
        const departmentSelect = document.getElementById('department');

        // 3. Define the function to update the Department dropdown
        window.updateDepartments = function() {
            const selectedCourse = courseSelect.value;
            const departments = departmentsByCourse[selectedCourse] || [];

            // Clear existing options
            departmentSelect.innerHTML = '';

            if (departments.length === 0) {
                const defaultOption = new Option('Select a course first', '');
                defaultOption.disabled = true;
                departmentSelect.add(defaultOption);
                return;
            }
            
            // Add a default placeholder option
            const placeholderOption = new Option('Select Department', '');
            placeholderOption.disabled = true;
            placeholderOption.selected = true;
            departmentSelect.add(placeholderOption);

            // Populate with new options
            departments.forEach(dept => {
                const option = new Option(dept, dept);
                if (dept === savedDepartment) {
                    option.selected = true;
                }
                departmentSelect.add(option);
            });
        };

        // 4. Run the function once on page load to set the initial state
        document.addEventListener('DOMContentLoaded', updateDepartments);
    })();
</script>

</body>
</html>