<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%-- =================================================================
     SERVER-SIDE LOGIC FOR ROOM ALLOCATION
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
    String message = null;
    String messageType = null; // 'success' or 'error' or 'info'

    // Student details for display
    String studentFullname = null;
    String currentRoomNumberDisplay = "Not Allocated"; // For displaying "Not Allocated" or room_no
    String currentAllocatedRoomNo = null; // Actual room_no if allocated

    // List to hold available rooms
    List<Map<String, Object>> availableRooms = new ArrayList<>();

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

        if (studRoll == null || studRoll.trim().isEmpty()) {
            message = "Student Roll Number is missing for room allocation.";
            messageType = "error";
        } else {
            // --- A. Fetch Student Info and Current Room (from room_allocations) ---
            String studentInfoSql = "SELECT sa.fullname, ra.room_no " +
                                    "FROM student_auth sa " +
                                    "LEFT JOIN room_allocations ra ON sa.roll_no = ra.roll_no " +
                                    "WHERE sa.roll_no = ?";
            pstmt = conn.prepareStatement(studentInfoSql);
            pstmt.setString(1, studRoll);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                studentFullname = rs.getString("fullname");
                currentAllocatedRoomNo = rs.getString("room_no"); // This gets the room_no if allocated
                if (currentAllocatedRoomNo != null) {
                    currentRoomNumberDisplay = currentAllocatedRoomNo; 
                }
            } else {
                message = "Student with Roll Number " + studRoll + " not found.";
                messageType = "error";
            }
            rs.close();
            if (pstmt != null) pstmt.close();

            // --- B. Handle Room Allocation Form Submission ---
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("action");
                if ("allocate".equals(action) && studentFullname != null) {
                    String selectedRoomNo = request.getParameter("selected_room_no"); 
                    if (selectedRoomNo != null && !selectedRoomNo.trim().isEmpty()) {
                        try {
                            // Start Transaction
                            conn.setAutoCommit(false);

                            // 1. If student already has a room and it's a different room, de-allocate it first
                            if (currentAllocatedRoomNo != null && !currentAllocatedRoomNo.equals(selectedRoomNo)) { 
                                // Decrement occupied_slots for the old room
                                String deallocateRoomUpdateSql = "UPDATE room SET occupied_slots = occupied_slots - 1 WHERE room_no = ?";
                                pstmt = conn.prepareStatement(deallocateRoomUpdateSql);
                                pstmt.setString(1, currentAllocatedRoomNo);
                                pstmt.executeUpdate();
                                if (pstmt != null) pstmt.close();

                                // Delete the old allocation record
                                String deallocateRecordSql = "DELETE FROM room_allocations WHERE roll_no = ?";
                                pstmt = conn.prepareStatement(deallocateRecordSql);
                                pstmt.setString(1, studRoll);
                                pstmt.executeUpdate();
                                if (pstmt != null) pstmt.close();
                                
                                message = "Previous room " + currentAllocatedRoomNo + " de-allocated. ";

                            } else if (currentAllocatedRoomNo != null && currentAllocatedRoomNo.equals(selectedRoomNo)) {
                                message = "Student is already allocated to room " + selectedRoomNo + ". No change made.";
                                messageType = "info"; 
                                conn.rollback(); // Rollback any implicit changes if transaction was started (safe for this case)
                                response.sendRedirect("admin_allocate_room.jsp?stud_roll=" + studRoll + "&message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&messageType=" + messageType);
                                return; 
                            }

                            // 2. Allocate the new room
                            // Check if an allocation record already exists for this student for the *same* new room to prevent PK violation on re-attempt
                            pstmt = conn.prepareStatement("SELECT COUNT(*) FROM room_allocations WHERE roll_no = ? AND room_no = ?");
                            pstmt.setString(1, studRoll);
                            pstmt.setString(2, selectedRoomNo);
                            rs = pstmt.executeQuery();
                            rs.next();
                            boolean exists = rs.getInt(1) > 0;
                            rs.close();
                            if (pstmt != null) pstmt.close();

                            int rowsAffected;
                            if (exists) {
                                // If already allocated to the selected room (which shouldn't happen if previous deallocation worked, but as a safeguard)
                                rowsAffected = 1; // Treat as successful for the transaction flow
                            } else {
                                String allocateRecordSql = "INSERT INTO room_allocations (roll_no, room_no, allocation_date) VALUES (?, ?, CURDATE())";
                                pstmt = conn.prepareStatement(allocateRecordSql);
                                pstmt.setString(1, studRoll);
                                pstmt.setString(2, selectedRoomNo);
                                rowsAffected = pstmt.executeUpdate();
                                if (pstmt != null) pstmt.close();
                            }

                            if (rowsAffected > 0) {
                                // 3. Increment occupied_slots for the new room (only if it's genuinely a new allocation or a change)
                                // We need to ensure we don't double increment if the student was already allocated to this room
                                // This check is already handled by the 'exists' variable above for initial insert.
                                // If the student changed rooms, the old room's count was decremented, so we increment for the new one.
                                // If the student was not allocated, we just increment.
                                
                                // Check if the selected room's occupied_slots needs incrementing
                                pstmt = conn.prepareStatement("SELECT COUNT(*) FROM room_allocations WHERE room_no = ? AND roll_no = ?");
                                pstmt.setString(1, selectedRoomNo);
                                pstmt.setString(2, studRoll);
                                rs = pstmt.executeQuery();
                                rs.next();
                                // Only increment if this is a new allocation for this room (i.e., this student wasn't counted for this room before)
                                if (rs.getInt(1) == 1 && (currentAllocatedRoomNo == null || !currentAllocatedRoomNo.equals(selectedRoomNo))) { 
                                     String updateNewRoomSql = "UPDATE room SET occupied_slots = occupied_slots + 1 WHERE room_no = ?";
                                     pstmt = conn.prepareStatement(updateNewRoomSql);
                                     pstmt.setString(1, selectedRoomNo);
                                     pstmt.executeUpdate();
                                     if (pstmt != null) pstmt.close();
                                }
                                rs.close(); // Close rs here

                                conn.commit(); // Commit transaction
                                message = "Room " + selectedRoomNo + " successfully allocated to " + studentFullname + " (" + studRoll + ").";
                                messageType = "success";
                                currentAllocatedRoomNo = selectedRoomNo; // Update for display
                                currentRoomNumberDisplay = selectedRoomNo; // Update for display
                            } else {
                                conn.rollback(); // Rollback if room_allocations insert failed
                                message = "Failed to allocate room for student " + studentFullname + ".";
                                messageType = "error";
                            }
                        } catch (SQLIntegrityConstraintViolationException e) {
                            if (conn != null) {
                                try { conn.rollback(); } catch (SQLException rbex) { rbex.printStackTrace(); }
                            }
                            // This catch block handles cases where the allocation record might already exist unexpectedly
                            message = "The student is already allocated to room " + selectedRoomNo + ". No changes made.";
                            messageType = "info";
                        }
                        catch (SQLException e) {
                            if (conn != null) {
                                try { conn.rollback(); } catch (SQLException rbex) { rbex.printStackTrace(); }
                            }
                            message = "A database error occurred during allocation: " + e.getMessage();
                            messageType = "error";
                            e.printStackTrace();
                        } finally {
                            if (conn != null) {
                                try { conn.setAutoCommit(true); } catch (SQLException acEx) { acEx.printStackTrace(); } // Reset auto-commit
                            }
                            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    } else {
                        message = "No room selected for allocation.";
                        messageType = "error";
                    }
                }
            }

            // --- C. Fetch Available Rooms for Selection (Always fetch after potential allocation) ---
            // Include the currently allocated room if any, so it can be re-selected even if full, 
            // or if we are changing it to a different room. This prevents issues if student's current room is full.
            String availableRoomsSql = "SELECT room_no, floor_no, total_slots, occupied_slots " +
                                       "FROM room " +
                                       "WHERE occupied_slots < total_slots "; // Available rooms
            
            if (currentAllocatedRoomNo != null) {
                // If student is currently allocated, ensure their room is always an option
                availableRoomsSql += "OR room_no = '" + currentAllocatedRoomNo + "' "; 
            }
            availableRoomsSql += "ORDER BY room_no";

            pstmt = conn.prepareStatement(availableRoomsSql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> room = new HashMap<>();
                room.put("room_no", rs.getString("room_no"));
                room.put("floor_no", rs.getInt("floor_no"));
                room.put("total_slots", rs.getInt("total_slots"));
                room.put("occupied_slots", rs.getInt("occupied_slots"));
                availableRooms.add(room);
            }
            rs.close();
            if (pstmt != null) pstmt.close();
        }

    } catch (Exception e) {
        message = "A general error occurred: " + e.getMessage();
        messageType = "error";
        e.printStackTrace();
    } finally {
        // Ensure all JDBC resources are closed
        try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
    
    // Retrieve messages from redirect if they exist
    if (request.getParameter("message") != null) {
        message = request.getParameter("message");
        messageType = request.getParameter("messageType");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocate Room - Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #1f2937; --secondary-color: #f9fafb; --accent-color: #2563eb;
            --light-text-color: #6b7280; --card-bg: #ffffff; --border-color: #e5e7eb;
            --success-color: #10b981; --success-bg: #f0fdf4; --success-border: #a7f3d0;
            --error-color: #ef4444; --error-bg: #fef2f2; --error-border: #fca5a5;
            --info-color: #3b82f6; --info-bg: #eff6ff; --info-border: #93c5fd; 
            --button-primary-bg: var(--accent-color); --button-primary-hover: #1d4ed8;
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
        .message-box.success { background-color: var(--success-bg); border: 1px solid var(--success-border); color: var(--success-color); }
        .message-box.error { background-color: var(--error-bg); border: 1px solid var(--error-border); color: var(--error-color); }
        .message-box.info { background-color: var(--info-bg); border: 1px solid var(--info-border); color: var(--info-color); } 
        .card { background-color: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); margin-bottom: 2rem; padding: 2rem; }
        
        .detail-item { display: flex; flex-direction: column; padding: 0.5rem 0; }
        .detail-label { font-size: 0.85rem; color: var(--light-text-color); margin-bottom: 0.25rem; font-weight: 500; }
        .detail-value { font-size: 1rem; color: var(--primary-color); font-weight: 600; }

        .form-group { margin-bottom: 1.5rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-weight: 600; color: var(--primary-color); }
        .form-group select, .form-group input[type="text"] {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 1rem;
            color: var(--primary-color);
            background-color: var(--secondary-color);
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-group select:focus, .form-group input[type="text"]:focus {
            border-color: var(--accent-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.2);
            outline: none;
        }
        .form-actions { display: flex; gap: 1rem; justify-content: flex-end; margin-top: 2rem; }
        .form-actions .button {
            padding: 0.8rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: background-color 0.2s ease, transform 0.2s ease;
            font-size: 1rem;
            border: none;
        }
        .form-actions .button:hover { transform: translateY(-2px); }
        .form-actions .button.primary { background-color: var(--button-primary-bg); color: white; }
        .form-actions .button.primary:hover { background-color: var(--button-primary-hover); }
        .form-actions .button.secondary { background-color: var(--button-secondary-bg); color: white; }
        .form-actions .button.secondary:hover { background-color: var(--button-secondary-hover); }
        
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
        </ul>
    </aside>
    <main class="main-content">
        <div class="page-header">
            <h1>Allocate Room</h1>
        </div>

        <%-- Display messages --%>
        <% if (message != null) { %>
            <div class="message-box <%= messageType %>">
                <%= message %>
            </div>
        <% } %>

        <% if (studRoll != null && studentFullname != null) { %>
            <div class="card">
                <h2>Student: <%= studentFullname %> (<%= studRoll %>)</h2>
                <div class="detail-item">
                    <span class="detail-label">Current Room</span>
                    <span class="detail-value"><%= currentRoomNumberDisplay %>
                        <% if (currentAllocatedRoomNo != null) { %>
                            (Room Number: <%= currentAllocatedRoomNo %>)
                        <% } %>
                    </span>
                </div>

                <form action="admin_allocate_room.jsp?stud_roll=<%= studRoll %>" method="POST">
                    <input type="hidden" name="action" value="allocate">
                    <div class="form-group" style="margin-top: 2rem;">
                        <label for="selected_room_no">Select an Available Room:</label>
                        <select id="selected_room_no" name="selected_room_no" required>
                            <option value="">-- Choose Room --</option>
                            <% if (availableRooms.isEmpty()) { %>
                                <option value="" disabled>No available rooms found</option>
                            <% } else { %>
                                <% for (Map<String, Object> room : availableRooms) { %>
                                    <option value="<%= room.get("room_no") %>"
                                        <% if (currentAllocatedRoomNo != null && currentAllocatedRoomNo.equals(room.get("room_no"))) { %>
                                            selected
                                        <% } %>
                                    >
                                        <%= room.get("room_no") %> (Floor: <%= room.get("floor_no") %>, Occupancy: <%= room.get("occupied_slots") %>/<%= room.get("total_slots") %>)
                                    </option>
                                <% } %>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-actions">
                         <%-- Link back to the appropriate page --%>
                        <%
                            // If coming from applications, go back to applications
                            String referer = request.getHeader("referer");
                            String backLink = "admin_applications.jsp"; // Default back to applications
                            if (referer != null && referer.contains("admin_slist.jsp")) {
                                backLink = "admin_slist.jsp"; // If coming from student list, go back to student list
                            }
                        %>
                        <a href="<%= backLink %>" class="button secondary"><i class="fas fa-arrow-left"></i> Back</a>
                        <button type="submit" class="button primary" <%= availableRooms.isEmpty() && currentAllocatedRoomNo == null ? "disabled" : "" %>>
                            <i class="fas fa-person-booth"></i> Allocate Room
                        </button>
                    </div>
                </form>
            </div>
        <% } else if (messageType == null || "error".equals(messageType)) { %>
            <div class="card">
                <p>Unable to load student details for allocation. Please ensure a valid student roll number is provided.</p>
                <div class="form-actions">
                    <a href="admin_applications.jsp" class="button secondary"><i class="fas fa-arrow-left"></i> Back to Applications list</a>
                    <a href="admin_slist.jsp" class="button secondary" style="margin-left: 0.5rem;"><i class="fas fa-arrow-left"></i> Back to Student list</a>
                </div>
            </div>
        <% } %>
    </main>
</body>
</html>