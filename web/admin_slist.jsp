<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR ADMIN STUDENT LIST PAGE
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }
    String adminName = (String) session.getAttribute("admin_name");

    // --- 2. INITIALIZE VARIABLES ---
    List<HashMap<String, String>> studentList = new ArrayList<>();

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

        // --- 3B. FETCH ALL ALLOCATED STUDENTS FOR DISPLAY ---
        // This query joins 5 tables to get all required information
        String sql = "SELECT " +
                     "sa.roll_no, sa.fullname, sp.course, sp.year, h.hostel_name, ra.room_no " +
                     "FROM room_allocations ra " +
                     "JOIN student_auth sa ON ra.roll_no = sa.roll_no " +
                     "JOIN student_profiles sp ON ra.roll_no = sp.roll_no " +
                     "JOIN room r ON ra.room_no = r.room_no " +
                     "JOIN hostels h ON r.hostel_id = h.hostel_id " +
                     "ORDER BY h.hostel_name, ra.room_no, sa.fullname";
                     
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            HashMap<String, String> student = new HashMap<>();
            student.put("roll_no", rs.getString("roll_no"));
            student.put("fullname", rs.getString("fullname"));
            student.put("course", rs.getString("course"));
            student.put("year", rs.getString("year"));
            student.put("hostel_name", rs.getString("hostel_name"));
            student.put("room_no", rs.getString("room_no"));
            studentList.add(student);
        }

    } catch (Exception e) {
        // You can add more robust error handling here
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
    <title>Student Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
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
        .page-header h1 { font-size: 2rem; font-weight: 800; margin: 0 0 2.5rem 0; }
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
        .filter-bar { padding: 1.5rem; display: flex; flex-wrap: wrap; gap: 1rem; align-items: center; border-bottom: 1px solid var(--border-color); }
        .search-group { flex-grow: 1; position: relative; }
        .search-group i { position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); color: var(--light-text-color); }
        .search-group input, .filter-group select { padding: 0.75rem; border-radius: 8px; border: 1px solid var(--border-color); font-size: 1rem; font-family: 'Inter', sans-serif; }
        .search-group input { padding-left: 2.75rem; width: 100%; }
        .filter-group select { min-width: 150px; }
        .button-filter { padding: 0.75rem 1.5rem; border: none; border-radius: 8px; background-color: var(--accent-color); color: white; font-size: 1rem; font-weight: 600; cursor: pointer; transition: background-color 0.2s ease; }
        .table-container { width: 100%; overflow-x: auto; }
        .student-table { width: 100%; border-collapse: collapse; }
        .student-table th, .student-table td { padding: 1.25rem 1.5rem; text-align: left; border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        .student-table thead { background-color: var(--secondary-color); }
        .student-table th { font-size: 0.85rem; font-weight: 600; text-transform: uppercase; color: var(--light-text-color); }
        .student-table tbody tr:hover { background-color: var(--secondary-color); }
        .button-action { padding: 0.5rem 1rem; border-radius: 6px; font-weight: 500; text-decoration: none; background-color: var(--card-bg); border: 1px solid var(--border-color); color: var(--primary-color); cursor: pointer; transition: all 0.2s ease; }
        .button-action:hover { background-color: var(--secondary-color); border-color: #d1d5db; }
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
            <li><a href="admin_applications.jsp"><i class="fas fa-file-signature"></i> Applications</a></li>
            <li><a href="admin_slist.jsp" class="active"><i class="fas fa-users"></i> Students</a></li>
            <li><a href="admin_rooms.jsp"><i class="fas fa-bed"></i> Rooms</a></li>
        </ul>
    </aside>
    <main class="main-content">
        <div class="page-header">
            <h1>Student Management</h1>
        </div>

        <div class="card">
            <div class="filter-bar">
                <div class="search-group">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Search by name or roll no...">
                </div>
                <div class="filter-group">
                    <select><option value="">All Hostels</option><option value="BH1">Vivekananda Boys Hostel</option><option value="GH1">Savitribai Phule Girls Hostel</option></select>
                </div>
                <div class="filter-group">
                    <select><option value="">All Courses</option><option value="BTech">BTech</option><option value="MTech">MTech</option></select>
                </div>
                <div class="filter-group">
                    <select><option value="">All Years</option><option value="1">First Year</option><option value="2">Second Year</option></select>
                </div>
                <button class="button-filter">Filter</button>
            </div>
            <div class="table-container">
                <table class="student-table">
                    <thead>
                        <tr>
                            <th>Roll No</th>
                            <th>Full Name</th>
                            <th>Course & Year</th>
                            <th>Hostel</th>
                            <th>Room No</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (studentList.isEmpty()) { %>
                            <tr>
                                <td colspan="6" style="text-align: center; color: var(--light-text-color); padding: 2rem;">No students with room allocations found.</td>
                            </tr>
                        <% } else {
                            for (HashMap<String, String> student : studentList) {
                        %>
                            <tr>
                                <td><%= student.get("roll_no") %></td>
                                <td><%= student.get("fullname") %></td>
                                <td><%= student.get("course") %>, Year <%= student.get("year") %></td>
                                <td><%= student.get("hostel_name") %></td>
                                <td><%= student.get("room_no") %></td>
                                <td><a href="view_student_details.jsp?roll_no=<%= student.get("roll_no") %>" class="button-action">View Details</a></td>
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