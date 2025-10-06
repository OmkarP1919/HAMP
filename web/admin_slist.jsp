<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%-- =================================================================
     SERVER-SIDE LOGIC FOR STUDENT LIST (ALLOCATED STUDENTS ONLY)
     ================================================================= --%>
<%
    // --- 1. SESSION SECURITY CHECK ---
    if (session.getAttribute("admin_id") == null) {
        response.sendRedirect("admin_login.jsp?error=Please login first");
        return;
    }
    String adminName = (String) session.getAttribute("admin_name");

    // --- 2. INITIALIZE VARIABLES ---
    List<HashMap<String, String>> allocatedStudents = new ArrayList<>();
    String errorMessage = null;

    // --- 3. DATABASE OPERATIONS ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String url = "jdbc:mysql://localhost:3306/hamp";
        String dbUsername = "root";
        String dbPassword = "root";
        // Corrected to the modern driver for MySQL Connector/J 8.0+
        String driver = "com.mysql.jdbc.Driver"; 
        Class.forName(driver);
        conn = DriverManager.getConnection(url, dbUsername, dbPassword);

        // Fetch ONLY students who have a room allocation
        String sql = "SELECT sa.roll_no, sa.fullname, sa.email, sa.mobile, " +
                     "       ra.room_no, ra.allocation_date " +
                     "FROM student_auth sa " +
                     "JOIN room_allocations ra ON sa.roll_no = ra.roll_no " + // INNER JOIN to only get allocated students
                     "ORDER BY sa.fullname";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            HashMap<String, String> student = new HashMap<>();
            student.put("roll_no", rs.getString("roll_no"));
            student.put("fullname", rs.getString("fullname"));
            student.put("email", rs.getString("email"));
            student.put("phone", rs.getString("mobile"));
            student.put("room_no", rs.getString("room_no"));
            student.put("allocation_date", new SimpleDateFormat("dd-MMM-yyyy").format(rs.getDate("allocation_date")));
            allocatedStudents.add(student);
        }

    } catch (Exception e) {
        errorMessage = "An error occurred while fetching student list: " + e.getMessage();
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocated Students List</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --approved-color: #10b981; --approved-bg: #f0fdf4; --approved-border: #a7f3d0;
            --error-color: #ef4444; --error-bg: #fef2f2; --error-border: #fca5a5;
            --view-detail-color: #4f46e5; /* Indigo-600 */
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
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 2rem; }
        .table-container { width: 100%; overflow-x: auto; }
        .students-table { width: 100%; border-collapse: collapse; }
        .students-table th, .students-table td { padding: 1.25rem 1.5rem; text-align: left; border-bottom: 1px solid var(--border-color); white-space: nowrap; }
        .students-table thead { background-color: var(--secondary-color); }
        .students-table th { font-size: 0.85rem; font-weight: 600; text-transform: uppercase; color: var(--light-text-color); }
        .students-table tbody tr:hover { background-color: var(--secondary-color); }
        .action-button { 
            padding: 0.6rem 1rem; border-radius: 6px; font-weight: 500; text-decoration: none; 
            cursor: pointer; transition: background-color 0.2s ease; font-size: 0.9rem;
            background-color: var(--view-detail-color); color: white; border: 1px solid var(--view-detail-color);
        }
        .action-button:hover { background-color: #3730a3; } /* Darker indigo */

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
            <h1>Allocated Students</h1>
            <% if (errorMessage != null) { %>
                <div class="message-box error"><%= errorMessage %></div>
            <% } %>
        </div>

        <div class="card">
            <div class="table-container">
                <table class="students-table">
                    <thead>
                        <tr>
                            <th>Roll No</th>
                            <th>Student Name</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Room No</th>
                            <th>Allocation Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (allocatedStudents.isEmpty()) { %>
                            <tr>
                                <td colspan="7" style="text-align: center; color: var(--light-text-color); padding: 2rem;">No students allocated to rooms yet.</td>
                            </tr>
                        <% } else {
                                for (HashMap<String, String> student : allocatedStudents) {
                        %>
                                <tr>
                                    <td><%= student.get("roll_no") %></td>
                                    <td><%= student.get("fullname") %></td>
                                    <td><%= student.get("email") %></td>
                                    <td><%= student.get("phone") %></td>
                                    <td><%= student.get("room_no") %></td>
                                    <td><%= student.get("allocation_date") %></td>
                                    <td class="action-buttons">
                                        <%-- Link to admin_allocate_room.jsp to view/manage their current allocation --%>
                                        <a href="view_student_details.jsp?stud_roll=<%= student.get("roll_no") %>" class="action-button"><i class="fas fa-eye"></i> View Details</a>
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